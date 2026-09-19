import { createClient } from 'npm:@supabase/supabase-js@2';
export const adminClient = () => createClient(Deno.env.get('SUPABASE_URL')!,Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,{auth:{persistSession:false,autoRefreshToken:false}});
export async function currentUser(req:Request){
  const token=(req.headers.get('Authorization')||'').replace(/^Bearer\s+/i,''); if(!token)throw new Error('Sesi tidak ditemukan');
  const db=adminClient(); const {data:{user},error}=await db.auth.getUser(token); if(error||!user)throw new Error('Sesi tidak valid');
  const {data:profile,error:pe}=await db.from('profiles').select('id,role,status').eq('id',user.id).single(); if(pe||!profile||profile.status!=='active')throw new Error('Akun tidak aktif');
  return {user,profile,db};
}
export const shuffled=<T>(items:T[])=>items.map(value=>({value,key:crypto.getRandomValues(new Uint32Array(1))[0]})).sort((a,b)=>a.key-b.key).map(x=>x.value);
