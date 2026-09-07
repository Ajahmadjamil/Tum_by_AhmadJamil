-- Urdu Poetry App schema
-- gen_random_uuid() comes from pgcrypto (already enabled on Supabase).

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Catalog tables
-- ---------------------------------------------------------------------------

create table public.poets (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name_urdu text not null,
  name_english text,
  bio_urdu text,
  bio_english text,
  avatar_url text,
  is_published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.poets is
  'Authors. Launch with one poet; add more rows later without schema changes.';

create table public.books (
  id uuid primary key default gen_random_uuid(),
  poet_id uuid not null references public.poets(id) on delete restrict,
  slug text not null unique,
  title_urdu text not null,
  title_english text,
  description_urdu text,
  description_english text,
  cover_image_url text,
  release_year integer,
  sort_order integer not null default 0,
  is_published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.books is
  'Poetry collections shown as library cards on Home (e.g. Tum).';

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name_urdu text not null,
  name_english text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  constraint categories_slug_format check (slug ~ '^[a-z0-9_]+$')
);

comment on table public.categories is
  'Poetic forms. "All" is a client-side filter, not a row.';

create table public.poetry (
  id uuid primary key default gen_random_uuid(),
  poet_id uuid not null references public.poets(id) on delete restrict,
  book_id uuid references public.books(id) on delete set null,
  category_id uuid not null references public.categories(id) on delete restrict,
  slug text not null unique,
  title_urdu text not null,
  title_english text,
  audio_url text,
  sort_order integer not null default 0,
  views_count integer not null default 0,
  is_published boolean not null default true,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint poetry_views_non_negative check (views_count >= 0)
);

comment on table public.poetry is
  'One ghazal, nazm, qataa, or standalone shair. Read in book order via sort_order.';

create table public.poetry_verses (
  id uuid primary key default gen_random_uuid(),
  poetry_id uuid not null references public.poetry(id) on delete cascade,
  sort_order integer not null,
  misra_1 text not null,
  misra_2 text,
  created_at timestamptz not null default now(),
  constraint poetry_verses_sort_positive check (sort_order > 0),
  constraint poetry_verses_unique_order unique (poetry_id, sort_order)
);

comment on table public.poetry_verses is
  'Stanzas/couplets. misra_1 + optional misra_2. Nazm lines can leave misra_2 null.';

create table public.featured_banners (
  id uuid primary key default gen_random_uuid(),
  poetry_id uuid references public.poetry(id) on delete set null,
  verse_id uuid references public.poetry_verses(id) on delete set null,
  title text,
  image_url text,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  constraint featured_banners_has_content
    check (poetry_id is not null or verse_id is not null or image_url is not null)
);

comment on table public.featured_banners is
  'Home carousel. Prefer verse_id so the banner can show a couplet snippet.';

create table public.quote_of_the_day (
  id uuid primary key default gen_random_uuid(),
  verse_id uuid not null references public.poetry_verses(id) on delete cascade,
  display_date date not null unique,
  created_at timestamptz not null default now()
);

comment on table public.quote_of_the_day is
  'Aaj Ka Shair. Points at a verse (couplet), not a whole ghazal.';

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.profiles is
  'App-facing user row for the Profile tab. Synced from auth.users.';

create table public.user_favorites (
  user_id uuid not null references auth.users(id) on delete cascade,
  poetry_id uuid not null references public.poetry(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, poetry_id)
);

comment on table public.user_favorites is
  'Bookmarks. Composite PK blocks duplicate hearts without a surrogate id.';

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

create index poets_published_idx on public.poets (is_published) where is_published;

create index books_poet_id_idx on public.books (poet_id);
create index books_published_sort_idx
  on public.books (sort_order, created_at)
  where is_published;

create index poetry_poet_id_idx on public.poetry (poet_id);
create index poetry_book_id_idx on public.poetry (book_id);
create index poetry_category_id_idx on public.poetry (category_id);
create unique index poetry_book_sort_uidx
  on public.poetry (book_id, sort_order)
  where book_id is not null;
create index poetry_published_idx
  on public.poetry (category_id, created_at desc)
  where is_published;

create index poetry_verses_poetry_id_idx on public.poetry_verses (poetry_id, sort_order);

create index featured_banners_active_idx
  on public.featured_banners (sort_order)
  where is_active;

create index quote_of_the_day_verse_id_idx on public.quote_of_the_day (verse_id);

create index user_favorites_poetry_id_idx on public.user_favorites (poetry_id);

-- ---------------------------------------------------------------------------
-- updated_at triggers
-- ---------------------------------------------------------------------------

create trigger poets_set_updated_at
  before update on public.poets
  for each row execute function public.set_updated_at();

create trigger books_set_updated_at
  before update on public.books
  for each row execute function public.set_updated_at();

create trigger poetry_set_updated_at
  before update on public.poetry
  for each row execute function public.set_updated_at();

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Auth → profiles
-- ---------------------------------------------------------------------------

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name, avatar_url)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data ->> 'full_name',
      new.raw_user_meta_data ->> 'name',
      split_part(new.email, '@', 1)
    ),
    new.raw_user_meta_data ->> 'avatar_url'
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Read models for Home / Reader (RLS of base tables still applies)
-- ---------------------------------------------------------------------------

