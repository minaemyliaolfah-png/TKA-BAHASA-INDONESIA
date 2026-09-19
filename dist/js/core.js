import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.57.4';
import { CONFIG } from './config.js';

const configured = CONFIG.SUPABASE_URL?.startsWith('https://') && !CONFIG.SUPABASE_URL.includes('YOUR_PROJECT') && CONFIG.SUPABASE_ANON_KEY && !CONFIG.SUPABASE_ANON_KEY.includes('YOUR_PUBLIC');
export const supabase = configured ? createClient(CONFIG.SUPABASE_URL, CONFIG.SUPABASE_ANON_KEY, {auth:{persistSession:true,autoRefreshToken:true,detectSessionInUrl:true}}) : null;
export const isConfigured = configured;

export const $ = (s, root=document) => root.querySelector(s);
export const $$ = (s, root=document) => [...root.querySelectorAll(s)];
export const esc = (value='') => String(value).replace(/[&<>'"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[c]));
export const fmtDate = value => value ? new Intl.DateTimeFormat('id-ID',{dateStyle:'medium',timeStyle:'short'}).format(new Date(value)) : '—';
export const fmtDuration = seconds => `${String(Math.floor((seconds||0)/60)).padStart(2,'0')}:${String((seconds||0)%60).padStart(2,'0')}`;
export const emailForUsername = identifier => {
  const value=String(identifier).trim().toLowerCase();
  return value.includes('@') ? value : `${value.replace(/[^a-z0-9._-]/g,'')}@tka.internal`;
};

export function toast(message,type='success'){
  const el=document.createElement('div'); el.className=`toast ${type}`; el.textContent=message;
  $('#toast-region')?.append(el); setTimeout(()=>el.remove(),3200);
}
export function setLoading(button,on,label='Memproses…'){
  if(!button)return; if(on){button.dataset.label=button.innerHTML;button.disabled=true;button.textContent=label}else{button.disabled=false;button.innerHTML=button.dataset.label||button.innerHTML}
}
export function openModal(html){$('#modal-content').innerHTML=html;$('#modal').classList.remove('hidden');setTimeout(()=>$('#modal input, #modal select, #modal button:not(.modal-close)')?.focus(),20)}
export function closeModal(){$('#modal').classList.add('hidden');$('#modal-content').innerHTML=''}
export function setupModal(){ $('#modal-close')?.addEventListener('click',closeModal); $('#modal')?.addEventListener('click',e=>{if(e.target.id==='modal')closeModal()}); document.addEventListener('keydown',e=>{if(e.key==='Escape')closeModal()}) }
export function emptyState(icon,title,copy,action=''){return `<div class="empty-state"><div class="empty-icon">${icon}</div><h3>${esc(title)}</h3><p>${esc(copy)}</p>${action}</div>`}
export function skeleton(){return `<div class="skeleton large"></div><div style="height:12px"></div><div class="skeleton"></div>`}
export async function requireSession(roles=[]){
  if(!supabase)return {error:new Error('Aplikasi belum dikonfigurasi. Salin config.example.js menjadi config.js lalu isi URL dan anon key Supabase.')};
  const {data:{session},error}=await supabase.auth.getSession(); if(error||!session)return {session:null,error};
  const {data:profile,error:profileError}=await supabase.from('profiles').select('id,username,full_name,role,class_id,must_change_password,classes(name)').eq('id',session.user.id).single();
  if(profileError)return {session:null,error:profileError}; if(roles.length&&!roles.includes(profile.role))return {session:null,error:new Error('Akun tidak memiliki izin untuk halaman ini.')};
  return {session,profile};
}
export async function login(username,password){ if(!supabase)throw new Error('Konfigurasi Supabase belum diisi.'); return supabase.auth.signInWithPassword({email:emailForUsername(username),password}); }
export async function logout(){await supabase?.auth.signOut();location.reload()}
export async function invoke(name,body={}){const {data,error}=await supabase.functions.invoke(name,{body});if(error)throw error;if(data?.error)throw new Error(data.error);return data}
export function scoreBadge(score){const n=Number(score||0);return n>=80?'good':n>=65?'warn':'bad'}
export function initials(name='Siswa'){return name.split(/\s+/).slice(0,2).map(x=>x[0]).join('').toUpperCase()}
export function setupSidebar(){
  $('#mobile-menu')?.addEventListener('click',()=>$('.sidebar').classList.toggle('open'));
  document.addEventListener('click',e=>{if(innerWidth<761&&!e.target.closest('.sidebar')&&!e.target.closest('#mobile-menu'))$('.sidebar')?.classList.remove('open')});
}
export function downloadCsv(filename,rows){
  if(!rows.length)return; const headers=Object.keys(rows[0]); const cell=v=>`"${String(v??'').replaceAll('"','""')}"`; const csv=[headers.map(cell).join(','),...rows.map(r=>headers.map(h=>cell(r[h])).join(','))].join('\n');
  const a=document.createElement('a');a.href=URL.createObjectURL(new Blob(['\ufeff'+csv],{type:'text/csv;charset=utf-8'}));a.download=filename;a.click();URL.revokeObjectURL(a.href);
}
export function parseCsv(text){
  const rows=[];let row=[],cell='',quote=false;for(let i=0;i<text.length;i++){const c=text[i],n=text[i+1];if(c==='"'&&quote&&n==='"'){cell+='"';i++}else if(c==='"'){quote=!quote}else if(c===','&&!quote){row.push(cell.trim());cell=''}else if((c==='\n'||c==='\r')&&!quote){if(c==='\r'&&n==='\n')i++;row.push(cell.trim());if(row.some(Boolean))rows.push(row);row=[];cell=''}else cell+=c}if(cell||row.length){row.push(cell.trim());rows.push(row)}if(rows.length<2)return[];const h=rows[0].map(x=>x.toLowerCase().trim());return rows.slice(1).map(r=>Object.fromEntries(h.map((k,i)=>[k,r[i]??''])))}
