import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/local_db/app_data_cache.dart';
import '../../core/supabase/app_supabase.dart';
import 'models.dart';
import 'repository.dart';

class CatalogController extends ChangeNotifier {
  CatalogController({
    PoetryRepository? repository,
    AppDataCache? cache,
  })  : _repository = repository ?? PoetryRepository(),
        _cache = cache ?? AppDataCache();

  final PoetryRepository _repository;
  final AppDataCache _cache;

  bool loading = true;
  String? error;
  String searchQuery = '';

  List<CategoryRow> categories = const [];
  List<PoetRow> poets = const [];
  List<BookRow> books = const [];
  List<PoetryCatalogRow> catalog = const [];
  List<BannerRow> banners = const [];
  QuoteRow? quote;
  String? selectedCategorySlug;

  List<PoetryCatalogRow> _sortedCatalog = const [];
  Map<String, PoetryCatalogRow> _poemsById = const {};
  Map<String, List<PoetryCatalogRow>> _poemsByCategory = const {};
  Map<String, List<PoetryCatalogRow>> _poemsByBook = const {};
  Map<String?, int> _categoryCounts = const {};
  List<PoetryCatalogRow> _gallery = const [];
  List<PoetryCatalogRow>? _visibleCache;
  String _visibleQuery = '';

  bool get isSinglePoetKalam => poets.length == 1;

  bool get showSkeleton => loading && catalog.isEmpty;

  List<PoetryCatalogRow> get visibleCatalog {
    final query = searchQuery.trim();
    if (query.isEmpty) return catalog;
    if (query == _visibleQuery && _visibleCache != null) return _visibleCache!;
    final lower = query.toLowerCase();
    final matches = catalog.where((poem) {
      return poem.titleUrdu.contains(query) ||
          (poem.titleEnglish?.toLowerCase().contains(lower) ?? false) ||
          (poem.firstBodyLine?.contains(query) ?? false) ||
          (poem.teaserLine1?.contains(query) ?? false) ||
          (poem.teaserLine2?.contains(query) ?? false);
    }).toList(growable: false);
    _visibleQuery = query;
    _visibleCache = matches;
    return matches;
  }

  List<PoetryCatalogRow> poemsForBook(String bookId) {
    return _poemsByBook[bookId] ?? const [];
  }

  PoetryCatalogRow? poemById(String id) => _poemsById[id];

  List<PoetryCatalogRow> poemsForSelectedCategory() {
    return poemsForCategory(selectedCategorySlug);
  }

  List<PoetryCatalogRow> poemsForCategory(String? slug) {
    if (slug == null) return _sortedCatalog;
    return _poemsByCategory[slug] ?? const [];
  }

  List<PoetryCatalogRow> get latestGallery => _gallery;

  int countForCategory(String? slug) {
    return _categoryCounts[slug] ?? 0;
  }

  void selectCategory(String? slug) {
    selectedCategorySlug = slug;
    notifyListeners();
  }

  Future<void> hydrateFromCache() async {
    final snapshot = await _cache.readSnapshot();
    if (snapshot == null || snapshot.isEmpty) return;
    _applySnapshot(snapshot);
    loading = false;
    notifyListeners();
  }

  Future<void> load() => refreshFromNetwork();

  Future<void> refreshFromNetwork() async {
    if (!AppSupabase.isConfigured) {
      error = 'missing_key';
      loading = false;
      notifyListeners();
      return;
    }

    final hadData = catalog.isNotEmpty;
    if (!hadData) {
      loading = true;
      error = null;
      notifyListeners();
    }

    try {
      final fetched = await Future.wait([
        _repository.fetchCategories(),
        _repository.fetchPoets(),
        _repository.fetchBooks(),
        _repository.fetchCatalog(),
        _repository.fetchBanners(),
        _repository.fetchTodayQuote(),
      ]);

      var nextQuote = fetched[5] as QuoteRow?;
      final nextCatalog = fetched[3] as List<PoetryCatalogRow>;
      if (nextQuote == null && nextCatalog.isNotEmpty) {
        final latest = List<PoetryCatalogRow>.from(nextCatalog)
          ..sort((a, b) => b.sortOrder.compareTo(a.sortOrder));
        nextQuote = QuoteRow.fromLatest(latest.first);
      }

      final snapshot = CatalogSnapshot(
        categories: _sortedCategories(fetched[0] as List<CategoryRow>),
        poets: fetched[1] as List<PoetRow>,
        books: fetched[2] as List<BookRow>,
        catalog: nextCatalog,
        banners: fetched[4] as List<BannerRow>,
        quote: nextQuote,
      );
      _applySnapshot(snapshot);
      error = null;
      unawaited(_cache.saveSnapshot(snapshot));
    } catch (e) {
      if (!hadData) error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _applySnapshot(CatalogSnapshot snapshot) {
    categories = snapshot.categories;
    poets = snapshot.poets;
    books = snapshot.books;
    catalog = snapshot.catalog;
    banners = snapshot.banners;
    quote = snapshot.quote;
    _rebuildIndexes();
  }

  void _rebuildIndexes() {
    final sorted = List<PoetryCatalogRow>.from(catalog)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _sortedCatalog = sorted;
    _poemsById = {for (final poem in sorted) poem.id: poem};

    final byCategory = <String, List<PoetryCatalogRow>>{};
    final byBook = <String, List<PoetryCatalogRow>>{};
    for (final poem in sorted) {
      (byCategory[poem.categorySlug] ??= []).add(poem);
      final bookId = poem.bookId;
      if (bookId != null) {
        (byBook[bookId] ??= []).add(poem);
      }
    }
    _poemsByCategory = byCategory;
    _poemsByBook = byBook;
    _categoryCounts = {
      null: sorted.length,
      for (final entry in byCategory.entries) entry.key: entry.value.length,
    };
    _gallery = sorted.reversed.take(10).toList(growable: false);
    _visibleCache = null;
  }

  void setSearchQuery(String value) {
    if (value == searchQuery) return;
    searchQuery = value;
    _visibleCache = null;
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
