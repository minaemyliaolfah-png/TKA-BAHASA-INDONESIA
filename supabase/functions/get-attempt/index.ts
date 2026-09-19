import { corsHeaders,json } from '../_shared/cors.ts';
import { currentUser } from '../_shared/auth.ts';
Deno.serve(async(req)=>{
  if(req.method==='OPTIONS')return new Response('ok',{headers:corsHeaders});
  try{
    const {user,profile,db}=await currentUser(req);const {attempt_id,include_review=false}=await req.json();
    const {data:a,error}=await db.from('attempts').select('*,topics(name),mini_tryouts(name),tryouts(name)').eq('id',attempt_id).single();if(error||!a)return json({error:'Pengerjaan tidak ditemukan.'},404);
    if(a.user_id!==user.id&&!['teacher','admin'].includes(profile.role))return json({error:'Tidak diizinkan.'},403);
    const completed=a.status==='completed';if(include_review&&!completed)return json({error:'Pembahasan hanya tersedia setelah submit.'},403);
    const {data:rows,error:qe}=await db.from('attempt_questions').select('id,question_order,selected_option,is_flagged,is_correct,questions(id,question_text,image_url,option_a,option_b,option_c,option_d,option_e,correct_option,explanation)').eq('attempt_id',a.id).order('question_order');if(qe)throw qe;
    const questions=(rows||[]).map((r:any)=>({id:r.id,question_id:r.questions.id,question_text:r.questions.question_text,image_url:r.questions.image_url,selected_option:r.selected_option,is_flagged:r.is_flagged,...(completed&&include_review?{is_correct:r.is_correct,correct_option:r.questions.correct_option,explanation:r.questions.explanation}:{}),options:[['A',r.questions.option_a],['B',r.questions.option_b],['C',r.questions.option_c],['D',r.questions.option_d],['E',r.questions.option_e]].filter(x=>x[1]).map(x=>({key:x[0],text:x[1]}))}));
    const display_name=a.type==='practice'?(a.topics?.name||'Latihan'):a.type==='mini_tryout'?(a.mini_tryouts?.name||'Mini Tryout'):(a.tryouts?.name||'Tryout');
    return json({id:a.id,type:a.type,status:a.status,score:a.score,correct_count:a.correct_count,wrong_count:a.wrong_count,duration_seconds:a.duration_seconds,started_at:a.started_at,expires_at:a.expires_at,completed_at:a.completed_at,display_name,questions});
  }catch(e){console.error(e);return json({error:e instanceof Error?e.message:'Terjadi kesalahan.'},400)}
});
