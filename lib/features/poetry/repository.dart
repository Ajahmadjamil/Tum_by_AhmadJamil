import '../../core/supabase/app_supabase.dart';
import 'models.dart';

class PoetryRepository {
  Future<List<CategoryRow>> fetchCategories() async {
    final rows = await AppSupabase.client
        .from('categories')
        .select()
        .order('sort_order');
    return (rows as List)
        .map((row) => CategoryRow.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<PoetRow>> fetchPoets() async {
    final rows =
        await AppSupabase.client.from('poets').select().order('name_english');
    return (rows as List)
        .map((row) => PoetRow.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<BookRow>> fetchBooks() async {
    final rows = await AppSupabase.client
        .from('books')
        .select('*, poets(name_urdu, name_english, slug)')
        .order('sort_order');
    return (rows as List)
        .map((row) => BookRow.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<PoetryCatalogRow>> fetchCatalog({
    String? categorySlug,
    String? bookId,
  }) async {
    var filter = AppSupabase.client.from('poetry_catalog').select();
    if (categorySlug != null) {
      filter = filter.eq('category_slug', categorySlug);
    }
    if (bookId != null) {
      filter = filter.eq('book_id', bookId);
    }
    final rows = await filter.order('sort_order');
    return (rows as List)
        .map((row) => PoetryCatalogRow.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<BannerRow>> fetchBanners() async {
    final rows = await AppSupabase.client
        .from('featured_banner_feed')
        .select()
        .order('sort_order');
    return (rows as List)
        .map((row) => BannerRow.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<QuoteRow?> fetchTodayQuote() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final rows = await AppSupabase.client
        .from('aaj_ka_shair')
        .select()
        .eq('display_date', today)
        .limit(1);
    final list = rows as List;
    if (list.isNotEmpty) {
      return QuoteRow.fromMap(list.first as Map<String, dynamic>);
    }

    final latest = await AppSupabase.client
        .from('poetry_catalog')
        .select()
        .order('sort_order', ascending: false)
        .limit(1);
    final latestList = latest as List;
    if (latestList.isEmpty) return null;
    return QuoteRow.fromLatest(
      PoetryCatalogRow.fromMap(latestList.first as Map<String, dynamic>),
    );
  }
}
