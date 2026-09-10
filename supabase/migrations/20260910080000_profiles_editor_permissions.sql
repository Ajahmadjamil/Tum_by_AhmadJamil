-- Editor permissions live on profiles (dashboard-only). The app never assigns them.
--
-- is_superadmin  → edit every poet / book / poem
-- can_edit       → edit only the attached poet's books and poetry
-- poet_id        → which poet this user is attached to
--
-- Grant another poet-editor later with:
--   update public.profiles
--   set can_edit = true, poet_id = '<poet uuid>'
--   where id = '<user uuid>';

alter table public.profiles
  add column if not exists is_superadmin boolean not null default false,
  add column if not exists can_edit boolean not null default false,
  add column if not exists poet_id uuid references public.poets(id) on delete set null;

comment on column public.profiles.is_superadmin is
  'Dashboard-only. Superadmins can edit all catalog content.';
comment on column public.profiles.can_edit is
  'Dashboard-only. When true, this user may edit books/poetry of poet_id.';
comment on column public.profiles.poet_id is
  'Poet attached to this user. Books of this poet are theirs.';

create index if not exists profiles_poet_id_idx on public.profiles (poet_id);

-- App users may update their name/photo, never their own editor flags.
revoke insert on table public.profiles from authenticated;
revoke update on table public.profiles from authenticated;
grant insert (id, display_name, avatar_url) on table public.profiles to authenticated;
grant update (display_name, avatar_url) on table public.profiles to authenticated;

create or replace function public.profiles_lock_editor_fields()
returns trigger
language plpgsql
as $$
begin
  -- Dashboard / service role have no auth.uid(); they may set these columns.
  -- Signed-in app users cannot raise their own privileges.
  if auth.uid() is null then
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

drop trigger if exists profiles_lock_editor_fields on public.profiles;
create trigger profiles_lock_editor_fields
  before insert or update on public.profiles
  for each row execute function public.profiles_lock_editor_fields();

revoke execute on function public.profiles_lock_editor_fields() from public, anon, authenticated;

-- Attach Ahmad Jamil + Tum's poet to this account and make them superadmin.
update public.profiles p
set
  is_superadmin = true,
  can_edit = true,
  poet_id = po.id
from auth.users u
join public.poets po on po.slug = 'ahmad-jamil'
where p.id = u.id
  and lower(u.email) = 'ahmadjamil2.0000@gmail.com';
