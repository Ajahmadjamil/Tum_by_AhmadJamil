-- Reorder must not violate poetry_book_sort_uidx (book_id, sort_order).
-- 1. Unique only among live rows so trash does not block a slot.
-- 2. Permute existing sort_order values instead of assigning 1..n.
-- 3. Park on negative numbers first so the unique index never sees a swap clash.

drop index if exists public.poetry_book_sort_uidx;
create unique index poetry_book_sort_uidx
  on public.poetry (book_id, sort_order)
  where deleted_at is null;

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

  with src as (
    select
      u.id,
      p.book_id,
      p.sort_order as old_sort,
      u.ord::integer as list_pos
    from unnest(p_poetry_ids) with ordinality as u(id, ord)
    join public.poetry p
      on p.id = u.id
     and p.deleted_at is null
  ),
  ranked as (
    select
      id,
      book_id,
      old_sort,
      row_number() over (partition by book_id order by list_pos) as new_pos
    from src
  ),
  slots as (
    select
      book_id,
      old_sort,
      row_number() over (partition by book_id order by old_sort, id) as slot_pos
    from src
  ),
  plan as (
    select
      r.id,
      s.old_sort as new_sort,
      -2000000000 + r.new_pos::integer as park_sort
    from ranked r
    join slots s
      on s.book_id is not distinct from r.book_id
     and s.slot_pos = r.new_pos
  ),
  parked as (
    update public.poetry p
    set sort_order = plan.park_sort
    from plan
    where p.id = plan.id
      and p.deleted_at is null
    returning p.id
  )
  update public.poetry p
  set sort_order = plan.new_sort
  from plan
  join parked on parked.id = plan.id
  where p.id = plan.id
    and p.deleted_at is null;
end;
$$;
