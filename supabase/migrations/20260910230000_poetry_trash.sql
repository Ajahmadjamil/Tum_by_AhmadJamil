-- Soft-delete poems into a trash bin. Clearing trash permanently deletes them.

alter table public.poetry
  add column if not exists deleted_at timestamptz;

comment on column public.poetry.deleted_at is
  'When set, the poem is in trash. Null means it is live. Permanent delete removes the row.';

create index if not exists poetry_deleted_at_idx
  on public.poetry (deleted_at)
  where deleted_at is not null;

create or replace view public.poetry_catalog
with (security_invoker = true) as
select
  p.id,
  p.slug,
  p.title_urdu,
  p.title_english,
  p.body,
  p.audio_url,
  p.sort_order,
  p.views_count,
  p.published_at,
  p.created_at,
  p.category_id,
  c.slug as category_slug,
  c.name_urdu as category_name_urdu,
  c.name_english as category_name_english,
  p.poet_id,
  po.slug as poet_slug,
  po.name_urdu as poet_name_urdu,
  po.name_english as poet_name_english,
  p.book_id,
  b.slug as book_slug,
  b.title_urdu as book_title_urdu,
  b.title_english as book_title_english,
  b.cover_image_url as book_cover_image_url,
  (public.poetry_body_lines(p.body))[1] as teaser_line_1,
  (public.poetry_body_lines(p.body))[2] as teaser_line_2
from public.poetry p
join public.categories c on c.id = p.category_id
join public.poets po on po.id = p.poet_id
left join public.books b on b.id = p.book_id
where p.is_published
  and p.deleted_at is null
  and po.is_published
  and (b.id is null or b.is_published);

create or replace view public.aaj_ka_shair
with (security_invoker = true) as
select
  q.id,
  q.display_date,
  p.id as poetry_id,
  p.slug as poetry_slug,
  p.title_urdu,
  p.body,
  (public.poetry_body_lines(p.body))[1] as teaser_line_1,
  (public.poetry_body_lines(p.body))[2] as teaser_line_2,
  po.name_urdu as poet_name_urdu,
  po.name_english as poet_name_english,
  b.title_urdu as book_title_urdu,
  b.title_english as book_title_english
from public.quote_of_the_day q
join public.poetry p on p.id = q.poetry_id
join public.poets po on po.id = p.poet_id
left join public.books b on b.id = p.book_id
where p.is_published
  and p.deleted_at is null
  and po.is_published
  and (b.id is null or b.is_published);

create or replace view public.featured_banner_feed
with (security_invoker = true) as
select
  fb.id,
  fb.title,
  fb.image_url,
  fb.sort_order,
  fb.poetry_id,
  p.slug as poetry_slug,
  p.title_urdu,
  p.body,
  (public.poetry_body_lines(p.body))[1] as teaser_line_1,
  (public.poetry_body_lines(p.body))[2] as teaser_line_2,
  po.name_urdu as poet_name_urdu,
  po.name_english as poet_name_english,
  b.title_urdu as book_title_urdu,
  b.title_english as book_title_english
from public.featured_banners fb
left join public.poetry p
  on p.id = fb.poetry_id
  and p.is_published
  and p.deleted_at is null
left join public.poets po on po.id = p.poet_id
left join public.books b on b.id = p.book_id
where fb.is_active;

create or replace view public.poetry_trash
with (security_invoker = true) as
select
  p.id,
  p.slug,
  p.title_urdu,
  p.title_english,
  p.body,
  p.audio_url,
  p.sort_order,
  p.views_count,
  p.published_at,
  p.created_at,
  p.deleted_at,
  p.category_id,
  c.slug as category_slug,
  c.name_urdu as category_name_urdu,
  c.name_english as category_name_english,
  p.poet_id,
  po.slug as poet_slug,
  po.name_urdu as poet_name_urdu,
  po.name_english as poet_name_english,
  p.book_id,
  b.slug as book_slug,
  b.title_urdu as book_title_urdu,
  b.title_english as book_title_english,
  b.cover_image_url as book_cover_image_url,
  (public.poetry_body_lines(p.body))[1] as teaser_line_1,
  (public.poetry_body_lines(p.body))[2] as teaser_line_2
