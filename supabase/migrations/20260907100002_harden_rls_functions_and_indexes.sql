create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

revoke execute on function public.handle_new_user() from public, anon, authenticated;
revoke execute on function public.set_updated_at() from public, anon, authenticated;

create index if not exists featured_banners_poetry_id_idx
  on public.featured_banners (poetry_id);
create index if not exists featured_banners_verse_id_idx
  on public.featured_banners (verse_id);

drop policy if exists profiles_select_own on public.profiles;
drop policy if exists profiles_update_own on public.profiles;
drop policy if exists user_favorites_select_own on public.user_favorites;
drop policy if exists user_favorites_insert_own on public.user_favorites;
drop policy if exists user_favorites_delete_own on public.user_favorites;

create policy profiles_select_own
  on public.profiles for select
  to authenticated
  using ((select auth.uid()) = id);

create policy profiles_update_own
  on public.profiles for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

create policy user_favorites_select_own
  on public.user_favorites for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy user_favorites_insert_own
  on public.user_favorites for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy user_favorites_delete_own
  on public.user_favorites for delete
  to authenticated
  using ((select auth.uid()) = user_id);
