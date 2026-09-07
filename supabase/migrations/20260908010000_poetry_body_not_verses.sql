-- Store each poem as the Excel body. Do not split ghazals into misra rows.

alter table public.poetry
  add column if not exists body text;

comment on column public.poetry.body is
  'Full poem text exactly as written (line breaks preserved).';

drop view if exists public.aaj_ka_shair;
drop view if exists public.featured_banner_feed;
drop view if exists public.poetry_catalog;

drop index if exists public.quote_of_the_day_verse_id_idx;
drop index if exists public.featured_banners_verse_id_idx;

alter table public.quote_of_the_day
  drop column if exists verse_id;

alter table public.quote_of_the_day
  add column if not exists poetry_id uuid references public.poetry(id) on delete cascade;

alter table public.featured_banners
  drop column if exists verse_id;

alter table public.featured_banners
  drop constraint if exists featured_banners_has_content;

alter table public.featured_banners
  add constraint featured_banners_has_content
  check (poetry_id is not null or image_url is not null);

delete from public.poetry_verses;

create or replace function public.poetry_body_lines(body text)
returns text[]
language sql
immutable
as $$
  select coalesce(
    array(
      select trim(line)
      from unnest(regexp_split_to_array(coalesce(body, ''), E'\r?\n')) as line
      where trim(line) <> ''
    ),
    '{}'::text[]
  );
$$;

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
  (public.poetry_body_lines(p.body))[2] as teaser_line_2
from public.poetry p
join public.categories c on c.id = p.category_id
join public.poets po on po.id = p.poet_id
left join public.books b on b.id = p.book_id
where p.is_published
  and po.is_published
  and (b.id is null or b.is_published);

comment on view public.poetry_catalog is
  'Published poems with full body and first two lines as list teasers.';

create view public.aaj_ka_shair
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
  and po.is_published
  and (b.id is null or b.is_published);

comment on view public.aaj_ka_shair is
  'Scheduled daily poem, shown from the stored body.';

create view public.featured_banner_feed
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
  po.name_urdu as poet_name_urdu
from public.featured_banners fb
left join public.poetry p on p.id = fb.poetry_id and p.is_published
left join public.poets po on po.id = p.poet_id
where fb.is_active;

comment on view public.featured_banner_feed is
  'Active Home carousel rows with teaser lines from the poem body.';

grant select on public.poetry_catalog to anon, authenticated;
grant select on public.aaj_ka_shair to anon, authenticated;
grant select on public.featured_banner_feed to anon, authenticated;
grant execute on function public.poetry_body_lines(text) to anon, authenticated;
