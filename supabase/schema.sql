-- TKA Cerdas — Supabase schema
-- Run once in a new Supabase project using SQL Editor.

create extension if not exists pgcrypto;

create type public.user_role as enum ('student','teacher','admin');
create type public.content_status as enum ('draft','active','inactive');
create type public.attempt_type as enum ('practice','mini_tryout','tryout');
create type public.attempt_status as enum ('in_progress','completed','expired','cancelled');
create type public.difficulty_level as enum ('easy','medium','hard');

create table public.classes (
  id uuid primary key default gen_random_uuid(), name text not null,
  academic_year text not null, status public.content_status not null default 'active',
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique(name, academic_year)
);
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique check (username ~ '^[a-zA-Z0-9._-]{3,50}$'),
  full_name text not null, role public.user_role not null default 'student',
  class_id uuid references public.classes(id) on delete set null,
  status public.content_status not null default 'active', must_change_password boolean not null default true,
  last_login_at timestamptz, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.subjects (
  id uuid primary key default gen_random_uuid(), name text not null, code text not null unique,
  description text, sort_order int not null default 0, status public.content_status not null default 'draft',
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.topics (
  id uuid primary key default gen_random_uuid(), subject_id uuid not null references public.subjects(id) on delete cascade,
  name text not null, description text, sort_order int not null default 0,
  status public.content_status not null default 'draft', created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique(subject_id,name)
);
create table public.subtopics (
  id uuid primary key default gen_random_uuid(), topic_id uuid not null references public.topics(id) on delete cascade,
  name text not null, description text, sort_order int not null default 0,
  status public.content_status not null default 'draft', created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique(topic_id,name)
);
create table public.learning_materials (
  id uuid primary key default gen_random_uuid(), topic_id uuid not null references public.topics(id) on delete cascade,
  subtopic_id uuid references public.subtopics(id) on delete set null, title text not null, content text not null,
  sort_order int not null default 0, status public.content_status not null default 'draft',
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.material_completions (
  user_id uuid not null references public.profiles(id) on delete cascade,
  material_id uuid not null references public.learning_materials(id) on delete cascade,
  completed_at timestamptz not null default now(), primary key(user_id,material_id)
);
create table public.questions (
  id uuid primary key default gen_random_uuid(), subject_id uuid references public.subjects(id) on delete set null,
  topic_id uuid not null references public.topics(id) on delete cascade,
  subtopic_id uuid references public.subtopics(id) on delete set null,
  code text not null unique, question_text text not null, image_url text,
  option_a text not null, option_b text not null, option_c text not null, option_d text not null, option_e text,
  correct_option char(1) not null check (correct_option in ('A','B','C','D','E')),
  explanation text not null, difficulty public.difficulty_level not null default 'medium',
  source text, tags text[] not null default '{}', status public.content_status not null default 'draft',
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check (correct_option <> 'E' or option_e is not null)
);
create table public.mini_tryouts (
  id uuid primary key default gen_random_uuid(), name text not null, description text,
  subject_id uuid references public.subjects(id) on delete set null,
  question_count int not null check(question_count>0), duration_minutes int not null check(duration_minutes>0),
  max_attempts int not null default 3 check(max_attempts>0), status public.content_status not null default 'draft',
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.mini_tryout_blueprints (
  id uuid primary key default gen_random_uuid(), mini_tryout_id uuid not null references public.mini_tryouts(id) on delete cascade,
  topic_id uuid not null references public.topics(id) on delete cascade,
  subtopic_id uuid references public.subtopics(id) on delete set null,
  difficulty public.difficulty_level, question_count int not null check(question_count>0),
  unique(mini_tryout_id,topic_id,subtopic_id,difficulty)
);
create table public.tryouts (
  id uuid primary key default gen_random_uuid(), name text not null, description text,
  subject_id uuid references public.subjects(id) on delete set null,
  question_count int not null check(question_count>0), duration_minutes int not null check(duration_minutes>0),
  max_attempts int not null default 1 check(max_attempts>0), start_at timestamptz, end_at timestamptz,
  allow_resume boolean not null default true, status public.content_status not null default 'draft',
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check(end_at is null or start_at is null or end_at>start_at)
);
create table public.tryout_blueprints (
  id uuid primary key default gen_random_uuid(), tryout_id uuid not null references public.tryouts(id) on delete cascade,
  topic_id uuid not null references public.topics(id) on delete cascade,
  subtopic_id uuid references public.subtopics(id) on delete set null,
  difficulty public.difficulty_level, question_count int not null check(question_count>0),
  unique(tryout_id,topic_id,subtopic_id,difficulty)
);
create table public.attempts (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade,
  type public.attempt_type not null, subject_id uuid references public.subjects(id) on delete set null,
  topic_id uuid references public.topics(id) on delete set null,
  mini_tryout_id uuid references public.mini_tryouts(id) on delete set null,
  tryout_id uuid references public.tryouts(id) on delete set null,
  status public.attempt_status not null default 'in_progress', total_questions int not null check(total_questions>0),
  correct_count int not null default 0, wrong_count int not null default 0,
  score numeric(5,2) not null default 0 check(score between 0 and 100),
  started_at timestamptz not null default now(), expires_at timestamptz not null,
  completed_at timestamptz, duration_seconds int not null default 0,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check ((type='practice' and topic_id is not null and mini_tryout_id is null and tryout_id is null)
      or (type='mini_tryout' and mini_tryout_id is not null and tryout_id is null)
      or (type='tryout' and tryout_id is not null and mini_tryout_id is null))
);
create table public.attempt_questions (
  id uuid primary key default gen_random_uuid(), attempt_id uuid not null references public.attempts(id) on delete cascade,
  question_id uuid not null references public.questions(id) on delete restrict,
  topic_id uuid not null references public.topics(id) on delete restrict,
  question_order int not null check(question_order>0), selected_option char(1) check(selected_option in ('A','B','C','D','E')),
  is_flagged boolean not null default false, is_correct boolean,
  answered_at timestamptz, duration_seconds int not null default 0,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique(attempt_id,question_id), unique(attempt_id,question_order)
);

create index profiles_class_idx on public.profiles(class_id);
create index topics_subject_idx on public.topics(subject_id,status,sort_order);
create index subtopics_topic_idx on public.subtopics(topic_id,status,sort_order);
create index questions_pool_idx on public.questions(topic_id,subtopic_id,difficulty,status);
create index attempts_user_idx on public.attempts(user_id,status,started_at desc);
create index attempts_completed_idx on public.attempts(completed_at desc) where status='completed';
create index attempt_questions_attempt_idx on public.attempt_questions(attempt_id,question_order);
create index attempt_questions_history_idx on public.attempt_questions(question_id,is_correct);

create or replace function public.set_updated_at() returns trigger language plpgsql as $$
begin new.updated_at=now(); return new; end $$;
do $$ declare t text; begin foreach t in array array['classes','profiles','subjects','topics','subtopics','learning_materials','questions','mini_tryouts','tryouts','attempts','attempt_questions'] loop execute format('create trigger set_%I_updated_at before update on public.%I for each row execute function public.set_updated_at()',t,t); end loop; end $$;

create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin
  insert into public.profiles(id,username,full_name,role,must_change_password)
  values(new.id,coalesce(new.raw_user_meta_data->>'username',split_part(new.email,'@',1)),coalesce(new.raw_user_meta_data->>'full_name','Pengguna'),coalesce((new.raw_user_meta_data->>'role')::public.user_role,'student'),coalesce((new.raw_user_meta_data->>'must_change_password')::boolean,true));
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();

create or replace function public.is_staff() returns boolean language sql stable security definer set search_path=public as $$
  select exists(select 1 from public.profiles where id=auth.uid() and role in ('teacher','admin') and status='active')
$$;
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$
  select exists(select 1 from public.profiles where id=auth.uid() and role='admin' and status='active')
$$;
revoke all on function public.is_staff() from public; grant execute on function public.is_staff() to authenticated;
revoke all on function public.is_admin() from public; grant execute on function public.is_admin() to authenticated;

alter table public.classes enable row level security;
alter table public.profiles enable row level security;
alter table public.subjects enable row level security;
alter table public.topics enable row level security;
alter table public.subtopics enable row level security;
alter table public.learning_materials enable row level security;
alter table public.material_completions enable row level security;
alter table public.questions enable row level security;
alter table public.mini_tryouts enable row level security;
alter table public.mini_tryout_blueprints enable row level security;
alter table public.tryouts enable row level security;
alter table public.tryout_blueprints enable row level security;
alter table public.attempts enable row level security;
alter table public.attempt_questions enable row level security;

create policy "read own profile or staff" on public.profiles for select to authenticated using(id=auth.uid() or public.is_staff());
create policy "staff update profiles" on public.profiles for update to authenticated using(public.is_staff()) with check(public.is_staff());
create policy "read classes" on public.classes for select to authenticated using(status='active' or public.is_staff());
create policy "staff manage classes" on public.classes for all to authenticated using(public.is_staff()) with check(public.is_staff());
create policy "read active subjects" on public.subjects for select to authenticated using(status='active' or public.is_staff());
create policy "staff manage subjects" on public.subjects for all to authenticated using(public.is_staff()) with check(public.is_staff());
create policy "read active topics" on public.topics for select to authenticated using(status='active' or public.is_staff());
create policy "staff manage topics" on public.topics for all to authenticated using(public.is_staff()) with check(public.is_staff());
create policy "read active subtopics" on public.subtopics for select to authenticated using(status='active' or public.is_staff());
create policy "staff manage subtopics" on public.subtopics for all to authenticated using(public.is_staff()) with check(public.is_staff());
create policy "read active materials" on public.learning_materials for select to authenticated using(status='active' or public.is_staff());
create policy "staff manage materials" on public.learning_materials for all to authenticated using(public.is_staff()) with check(public.is_staff());
create policy "own material completions" on public.material_completions for select to authenticated using(user_id=auth.uid() or public.is_staff());
create policy "staff questions only" on public.questions for all to authenticated using(public.is_staff()) with check(public.is_staff());
create policy "read active mini tryouts" on public.mini_tryouts for select to authenticated using(status='active' or public.is_staff());
create policy "staff manage mini tryouts" on public.mini_tryouts for all to authenticated using(public.is_staff()) with check(public.is_staff());
create policy "staff mini blueprints" on public.mini_tryout_blueprints for all to authenticated using(public.is_staff()) with check(public.is_staff());
create policy "read active tryouts" on public.tryouts for select to authenticated using(status='active' or public.is_staff());
create policy "staff manage tryouts" on public.tryouts for all to authenticated using(public.is_staff()) with check(public.is_staff());
create policy "staff tryout blueprints" on public.tryout_blueprints for all to authenticated using(public.is_staff()) with check(public.is_staff());
create policy "read own attempts or staff" on public.attempts for select to authenticated using(user_id=auth.uid() or public.is_staff());
create policy "staff read attempt questions" on public.attempt_questions for select to authenticated using(public.is_staff());

create or replace function public.mark_material_complete(p_material_id uuid) returns void language plpgsql security definer set search_path=public as $$
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  if not exists(select 1 from public.learning_materials where id=p_material_id and status='active') then raise exception 'Material unavailable'; end if;
  insert into public.material_completions(user_id,material_id) values(auth.uid(),p_material_id) on conflict(user_id,material_id) do update set completed_at=now();
end $$;
revoke all on function public.mark_material_complete(uuid) from public; grant execute on function public.mark_material_complete(uuid) to authenticated;

create or replace function public.save_answer(p_attempt_question_id uuid,p_selected_option char(1),p_is_flagged boolean default false) returns void language plpgsql security definer set search_path=public as $$
declare v_attempt public.attempts%rowtype;
begin
  select a.* into v_attempt from public.attempts a join public.attempt_questions aq on aq.attempt_id=a.id where aq.id=p_attempt_question_id and a.user_id=auth.uid() for update;
  if not found then raise exception 'Attempt not found'; end if;
  if v_attempt.status<>'in_progress' or now()>v_attempt.expires_at then raise exception 'Attempt is no longer active'; end if;
  if p_selected_option is not null and p_selected_option not in ('A','B','C','D','E') then raise exception 'Invalid option'; end if;
  update public.attempt_questions set selected_option=p_selected_option,is_flagged=coalesce(p_is_flagged,false),answered_at=case when p_selected_option is null then answered_at else now() end where id=p_attempt_question_id;
end $$;
revoke all on function public.save_answer(uuid,char,boolean) from public; grant execute on function public.save_answer(uuid,char,boolean) to authenticated;

-- Student-safe reporting views. Every view is explicitly scoped to auth.uid().
create or replace view public.attempt_history with (security_barrier=true) as
select a.id,a.type,a.status,a.total_questions,a.correct_count,a.wrong_count,a.score,a.duration_seconds,a.started_at,a.completed_at,
  case when a.type='practice' then coalesce(t.name,'Latihan') when a.type='mini_tryout' then coalesce(mt.name,'Mini Tryout') else coalesce(tr.name,'Tryout') end display_name
from public.attempts a left join public.topics t on t.id=a.topic_id left join public.mini_tryouts mt on mt.id=a.mini_tryout_id left join public.tryouts tr on tr.id=a.tryout_id
where a.user_id=auth.uid() and a.status='completed' order by a.completed_at desc;
create or replace view public.student_mastery with (security_barrier=true) as
select aq.topic_id,t.name topic_name,count(*) total_answered,count(*) filter(where aq.is_correct) correct_count,
  round(100.0*count(*) filter(where aq.is_correct)/nullif(count(*),0),1) mastery_score
from public.attempt_questions aq join public.attempts a on a.id=aq.attempt_id join public.topics t on t.id=aq.topic_id
where a.user_id=auth.uid() and a.status='completed' group by aq.topic_id,t.name;
create or replace view public.student_dashboard_summary with (security_barrier=true) as
select count(*) filter(where type='practice') practice_count,count(*) filter(where type='mini_tryout') mini_count,count(*) filter(where type='tryout') tryout_count,
  coalesce(round(avg(score),1),0) average_score,coalesce(sum(total_questions),0) questions_answered,
  count(distinct completed_at::date) filter(where completed_at>=now()-interval '7 days') study_streak
from public.attempts where user_id=auth.uid() and status='completed';

-- Admin-only reporting views.
create or replace view public.admin_dashboard_summary with (security_barrier=true) as
select (select count(*) from public.profiles where role='student' and status='active' and public.is_staff()) student_count,
 (select count(distinct user_id) from public.attempts where started_at>=now()-interval '7 days' and public.is_staff()) active_students,
 (select count(*) from public.attempts where status='completed' and public.is_staff()) completed_attempts,
 (select coalesce(round(avg(score),1),0) from public.attempts where status='completed' and public.is_staff()) average_score,
 (select count(*) from public.questions where status='active' and public.is_staff()) active_questions;
create or replace view public.admin_topic_analysis with (security_barrier=true) as
select t.id topic_id,t.name topic_name,count(*) total_answers,round(100.0*count(*) filter(where aq.is_correct)/nullif(count(*),0),1) accuracy
from public.attempt_questions aq join public.attempts a on a.id=aq.attempt_id join public.topics t on t.id=aq.topic_id
where a.status='completed' and public.is_staff() group by t.id,t.name;
create or replace view public.admin_recent_activity with (security_barrier=true) as
select a.id,p.full_name student_name,a.score,a.completed_at,
 case when a.type='practice' then coalesce(t.name,'Latihan') when a.type='mini_tryout' then coalesce(mt.name,'Mini Tryout') else coalesce(tr.name,'Tryout') end display_name
from public.attempts a join public.profiles p on p.id=a.user_id left join public.topics t on t.id=a.topic_id left join public.mini_tryouts mt on mt.id=a.mini_tryout_id left join public.tryouts tr on tr.id=a.tryout_id
where a.status='completed' and public.is_staff() order by a.completed_at desc;
create or replace view public.admin_student_analysis with (security_barrier=true) as
select p.id,p.username,p.full_name student_name,c.name class_name,count(a.id) filter(where a.status='completed') attempt_count,
 coalesce(sum(a.total_questions) filter(where a.status='completed'),0) questions_answered,coalesce(round(avg(a.score) filter(where a.status='completed'),1),0) average_score,max(a.completed_at) last_activity
from public.profiles p left join public.classes c on c.id=p.class_id left join public.attempts a on a.user_id=p.id
where p.role='student' and public.is_staff() group by p.id,p.username,p.full_name,c.name;
create or replace view public.question_stats with (security_barrier=true) as
select q.id question_id,count(aq.id) filter(where a.status='completed') total_attempts,
 coalesce(round(100.0*count(aq.id) filter(where a.status='completed' and aq.is_correct)/nullif(count(aq.id) filter(where a.status='completed'),0),1),0) accuracy
from public.questions q left join public.attempt_questions aq on aq.question_id=q.id left join public.attempts a on a.id=aq.attempt_id
where public.is_staff() group by q.id;

grant usage on schema public to authenticated;
grant select on public.classes,public.profiles,public.subjects,public.topics,public.subtopics,public.learning_materials,public.mini_tryouts,public.tryouts,public.attempts to authenticated;
grant update on public.profiles to authenticated;
grant select,insert,update,delete on public.classes,public.subjects,public.topics,public.subtopics,public.learning_materials,public.questions,public.mini_tryouts,public.mini_tryout_blueprints,public.tryouts,public.tryout_blueprints to authenticated;
grant select on public.attempt_history,public.student_mastery,public.student_dashboard_summary,public.admin_dashboard_summary,public.admin_topic_analysis,public.admin_recent_activity,public.admin_student_analysis,public.question_stats to authenticated;
revoke all on public.attempt_questions from anon,authenticated;
revoke all on public.questions from anon;

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values('question-images','question-images',true,5242880,array['image/png','image/jpeg','image/webp','image/svg+xml']) on conflict(id) do nothing;
create policy "public question images" on storage.objects for select using(bucket_id='question-images');
create policy "staff upload question images" on storage.objects for insert to authenticated with check(bucket_id='question-images' and public.is_staff());
create policy "staff manage question images" on storage.objects for update to authenticated using(bucket_id='question-images' and public.is_staff()) with check(bucket_id='question-images' and public.is_staff());
create policy "staff delete question images" on storage.objects for delete to authenticated using(bucket_id='question-images' and public.is_staff());
