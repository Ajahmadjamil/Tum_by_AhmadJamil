-- Remove dummy poems/verses while keeping poets, books, and categories.
delete from public.featured_banners;
delete from public.quote_of_the_day;
delete from public.user_favorites;
delete from public.poetry_verses;
delete from public.poetry;
