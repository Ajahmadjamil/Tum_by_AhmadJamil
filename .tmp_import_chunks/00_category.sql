-- Import Tum by Ahmad Jamil from Excel, preserving worksheet order.
insert into public.categories (slug, name_urdu, name_english, sort_order)
values ('tehreer', 'تحریر', 'Tehreer', 5)
on conflict (slug) do nothing;
