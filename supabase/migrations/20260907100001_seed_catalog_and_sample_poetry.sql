insert into public.categories (slug, name_urdu, name_english, sort_order)
values
  ('ghazal', 'غزل', 'Ghazal', 1),
  ('nazm', 'نظم', 'Nazm', 2),
  ('shair', 'شعر', 'Shair', 3),
  ('qataa', 'قطعہ', 'Qataa', 4);

-- Catalog only. Poetry verses are added later from the dashboard.
with poet as (
  insert into public.poets (
    slug, name_urdu, name_english, bio_urdu, bio_english
  )
  values (
    'ahmad-jamil',
    'احمد جمیل',
    'Ahmad Jamil',
    'ٹیسٹ اندراج — بعد میں اصل تعارف سے بدل دیں۔',
    'Test poet row. Replace later from the dashboard.'
  )
  returning id
)
insert into public.books (
  poet_id, slug, title_urdu, title_english,
  description_urdu, description_english, release_year, sort_order
)
select
  poet.id,
  'tum',
  'تم',
  'Tum',
  'ٹیسٹ کتاب — بعد میں سرورق اور تفصیل شامل کریں۔',
  'Test book row for the Home library grid.',
  2024,
  1
from poet;
