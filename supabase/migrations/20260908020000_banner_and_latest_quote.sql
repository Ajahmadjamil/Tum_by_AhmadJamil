-- Home banner for book Tum / Ahmad Jamil, and آج کا شعر from the latest poem.

create or replace view public.featured_banner_feed
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
  po.name_urdu as poet_name_urdu,
  po.name_english as poet_name_english,
  b.title_urdu as book_title_urdu,
  b.title_english as book_title_english
from public.featured_banners fb
left join public.poetry p on p.id = fb.poetry_id and p.is_published
left join public.poets po on po.id = p.poet_id
left join public.books b on b.id = p.book_id
where fb.is_active;

grant select on public.featured_banner_feed to anon, authenticated;

insert into public.featured_banners (poetry_id, title, sort_order, is_active)
select p.id, 'تم', 1, true
from public.poetry p
join public.books b on b.id = p.book_id
where b.slug = 'tum'
  and not exists (select 1 from public.featured_banners where is_active)
order by p.sort_order
limit 1;

insert into public.quote_of_the_day (poetry_id, display_date)
select p.id, current_date
from public.poetry p
join public.books b on b.id = p.book_id
where b.slug = 'tum'
order by p.sort_order desc
limit 1
on conflict (display_date) do update
set poetry_id = excluded.poetry_id;
