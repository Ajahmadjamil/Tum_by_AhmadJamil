-- Editors can drag poems into a custom sequence. Popular has its own order.

alter table public.poetry
  add column if not exists popular_sort integer;

comment on column public.poetry.popular_sort is
  'Display order inside Popular / mashoor. Null when not starred.';

create index if not exists poetry_popular_sort_idx
  on public.poetry (popular_sort)
  where is_popular and deleted_at is null;

update public.poetry p
set popular_sort = ranked.ord
from (
  select id, row_number() over (order by sort_order, created_at) as ord
  from public.poetry
  where is_popular
    and deleted_at is null
) ranked
where p.id = ranked.id
  and p.popular_sort is null;

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
  (public.poetry_body_lines(p.body))[2] as teaser_line_2,
  p.is_popular,
  p.popular_sort
from public.poetry p
join public.categories c on c.id = p.category_id
join public.poets po on po.id = p.poet_id
left join public.books b on b.id = p.book_id
where p.is_published
  and p.deleted_at is null
  and po.is_published
  and (b.id is null or b.is_published);

grant select on public.poetry_catalog to anon, authenticated;

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
  v_sort integer;
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

  if coalesce(p_is_popular, false) then
    select coalesce(max(p.popular_sort), 0) + 1
    into v_sort
    from public.poetry p
    where p.is_popular
      and p.deleted_at is null;

    update public.poetry
    set
      is_popular = true,
      popular_sort = coalesce(popular_sort, v_sort)
    where id = p_poetry_id
      and deleted_at is null;
  else
    update public.poetry
    set
      is_popular = false,
      popular_sort = null
    where id = p_poetry_id
      and deleted_at is null;
  end if;
end;
$$;

create or replace function public.reorder_poetry_posts(p_poetry_ids uuid[])
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid;
  v_poet_id uuid;
  v_i integer;
begin
  if p_poetry_ids is null or coalesce(array_length(p_poetry_ids, 1), 0) = 0 then
    raise exception 'ids required';
  end if;

  for v_i in 1 .. array_length(p_poetry_ids, 1) loop
    v_id := p_poetry_ids[v_i];
    select p.poet_id into v_poet_id
    from public.poetry p
    where p.id = v_id
      and p.deleted_at is null;

    if v_poet_id is null then
      raise exception 'poetry not found';
    end if;

    if not public.viewer_can_edit_poet(v_poet_id) then
      raise exception 'not allowed';
    end if;
  end loop;

  update public.poetry p
  set sort_order = u.ord::integer
  from unnest(p_poetry_ids) with ordinality as u(id, ord)
  where p.id = u.id
    and p.deleted_at is null;
end;
$$;

create or replace function public.reorder_popular_posts(p_poetry_ids uuid[])
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid;
  v_poet_id uuid;
  v_i integer;
begin
  if p_poetry_ids is null or coalesce(array_length(p_poetry_ids, 1), 0) = 0 then
    raise exception 'ids required';
  end if;

  for v_i in 1 .. array_length(p_poetry_ids, 1) loop
    v_id := p_poetry_ids[v_i];
    select p.poet_id into v_poet_id
    from public.poetry p
    where p.id = v_id
      and p.deleted_at is null
      and p.is_popular;

    if v_poet_id is null then
      raise exception 'poetry not found';
    end if;

    if not public.viewer_can_edit_poet(v_poet_id) then
      raise exception 'not allowed';
    end if;
  end loop;

  update public.poetry p
  set popular_sort = u.ord::integer
  from unnest(p_poetry_ids) with ordinality as u(id, ord)
  where p.id = u.id
    and p.is_popular
    and p.deleted_at is null;
end;
$$;

revoke execute on function public.reorder_poetry_posts(uuid[]) from public, anon;
grant execute on function public.reorder_poetry_posts(uuid[]) to authenticated;

revoke execute on function public.reorder_popular_posts(uuid[]) from public, anon;
grant execute on function public.reorder_popular_posts(uuid[]) to authenticated;

notify pgrst, 'reload schema';
