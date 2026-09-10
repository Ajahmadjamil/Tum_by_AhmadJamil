-- Editor flags live on profiles. Grant/revoke them in the Supabase Table Editor;
-- the app only reads them.
--
-- Superadmin: is_superadmin = true  (edits every poet, book, and poem)
-- Poet editor: can_edit = true AND poet_id = that poet  (edits only their work)

alter table public.profiles
  add column if not exists is_superadmin boolean not null default false,
  add column if not exists can_edit boolean not null default false,
  add column if not exists poet_id uuid references public.poets(id) on delete set null;

comment on column public.profiles.is_superadmin is
  'Dashboard-only. true = can edit all poets, books, and poetry.';
comment on column public.profiles.can_edit is
  'Dashboard-only. true = can edit the attached poet''s books and poetry.';
comment on column public.profiles.poet_id is
  'Poet this user is attached to. Required for non-superadmin editors.';

create index if not exists profiles_poet_id_idx on public.profiles (poet_id);

-- Clients may update their name/photo, never their permission flags.
revoke update on table public.profiles from authenticated;
grant update (display_name, avatar_url) on table public.profiles to authenticated;
revoke insert on table public.profiles from authenticated;
grant insert (id, display_name, avatar_url) on table public.profiles to authenticated;

create or replace function public.protect_profile_permissions()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if coalesce(auth.role(), '') <> 'authenticated' then
    return new;
  end if;

  if tg_op = 'INSERT' then
    new.is_superadmin := false;
    new.can_edit := false;
    new.poet_id := null;
    return new;
  end if;

  new.is_superadmin := old.is_superadmin;
  new.can_edit := old.can_edit;
  new.poet_id := old.poet_id;
  return new;
end;
$$;

drop trigger if exists profiles_protect_permissions on public.profiles;
create trigger profiles_protect_permissions
  before insert or update on public.profiles
  for each row execute function public.protect_profile_permissions();

revoke execute on function public.protect_profile_permissions() from public, anon, authenticated;

-- Superadmin: ahmadjamil2.0000@gmail.com, attached to poet Ahmad Jamil (book Tum).
update public.profiles as p
set
  is_superadmin = true,
  can_edit = true,
  poet_id = poets.id
from auth.users u
join public.poets on poets.slug = 'ahmad-jamil'
where p.id = u.id
  and lower(u.email) = 'ahmadjamil2.0000@gmail.com';
