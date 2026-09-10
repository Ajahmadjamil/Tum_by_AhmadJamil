-- Sync Google name/photo without granting table UPDATE to authenticated.
-- PostgREST cannot use column-only grants; this RPC runs as the function owner.

create or replace function public.sync_own_profile(
  p_display_name text default null,
  p_avatar_url text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_name text;
  v_avatar text;
begin
  if auth.uid() is null then
    raise exception 'not allowed';
  end if;

  v_name := nullif(trim(coalesce(p_display_name, '')), '');
  v_avatar := nullif(trim(coalesce(p_avatar_url, '')), '');

  update public.profiles
  set
    display_name = coalesce(v_name, display_name),
    avatar_url = coalesce(v_avatar, avatar_url)
  where id = auth.uid();

  if not found then
    insert into public.profiles (id, display_name, avatar_url)
    values (auth.uid(), v_name, v_avatar);
  end if;
end;
$$;

revoke execute on function public.sync_own_profile(text, text) from public, anon;
grant execute on function public.sync_own_profile(text, text) to authenticated;

notify pgrst, 'reload schema';