from public.poetry p
join public.categories c on c.id = p.category_id
join public.poets po on po.id = p.poet_id
left join public.books b on b.id = p.book_id
where p.deleted_at is not null;

grant select on public.poetry_trash to authenticated;

drop policy if exists poetry_visible_read on public.poetry;
create policy poetry_visible_read
  on public.poetry for select
  using (
    is_published
    and deleted_at is null
    and public.viewer_can_see_poet(poet_id)
  );

drop policy if exists poetry_trash_read on public.poetry;
create policy poetry_trash_read
  on public.poetry for select
  to authenticated
  using (
    deleted_at is not null
    and public.viewer_can_edit_poet(poet_id)
  );

create or replace function public.update_poetry_post(
  p_poetry_id uuid,
  p_title_urdu text,
  p_body text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_poet_id uuid;
  v_title text;
  v_body text;
begin
  v_title := trim(coalesce(p_title_urdu, ''));
  v_body := trim(coalesce(p_body, ''));

  if v_title = '' then
    raise exception 'title required';
  end if;
  if v_body = '' then
    raise exception 'body required';
  end if;

  select p.poet_id into v_poet_id
  from public.poetry p
  where p.id = p_poetry_id
    and p.deleted_at is null;

  if v_poet_id is null then
    raise exception 'poetry not found';
  end if;

  if not public.viewer_can_edit_poet(v_poet_id) then
    raise exception 'not allowed';
  end if;

  update public.poetry
  set
    title_urdu = v_title,
    body = v_body
  where id = p_poetry_id
    and deleted_at is null;
end;
$$;

create or replace function public.trash_poetry_post(p_poetry_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_poet_id uuid;
begin
  select p.poet_id into v_poet_id
  from public.poetry p
  where p.id = p_poetry_id
    and p.deleted_at is null;

  if v_poet_id is null then
    raise exception 'poetry not found';
  end if;

  if not public.viewer_can_edit_poet(v_poet_id) then
    raise exception 'not allowed';
  end if;

  update public.poetry
  set deleted_at = now()
  where id = p_poetry_id
    and deleted_at is null;
end;
$$;

create or replace function public.restore_poetry_post(p_poetry_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_poet_id uuid;
begin
  select p.poet_id into v_poet_id
  from public.poetry p
  where p.id = p_poetry_id
    and p.deleted_at is not null;

  if v_poet_id is null then
    raise exception 'poetry not found';
  end if;

  if not public.viewer_can_edit_poet(v_poet_id) then
    raise exception 'not allowed';
  end if;

  update public.poetry
  set deleted_at = null
  where id = p_poetry_id
    and deleted_at is not null;
end;
$$;

create or replace function public.purge_poetry_post(p_poetry_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_poet_id uuid;
begin
  select p.poet_id into v_poet_id
  from public.poetry p
  where p.id = p_poetry_id
    and p.deleted_at is not null;

  if v_poet_id is null then
    raise exception 'poetry not found';
  end if;

  if not public.viewer_can_edit_poet(v_poet_id) then
    raise exception 'not allowed';
  end if;

  delete from public.poetry
  where id = p_poetry_id
    and deleted_at is not null;
end;
$$;

create or replace function public.empty_poetry_trash()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and (p.is_superadmin or p.can_edit)
  ) then
    raise exception 'not allowed';
  end if;

  delete from public.poetry p
  where p.deleted_at is not null
    and public.viewer_can_edit_poet(p.poet_id);
end;
$$;

revoke execute on function public.trash_poetry_post(uuid) from public, anon;
grant execute on function public.trash_poetry_post(uuid) to authenticated;

revoke execute on function public.restore_poetry_post(uuid) from public, anon;
grant execute on function public.restore_poetry_post(uuid) to authenticated;

revoke execute on function public.purge_poetry_post(uuid) from public, anon;
grant execute on function public.purge_poetry_post(uuid) to authenticated;

revoke execute on function public.empty_poetry_trash() from public, anon;
grant execute on function public.empty_poetry_trash() to authenticated;
