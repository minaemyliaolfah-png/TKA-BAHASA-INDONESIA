import { corsHeaders,json } from '../_shared/cors.ts';
import { currentUser,shuffled } from '../_shared/auth.ts';

Deno.serve(async(req)=>{
  if(req.method==='OPTIONS')return new Response('ok',{headers:corsHeaders});
  try{
    const {user,profile,db}=await currentUser(req); if(profile.role!=='student')return json({error:'Hanya akun siswa yang dapat memulai pengerjaan.'},403);
    const body=await req.json(); const type=body.type; if(!['practice','mini_tryout','tryout'].includes(type))return json({error:'Jenis pengerjaan tidak valid.'},400);
    let topicId:string|null=null,miniId:string|null=null,tryoutId:string|null=null,subjectId:string|null=null,count=0,duration=45,blueprints:any[]=[];
    if(type==='practice'){
      topicId=body.topic_id; count=Math.min(15,Math.max(5,Number(body.question_count||5))); duration=Math.max(15,count*3);
      const {data:t,error}=await db.from('topics').select('id,subject_id,status').eq('id',topicId).single(); if(error||t.status!=='active')return json({error:'Materi tidak tersedia.'},404);subjectId=t.subject_id;blueprints=[{topic_id:topicId,question_count:count}];
    }else{
      const table=type==='mini_tryout'?'mini_tryouts':'tryouts',id=type==='mini_tryout'?body.mini_tryout_id:body.tryout_id;
      const {data:item,error}=await db.from(table).select('*').eq('id',id).eq('status','active').single();if(error||!item)return json({error:'Paket tidak tersedia.'},404);
      if(type==='tryout'&&((item.start_at&&Date.now()<new Date(item.start_at).getTime())||(item.end_at&&Date.now()>new Date(item.end_at).getTime())))return json({error:'Tryout belum dimulai atau sudah berakhir.'},400);
      const {count:used}=await db.from('attempts').select('*',{count:'exact',head:true}).eq('user_id',user.id).eq(type==='mini_tryout'?'mini_tryout_id':'tryout_id',id).eq('status','completed');
      if((used||0)>=item.max_attempts)return json({error:'Kesempatan pengerjaan sudah habis.'},400);
      count=item.question_count;duration=item.duration_minutes;subjectId=item.subject_id;if(type==='mini_tryout')miniId=id;else tryoutId=id;
      const bpTable=type==='mini_tryout'?'mini_tryout_blueprints':'tryout_blueprints',fk=type==='mini_tryout'?'mini_tryout_id':'tryout_id';
      const {data:bp,error:bpErr}=await db.from(bpTable).select('*').eq(fk,id);if(bpErr||!bp?.length)return json({error:'Blueprint belum diatur.'},400);blueprints=bp;
    }
    const selected:any[]=[];
    for(const bp of blueprints){
      let query=db.from('questions').select('id,topic_id').eq('topic_id',bp.topic_id).eq('status','active');if(bp.subtopic_id)query=query.eq('subtopic_id',bp.subtopic_id);if(bp.difficulty)query=query.eq('difficulty',bp.difficulty);
      const {data:pool,error}=await query;if(error)throw error;
      const ids=(pool||[]).map(x=>x.id);const {data:history}=ids.length?await db.from('attempt_questions').select('question_id,is_correct,attempts!inner(user_id,status)').in('question_id',ids).eq('attempts.user_id',user.id).eq('attempts.status','completed'):{data:[]};
      const seen=new Map<string,{wrong:boolean}>();for(const h of history||[]){const old=seen.get(h.question_id)||{wrong:false};old.wrong=old.wrong||h.is_correct===false;seen.set(h.question_id,old)}
      const unseen=shuffled((pool||[]).filter(x=>!seen.has(x.id))),wrong=shuffled((pool||[]).filter(x=>seen.get(x.id)?.wrong)),other=shuffled((pool||[]).filter(x=>seen.has(x.id)&&!seen.get(x.id)?.wrong));
      const wrongQuota=Math.min(wrong.length,Math.max(1,Math.floor(bp.question_count*.3)));
      const first=[...unseen.slice(0,Math.max(0,bp.question_count-wrongQuota)),...wrong.slice(0,wrongQuota)];
      const chosen=[...first,...unseen,...wrong,...other].filter((x,i,a)=>a.findIndex(y=>y.id===x.id)===i).slice(0,bp.question_count);
      if(chosen.length<bp.question_count)return json({error:`Soal aktif pada salah satu materi belum cukup (butuh ${bp.question_count}, tersedia ${chosen.length}).`},400);selected.push(...chosen);
    }
    const ordered=shuffled(selected);if(ordered.length!==count)return json({error:`Total blueprint (${ordered.length}) tidak sama dengan jumlah soal (${count}).`},400);
    const expiresAt=new Date(Date.now()+duration*60_000).toISOString();
    const {data:attempt,error:aErr}=await db.from('attempts').insert({user_id:user.id,type,subject_id:subjectId,topic_id:topicId,mini_tryout_id:miniId,tryout_id:tryoutId,total_questions:count,expires_at:expiresAt}).select('id').single();if(aErr)throw aErr;
    const rows=ordered.map((x,i)=>({attempt_id:attempt.id,question_id:x.id,topic_id:x.topic_id,question_order:i+1}));const {error:qErr}=await db.from('attempt_questions').insert(rows);if(qErr){await db.from('attempts').delete().eq('id',attempt.id);throw qErr}
    return json({attempt_id:attempt.id,expires_at:expiresAt});
  }catch(e){console.error(e);return json({error:e instanceof Error?e.message:'Terjadi kesalahan.'},400)}
});
