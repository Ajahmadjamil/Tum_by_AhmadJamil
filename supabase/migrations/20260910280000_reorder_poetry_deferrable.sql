-- Parking left every live Tum poem on negative sort_order values, so the next
-- drag collided on -1999999999. Stop parking. Repair numbers, then enforce
-- uniqueness at transaction end so a swap cannot hit a duplicate mid-update.

drop index if exists public.poetry_book_sort_uidx;
alter table public.poetry drop constraint if exists poetry_book_sort_uidx;

update public.poetry p
set sort_order = ranked.n
from (
  select
    id,
    row_number() over (
      partition by book_id
      order by sort_order, created_at, id
    ) as n
  from public.poetry
) ranked
where p.id = ranked.id
  and p.sort_order is distinct from ranked.n;

alter table public.poetry
  add constraint poetry_book_sort_uidx
  unique (book_id, sort_order)
  deferrable initially deferred;

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
  set sort_order = plan.new_sort
  from (
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
        row_number() over (partition by book_id order by list_pos) as new_pos
      from src
    ),
    slots as (
      select
        book_id,
        old_sort,
        row_number() over (partition by book_id order by old_sort, id) as slot_pos
      from src
    )
    select
      r.id,
      s.old_sort as new_sort
    from ranked r
    join slots s
      on s.book_id is not distinct from r.book_id
     and s.slot_pos = r.new_pos
  ) plan
  where p.id = plan.id
    and p.deleted_at is null;
end;
$$;
