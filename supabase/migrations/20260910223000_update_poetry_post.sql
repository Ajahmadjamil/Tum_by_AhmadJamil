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
  where p.id = p_poetry_id;

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
  where id = p_poetry_id;
end;
$$;

revoke execute on function public.update_poetry_post(uuid, text, text)
  from public, anon;
grant execute on function public.update_poetry_post(uuid, text, text)
  to authenticated;