create view public.poetry_catalog
with (security_invoker = true) as
select
  p.id,
  p.slug,
  p.title_urdu,
  p.title_english,
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
  v.misra_1 as teaser_misra_1,
  v.misra_2 as teaser_misra_2
from public.poetry p
join public.categories c on c.id = p.category_id
join public.poets po on po.id = p.poet_id
left join public.books b on b.id = p.book_id
left join lateral (
  select pv.misra_1, pv.misra_2
  from public.poetry_verses pv
  where pv.poetry_id = p.id
  order by pv.sort_order
  limit 1
) v on true
where p.is_published
  and po.is_published
  and (b.id is null or b.is_published);

comment on view public.poetry_catalog is
  'Published poems with poet/book/category and first-verse teaser for lists.';

create view public.aaj_ka_shair
with (security_invoker = true) as
select
  q.id,
  q.display_date,
  pv.id as verse_id,
  pv.misra_1,
  pv.misra_2,
  p.id as poetry_id,
  p.slug as poetry_slug,
  p.title_urdu,
  po.name_urdu as poet_name_urdu,
  po.name_english as poet_name_english,
  b.title_urdu as book_title_urdu,
  b.title_english as book_title_english
from public.quote_of_the_day q
join public.poetry_verses pv on pv.id = q.verse_id
join public.poetry p on p.id = pv.poetry_id
join public.poets po on po.id = p.poet_id
left join public.books b on b.id = p.book_id
where p.is_published
  and po.is_published
  and (b.id is null or b.is_published);

comment on view public.aaj_ka_shair is
  'Scheduled daily couplets with poet/book names for the Home banner.';

create view public.featured_banner_feed
with (security_invoker = true) as
select
  fb.id,
  fb.title,
  fb.image_url,
  fb.sort_order,
  fb.poetry_id,
  fb.verse_id,
  coalesce(pv.misra_1, teaser.misra_1) as misra_1,
  coalesce(pv.misra_2, teaser.misra_2) as misra_2,
  p.slug as poetry_slug,
  p.title_urdu,
  po.name_urdu as poet_name_urdu
from public.featured_banners fb
left join public.poetry p on p.id = fb.poetry_id and p.is_published
left join public.poets po on po.id = p.poet_id
left join public.poetry_verses pv on pv.id = fb.verse_id
left join lateral (
  select v.misra_1, v.misra_2
  from public.poetry_verses v
  where v.poetry_id = p.id
  order by v.sort_order
  limit 1
) teaser on fb.verse_id is null
where fb.is_active;

comment on view public.featured_banner_feed is
  'Active Home carousel rows with couplet text resolved from verse or first stanza.';

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

alter table public.poets enable row level security;
alter table public.books enable row level security;
alter table public.categories enable row level security;
alter table public.poetry enable row level security;
alter table public.poetry_verses enable row level security;
alter table public.featured_banners enable row level security;
alter table public.quote_of_the_day enable row level security;
alter table public.profiles enable row level security;
alter table public.user_favorites enable row level security;

create policy poets_public_read
  on public.poets for select
  using (is_published);

create policy books_public_read
  on public.books for select
  using (is_published);

create policy categories_public_read
  on public.categories for select
  using (true);

create policy poetry_public_read
  on public.poetry for select
  using (is_published);

create policy poetry_verses_public_read
  on public.poetry_verses for select
  using (
    exists (
      select 1
      from public.poetry p
      where p.id = poetry_verses.poetry_id
        and p.is_published
    )
  );

create policy featured_banners_public_read
  on public.featured_banners for select
  using (is_active);

create policy quote_of_the_day_public_read
  on public.quote_of_the_day for select
  using (true);

create policy profiles_select_own
  on public.profiles for select
  to authenticated
  using (auth.uid() = id);

create policy profiles_update_own
  on public.profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy user_favorites_select_own
  on public.user_favorites for select
  to authenticated
  using (auth.uid() = user_id);

create policy user_favorites_insert_own
  on public.user_favorites for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy user_favorites_delete_own
  on public.user_favorites for delete
  to authenticated
  using (auth.uid() = user_id);

-- Catalog writes stay in the Dashboard / service role. No insert/update
-- policies on content tables for anon or authenticated.

grant select on public.poets to anon, authenticated;
grant select on public.books to anon, authenticated;
grant select on public.categories to anon, authenticated;
grant select on public.poetry to anon, authenticated;
grant select on public.poetry_verses to anon, authenticated;
grant select on public.featured_banners to anon, authenticated;
grant select on public.quote_of_the_day to anon, authenticated;
grant select on public.poetry_catalog to anon, authenticated;
grant select on public.aaj_ka_shair to anon, authenticated;
grant select on public.featured_banner_feed to anon, authenticated;

grant select, update on public.profiles to authenticated;
grant select, insert, delete on public.user_favorites to authenticated;
