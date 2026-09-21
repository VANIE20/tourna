-- TOURNA-owned team identity. All membership mutations are atomic RPCs.
create extension if not exists pgcrypto with schema extensions;

create table public.tourna_teams (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  captain_id uuid not null references public.tourna_profiles(id) on delete cascade,
  join_code text not null default upper(substr(encode(extensions.gen_random_bytes(8), 'hex'), 1, 10)),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint tourna_teams_name_length check (
    char_length(btrim(name)) between 2 and 40
  ),
  constraint tourna_teams_join_code_format check (
    join_code ~ '^[A-F0-9]{10}$'
  )
);

create unique index tourna_teams_join_code_unique
  on public.tourna_teams (join_code);
create index tourna_teams_captain_id_idx
  on public.tourna_teams (captain_id);

create table public.tourna_team_members (
  team_id uuid not null references public.tourna_teams(id) on delete cascade,
  user_id uuid not null references public.tourna_profiles(id) on delete cascade,
  member_role text not null default 'player',
  joined_at timestamptz not null default now(),
  primary key (team_id, user_id),
  constraint tourna_team_members_one_team unique (user_id),
  constraint tourna_team_members_role check (
    member_role in ('captain', 'player')
  )
);

create index tourna_team_members_team_id_idx
  on public.tourna_team_members (team_id);

create trigger tourna_teams_set_updated_at
before update on public.tourna_teams
for each row execute function public.tourna_set_updated_at();

alter table public.tourna_teams enable row level security;
alter table public.tourna_team_members enable row level security;

create or replace function public.tourna_current_team_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select team_id
  from public.tourna_team_members
  where user_id = auth.uid()
  limit 1;
$$;

create policy "Members can read their team"
on public.tourna_teams for select
to authenticated
using (id = (select public.tourna_current_team_id()));

create policy "Members can read their roster"
on public.tourna_team_members for select
to authenticated
using (team_id = (select public.tourna_current_team_id()));

create or replace function public.tourna_create_team(p_name text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  new_team_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  if not exists (
    select 1 from public.tourna_profiles where id = auth.uid()
  ) then
    raise exception 'Create a player profile first' using errcode = 'P0001';
  end if;
  if exists (
    select 1 from public.tourna_team_members where user_id = auth.uid()
  ) then
    raise exception 'Player already belongs to a team' using errcode = 'P0001';
  end if;

  insert into public.tourna_teams (name, captain_id)
  values (btrim(p_name), auth.uid())
  returning id into new_team_id;

  insert into public.tourna_team_members (team_id, user_id, member_role)
  values (new_team_id, auth.uid(), 'captain');

  return new_team_id;
end;
$$;

create or replace function public.tourna_join_team(p_join_code text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  target_team_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  if not exists (
    select 1 from public.tourna_profiles where id = auth.uid()
  ) then
    raise exception 'Create a player profile first' using errcode = 'P0001';
  end if;
  if exists (
    select 1 from public.tourna_team_members where user_id = auth.uid()
  ) then
    raise exception 'Player already belongs to a team' using errcode = 'P0001';
  end if;

  select id into target_team_id
  from public.tourna_teams
  where join_code = upper(btrim(p_join_code));

  if target_team_id is null then
    raise exception 'Invalid team invite code' using errcode = 'P0001';
  end if;

  insert into public.tourna_team_members (team_id, user_id)
  values (target_team_id, auth.uid());

  return target_team_id;
end;
$$;

create or replace function public.tourna_leave_team()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  membership public.tourna_team_members%rowtype;
  roster_size integer;
begin
  select * into membership
  from public.tourna_team_members
  where user_id = auth.uid();

  if membership.user_id is null then
    raise exception 'Player does not belong to a team' using errcode = 'P0001';
  end if;

  if membership.member_role = 'captain' then
    select count(*) into roster_size
    from public.tourna_team_members
    where team_id = membership.team_id;

    if roster_size > 1 then
      raise exception 'Captain cannot leave while other members remain'
        using errcode = 'P0001';
    end if;

    delete from public.tourna_teams where id = membership.team_id;
  else
    delete from public.tourna_team_members
    where team_id = membership.team_id and user_id = auth.uid();
  end if;
end;
$$;

revoke all on table public.tourna_teams from anon, authenticated;
revoke all on table public.tourna_team_members from anon, authenticated;
grant select on table public.tourna_teams to authenticated;
grant select on table public.tourna_team_members to authenticated;

revoke execute on function public.tourna_current_team_id() from public;
revoke execute on function public.tourna_create_team(text) from public;
revoke execute on function public.tourna_join_team(text) from public;
revoke execute on function public.tourna_leave_team() from public;
grant execute on function public.tourna_create_team(text) to authenticated;
grant execute on function public.tourna_join_team(text) to authenticated;
grant execute on function public.tourna_leave_team() to authenticated;
grant execute on function public.tourna_current_team_id() to authenticated;
