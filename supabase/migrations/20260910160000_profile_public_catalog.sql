-- Dashboard-only switch: when true, this user's attached poet (books + poetry)
-- is visible to everyone, including signed-out visitors.
-- Default false. The app cannot change this column.

alter table public.profiles
  add column if not exists is_public boolean not null default false;

comment on column public.profiles.is_public is
  'Dashboard-only. true = this user''s books and poetry are visible to everyone (logged in or not).';

create index if not exists profiles_public_poet_idx
  on public.profiles (poet_id)
  where is_public;

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
    new.is_public := false;
    return new;
  end if;

  new.is_superadmin := old.is_superadmin;
  new.can_edit := old.can_edit;
  new.poet_id := old.poet_id;
  new.is_public := old.is_public;
  return new;
end;
$$;

-- Anyone can see a poet if a linked profile has is_public.
-- The owner and superadmins can still see it when is_public is false.
create or replace function public.viewer_can_see_poet(target_poet_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    exists (
      select 1
      from public.profiles p
      where p.poet_id = target_poet_id
        and p.is_public
    )
    or exists (
      select 1
      from public.profiles p
      where p.id = auth.uid()
        and (
          p.is_superadmin
          or p.poet_id = target_poet_id
        )
    ),
    false
  );
$$;

revoke execute on function public.viewer_can_see_poet(uuid) from public;
grant execute on function public.viewer_can_see_poet(uuid) to anon, authenticated;

drop policy if exists poets_public_read on public.poets;
create policy poets_visible_read
  on public.poets for select
  using (is_published and public.viewer_can_see_poet(id));

drop policy if exists books_public_read on public.books;
create policy books_visible_read
  on public.books for select
  using (is_published and public.viewer_can_see_poet(poet_id));

drop policy if exists poetry_public_read on public.poetry;
create policy poetry_visible_read
  on public.poetry for select
  using (is_published and public.viewer_can_see_poet(poet_id));

drop policy if exists poetry_verses_public_read on public.poetry_verses;
create policy poetry_verses_visible_read
  on public.poetry_verses for select
  using (
    exists (
      select 1
      from public.poetry p
      where p.id = poetry_verses.poetry_id
        and p.is_published
        and public.viewer_can_see_poet(p.poet_id)
    )
  );

drop policy if exists featured_banners_public_read on public.featured_banners;
create policy featured_banners_visible_read
  on public.featured_banners for select
  using (
    is_active
    and (
      poetry_id is null
      or exists (
        select 1
        from public.poetry p
        where p.id = featured_banners.poetry_id
      )
    )
  );

drop policy if exists quote_of_the_day_public_read on public.quote_of_the_day;
create policy quote_of_the_day_visible_read
  on public.quote_of_the_day for select
  using (
    exists (
      select 1
      from public.poetry p
      where p.id = quote_of_the_day.poetry_id
    )
  );
