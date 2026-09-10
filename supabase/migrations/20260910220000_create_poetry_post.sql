-- Editors publish poems through this function only. The app cannot
-- insert into poetry directly.

create or replace function public.viewer_can_edit_poet(target_poet_id uuid)
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
      where p.id = auth.uid()
        and (
          p.is_superadmin
          or (p.can_edit and p.poet_id = target_poet_id)
        )
    ),
    false
  );
$$;

revoke execute on function public.viewer_can_edit_poet(uuid) from public, anon;
grant execute on function public.viewer_can_edit_poet(uuid) to authenticated;

create or replace function public.create_poetry_post(
  p_category_id uuid,
  p_book_id uuid,
  p_title_urdu text,
  p_body text,
  p_title_english text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_poet_id uuid;
  v_sort integer;
  v_id uuid;
  v_slug text;
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

  select b.poet_id into v_poet_id
  from public.books b
  where b.id = p_book_id;

  if v_poet_id is null then
    raise exception 'book not found';
  end if;

  if not public.viewer_can_edit_poet(v_poet_id) then
    raise exception 'not allowed';
  end if;

  if not exists (
    select 1 from public.categories c where c.id = p_category_id
  ) then
    raise exception 'category not found';
  end if;

  perform pg_advisory_xact_lock(hashtext(p_book_id::text));

  select coalesce(max(p.sort_order), 0) + 1
  into v_sort
  from public.poetry p
  where p.book_id = p_book_id;

  v_id := gen_random_uuid();
  v_slug := 'p-' || replace(v_id::text, '-', '');

  insert into public.poetry (
    id,
    poet_id,
    book_id,
    category_id,
    slug,
    title_urdu,
    title_english,
    body,
    sort_order,
    is_published,
    published_at
  ) values (
    v_id,
    v_poet_id,
    p_book_id,
    p_category_id,
    v_slug,
    v_title,
    nullif(trim(coalesce(p_title_english, '')), ''),
    v_body,
    v_sort,
    true,
    now()
  );

  return v_id;
end;
$$;

revoke execute on function public.create_poetry_post(uuid, uuid, text, text, text)
  from public, anon;
grant execute on function public.create_poetry_post(uuid, uuid, text, text, text)
  to authenticated;
