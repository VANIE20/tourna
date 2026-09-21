-- TOURNA-owned player identity. This migration does not alter tournament tables.
create table public.tourna_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null,
  display_name text not null,
  role text not null default 'player',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint tourna_profiles_username_format check (
    username ~ '^[a-z0-9_]{3,24}$'
  ),
  constraint tourna_profiles_display_name_length check (
    char_length(btrim(display_name)) between 2 and 50
  ),
  constraint tourna_profiles_role check (
    role in ('guest', 'player', 'captain', 'organizer', 'admin')
  )
);

create unique index tourna_profiles_username_unique
  on public.tourna_profiles (lower(username));

create or replace function public.tourna_set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger tourna_profiles_set_updated_at
before update on public.tourna_profiles
for each row execute function public.tourna_set_updated_at();

alter table public.tourna_profiles enable row level security;

create policy "Authenticated players can read profiles"
on public.tourna_profiles for select
to authenticated
using (true);

create policy "Players can create their own profile"
on public.tourna_profiles for insert
to authenticated
with check (id = (select auth.uid()) and role = 'player');

create policy "Players can update their own profile"
on public.tourna_profiles for update
to authenticated
using (id = (select auth.uid()))
with check (id = (select auth.uid()));

revoke all on table public.tourna_profiles from anon, authenticated;
grant select on table public.tourna_profiles to authenticated;
grant insert (id, username, display_name) on table public.tourna_profiles
  to authenticated;
grant update (username, display_name) on table public.tourna_profiles
  to authenticated;

revoke execute on function public.tourna_set_updated_at() from public;
