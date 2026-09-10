-- Editors star poems into a virtual Popular (مشہور) collection.
-- Poems keep their real form category; starring does not move them.

alter table public.poetry
  add column if not exists is_popular boolean not null default false;

comment on column public.poetry.is_popular is
  'When true, the poem appears in the Popular / mashoor collection on home.';

create index if not exists poetry_is_popular_idx
  on public.poetry (is_popular)
  where is_popular and deleted_at is null;

drop view if exists public.poetry_catalog;
create view public.poetry_catalog
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
  (public.poetry_body_lines(p.body))[2] as teaser_line_2,
  p.is_popular
from public.poetry p
join public.categories c on c.id = p.category_id
join public.poets po on po.id = p.poet_id
left join public.books b on b.id = p.book_id
where p.is_published
  and p.deleted_at is null
  and po.is_published
  and (b.id is null or b.is_published);

grant select on public.poetry_catalog to anon, authenticated;

drop view if exists public.poetry_trash;
create view public.poetry_trash
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
  (public.poetry_body_lines(p.body))[2] as teaser_line_2,
  p.is_popular
from public.poetry p
join public.categories c on c.id = p.category_id
join public.poets po on po.id = p.poet_id
left join public.books b on b.id = p.book_id
where p.deleted_at is not null;

grant select on public.poetry_trash to authenticated;

create or replace function public.set_poetry_popular(
  p_poetry_id uuid,
  p_is_popular boolean
)
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
  set is_popular = coalesce(p_is_popular, false)
  where id = p_poetry_id
    and deleted_at is null;
end;
$$;

revoke execute on function public.set_poetry_popular(uuid, boolean) from public, anon;
grant execute on function public.set_poetry_popular(uuid, boolean) to authenticated;

notify pgrst, 'reload schema';
