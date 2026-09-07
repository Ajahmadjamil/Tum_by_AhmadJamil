import 'package:flutter/foundation.dart';

import '../../core/supabase/app_supabase.dart';
import 'models.dart';
import 'repository.dart';

class CatalogController extends ChangeNotifier {
  CatalogController({PoetryRepository? repository})
      : _repository = repository ?? PoetryRepository();

  final PoetryRepository _repository;

  bool loading = false;
  String? error;
  String searchQuery = '';

  List<CategoryRow> categories = const [];
  List<PoetRow> poets = const [];
  List<BookRow> books = const [];
  List<PoetryCatalogRow> catalog = const [];
  List<BannerRow> banners = const [];
  QuoteRow? quote;
  String? selectedCategorySlug;

  bool get isSinglePoetKalam => poets.length == 1;

  List<PoetryCatalogRow> get visibleCatalog {
    final query = searchQuery.trim();
    if (query.isEmpty) return catalog;
    return catalog.where((poem) {
      return poem.titleUrdu.contains(query) ||
          (poem.titleEnglish?.toLowerCase().contains(query.toLowerCase()) ??
              false) ||
          (poem.teaserLine1?.contains(query) ?? false) ||
          (poem.teaserLine2?.contains(query) ?? false) ||
          poem.body.contains(query);
    }).toList();
  }

  List<PoetryCatalogRow> poemsForBook(String bookId) {
    final poems = catalog.where((poem) => poem.bookId == bookId).toList();
    poems.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return poems;
  }

  PoetryCatalogRow? poemById(String id) {
    for (final poem in catalog) {
      if (poem.id == id) return poem;
    }
    return null;
  }

  List<PoetryCatalogRow> poemsForSelectedCategory() {
    final poems = selectedCategorySlug == null
        ? List<PoetryCatalogRow>.from(catalog)
        : catalog
            .where((poem) => poem.categorySlug == selectedCategorySlug)
            .toList();
    poems.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return poems;
  }

  List<PoetryCatalogRow> get latestGallery {
    final poems = List<PoetryCatalogRow>.from(catalog)
      ..sort((a, b) => b.sortOrder.compareTo(a.sortOrder));
    return poems.take(10).toList();
  }

  int countForCategory(String? slug) {
    if (slug == null) return catalog.length;
    return catalog.where((poem) => poem.categorySlug == slug).length;
  }

  void selectCategory(String? slug) {
    selectedCategorySlug = slug;
    notifyListeners();
  }

  Future<void> load() async {
    if (!AppSupabase.isConfigured) {
      error = 'missing_key';
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      categories = _sortedCategories(await _repository.fetchCategories());
      poets = await _repository.fetchPoets();
      books = await _repository.fetchBooks();
      catalog = await _repository.fetchCatalog();
      banners = await _repository.fetchBanners();
      quote = await _repository.fetchTodayQuote();
      if (quote == null && catalog.isNotEmpty) {
        final latest = List<PoetryCatalogRow>.from(catalog)
          ..sort((a, b) => b.sortOrder.compareTo(a.sortOrder));
        quote = QuoteRow.fromLatest(latest.first);
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }
}

const _categoryDisplayOrder = ['ghazal', 'nazm', 'shair', 'qataa', 'tehreer'];

List<CategoryRow> _sortedCategories(List<CategoryRow> categories) {
  final ranked = [...categories];
  ranked.sort((a, b) {
    final ai = _categoryDisplayOrder.indexOf(a.slug);
    final bi = _categoryDisplayOrder.indexOf(b.slug);
    return (ai < 0 ? 999 : ai).compareTo(bi < 0 ? 999 : bi);
  });
  return ranked;
}
