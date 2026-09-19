import { corsHeaders,json } from '../_shared/cors.ts';
import { currentUser } from '../_shared/auth.ts';
Deno.serve(async(req)=>{
  if(req.method==='OPTIONS')return new Response('ok',{headers:corsHeaders});
  try{
    const {user,db}=await currentUser(req);const {attempt_id}=await req.json();const {data:a,error}=await db.from('attempts').select('*').eq('id',attempt_id).eq('user_id',user.id).single();if(error||!a)return json({error:'Pengerjaan tidak ditemukan.'},404);if(a.status==='completed')return json({attempt_id:a.id,score:a.score});if(a.status!=='in_progress')return json({error:'Pengerjaan tidak aktif.'},400);
    const {data:rows,error:qe}=await db.from('attempt_questions').select('id,selected_option,questions(correct_option)').eq('attempt_id',a.id);if(qe)throw qe;
    let correct=0;for(const r of rows||[]){const yes=!!r.selected_option&&r.selected_option===(r.questions as any).correct_option;if(yes)correct++;const {error:uErr}=await db.from('attempt_questions').update({is_correct:yes}).eq('id',r.id);if(uErr)throw uErr}
    const wrong=a.total_questions-correct,score=Number((100*correct/a.total_questions).toFixed(2)),completed=new Date(),duration=Math.max(0,Math.min(Math.round((completed.getTime()-new Date(a.started_at).getTime())/1000),24*3600));
    const {error:upErr}=await db.from('attempts').update({status:'completed',correct_count:correct,wrong_count:wrong,score,completed_at:completed.toISOString(),duration_seconds:duration}).eq('id',a.id).eq('status','in_progress');if(upErr)throw upErr;
    return json({attempt_id:a.id,score,correct_count:correct,wrong_count:wrong});
  }catch(e){console.error(e);return json({error:e instanceof Error?e.message:'Terjadi kesalahan.'},400)}
});
