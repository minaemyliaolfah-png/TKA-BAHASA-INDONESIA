import { corsHeaders,json } from '../_shared/cors.ts';
import { currentUser } from '../_shared/auth.ts';
const emailFor=(u:string)=>`${u.trim().toLowerCase().replace(/[^a-z0-9._-]/g,'')}@tka.internal`;
Deno.serve(async(req)=>{
  if(req.method==='OPTIONS')return new Response('ok',{headers:corsHeaders});
  try{
    const {profile,db}=await currentUser(req);if(profile.role!=='admin')return json({error:'Hanya administrator yang dapat mengelola akun.'},403);const body=await req.json();
    if(body.action==='create'){
      if(!body.username||!body.full_name||String(body.password||'').length<8)return json({error:'Data belum lengkap atau password kurang dari 8 karakter.'},400);
      const {data,error}=await db.auth.admin.createUser({email:emailFor(body.username),password:body.password,email_confirm:true,user_metadata:{username:body.username,full_name:body.full_name,role:body.role||'student',must_change_password:true}});if(error)throw error;
      if(body.class_id)await db.from('profiles').update({class_id:body.class_id}).eq('id',data.user.id);return json({user_id:data.user.id});
    }
    if(body.action==='reset_password'){
      if(!body.user_id||String(body.password||'').length<8)return json({error:'Password minimal 8 karakter.'},400);const {error}=await db.auth.admin.updateUserById(body.user_id,{password:body.password,user_metadata:{must_change_password:true}});if(error)throw error;await db.from('profiles').update({must_change_password:true}).eq('id',body.user_id);return json({ok:true});
    }
    if(body.action==='import'){
      const rows=Array.isArray(body.rows)?body.rows.slice(0,200):[];let created=0;const errors=[];const {data:classes}=await db.from('classes').select('id,name');const classMap=new Map((classes||[]).map(x=>[x.name.toLowerCase(),x.id]));
      for(const [i,r] of rows.entries())try{if(!r.username||!r.nama||String(r.password||'').length<8)throw new Error('Data wajib tidak lengkap');const cid=r.kelas?classMap.get(String(r.kelas).toLowerCase()):null;if(r.kelas&&!cid)throw new Error(`Kelas ${r.kelas} tidak ditemukan`);const {data,error}=await db.auth.admin.createUser({email:emailFor(r.username),password:r.password,email_confirm:true,user_metadata:{username:r.username,full_name:r.nama,role:'student',must_change_password:true}});if(error)throw error;if(cid)await db.from('profiles').update({class_id:cid}).eq('id',data.user.id);created++}catch(e){errors.push({row:i+2,error:e instanceof Error?e.message:'Gagal'})}
      return json({created,errors});
    }
    return json({error:'Aksi tidak dikenali.'},400);
  }catch(e){console.error(e);return json({error:e instanceof Error?e.message:'Terjadi kesalahan.'},400)}
});
