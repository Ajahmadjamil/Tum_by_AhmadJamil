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

  List<CategoryRow> get visibleCategories {
    final showMashoor = countForCategory(CategoryRow.mashoorSlug) > 0;
    return [
      for (final category in categories)
        if (!category.isMashoor || showMashoor) category,
    ];
  }

  List<CategoryRow> categoriesForBrowse(String? selectedSlug) {
    final visible = visibleCategories;
    if (selectedSlug == CategoryRow.mashoorSlug &&
        !visible.any((category) => category.isMashoor)) {
      return [CategoryRow.mashoor, ...visible];
    }
    return visible;
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
    categories = _withMashoor(snapshot.categories);
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
    final popular = <PoetryCatalogRow>[];
    for (final poem in sorted) {
      if (poem.categorySlug != CategoryRow.mashoorSlug) {
        (byCategory[poem.categorySlug] ??= []).add(poem);
      }
      if (poem.isPopular) popular.add(poem);
      final bookId = poem.bookId;
      if (bookId != null) {
        (byBook[bookId] ??= []).add(poem);
      }
    }
    popular.sort((a, b) {
      final as = a.popularSort ?? a.sortOrder;
      final bs = b.popularSort ?? b.sortOrder;
      final byPopular = as.compareTo(bs);
      if (byPopular != 0) return byPopular;
      return a.sortOrder.compareTo(b.sortOrder);
    });
    byCategory[CategoryRow.mashoorSlug] = popular;
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

  List<BookRow> booksEditableBy({required bool Function(String poetId) canEdit}) {
    return books.where((book) => canEdit(book.poetId)).toList(growable: false);
  }

  Future<String> publishPoem({
    required String categoryId,
    required String bookId,
    required String titleUrdu,
    required String body,
    String? titleEnglish,
  }) async {
    final id = await _repository.createPoetryPost(
      categoryId: categoryId,
      bookId: bookId,
      titleUrdu: titleUrdu,
      body: body,
      titleEnglish: titleEnglish,
    );
    await refreshFromNetwork();
    return id;
  }

  Future<void> updatePoem({
    required String poetryId,
    required String titleUrdu,
    required String body,
  }) async {
    await _repository.updatePoetryPost(
      poetryId: poetryId,
      titleUrdu: titleUrdu,
      body: body,
    );
    final existing = poemById(poetryId);
    if (existing != null) {
      catalog = [
        for (final poem in catalog)
          if (poem.id == poetryId)
            existing.copyWith(titleUrdu: titleUrdu, body: body)
          else
            poem,
      ];
      _rebuildIndexes();
      notifyListeners();
    }
    unawaited(refreshFromNetwork());
  }

  Future<void> setPopular(String poetryId, bool isPopular) async {
    final existing = poemById(poetryId);
    if (existing == null || existing.isPopular == isPopular) return;
    var nextPopularSort = existing.popularSort;
    if (isPopular) {
      var maxSort = 0;
      for (final poem in catalog) {
        if (poem.isPopular) {
          final sort = poem.popularSort ?? 0;
          if (sort > maxSort) maxSort = sort;
        }
      }
      nextPopularSort = maxSort + 1;
    }
    catalog = [
      for (final poem in catalog)
        if (poem.id == poetryId)
          poem.copyWith(
            isPopular: isPopular,
            popularSort: isPopular ? nextPopularSort : null,
            clearPopularSort: !isPopular,
          )
        else
          poem,
    ];
    _rebuildIndexes();
    notifyListeners();
    try {
      await _repository.setPoetryPopular(
        poetryId: poetryId,
        isPopular: isPopular,
      );
    } catch (_) {
      catalog = [
        for (final poem in catalog)
          if (poem.id == poetryId)
            poem.copyWith(
              isPopular: existing.isPopular,
              popularSort: existing.popularSort,
              clearPopularSort: existing.popularSort == null,
            )
          else
            poem,
      ];
      _rebuildIndexes();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> reorderPoems({
    required String? categorySlug,
    required int oldIndex,
    required int newIndex,
  }) async {
    var target = newIndex;
    if (oldIndex < target) target -= 1;
    if (oldIndex == target) return;

    final current = List<PoetryCatalogRow>.from(poemsForCategory(categorySlug));
    if (oldIndex < 0 || oldIndex >= current.length) return;
    if (target < 0 || target >= current.length) return;

    final moved = current.removeAt(oldIndex);
    current.insert(target, moved);
    final order = <String, int>{
      for (var i = 0; i < current.length; i++) current[i].id: i + 1,
    };
    final popular = categorySlug == CategoryRow.mashoorSlug;
    final previous = catalog;
    if (popular) {
      catalog = [
        for (final poem in catalog)
          if (order.containsKey(poem.id))
            poem.copyWith(popularSort: order[poem.id])
          else
            poem,
      ];
    } else {
      final slots = [for (final poem in current) poem.sortOrder]..sort();
      catalog = [
        for (final poem in catalog)
          if (order.containsKey(poem.id))
            poem.copyWith(sortOrder: slots[order[poem.id]! - 1])
          else
            poem,
      ];
    }
    _rebuildIndexes();
    notifyListeners();
    try {
      final ids = current.map((poem) => poem.id).toList(growable: false);
      if (popular) {
        await _repository.reorderPopularPosts(ids);
      } else {
        await _repository.reorderPoetryPosts(ids);
      }
    } catch (_) {
      catalog = previous;
      _rebuildIndexes();
      notifyListeners();
      rethrow;
    }
  }

  List<PoetryCatalogRow> trash = const [];
  bool trashLoading = false;

  Future<void> loadTrash() async {
    trashLoading = true;
    notifyListeners();
    try {
      trash = await _repository.fetchTrash();
    } finally {
      trashLoading = false;
      notifyListeners();
    }
  }

  Future<void> moveToTrash(String poetryId) async {
    await _repository.trashPoetryPost(poetryId);
    catalog = [for (final poem in catalog) if (poem.id != poetryId) poem];
    _rebuildIndexes();
    notifyListeners();
    unawaited(refreshFromNetwork());
  }

  Future<void> restoreFromTrash(String poetryId) async {
    await _repository.restorePoetryPost(poetryId);
    trash = [for (final poem in trash) if (poem.id != poetryId) poem];
    notifyListeners();
    await refreshFromNetwork();
  }

  Future<void> purgeFromTrash(String poetryId) async {
    await _repository.purgePoetryPost(poetryId);
    trash = [for (final poem in trash) if (poem.id != poetryId) poem];
    notifyListeners();
  }

  Future<void> emptyTrash() async {
    await _repository.emptyPoetryTrash();
    trash = const [];
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

List<CategoryRow> _withMashoor(List<CategoryRow> categories) {
  return [
    CategoryRow.mashoor,
    ..._sortedCategories([
      for (final category in categories)
        if (!category.isMashoor) category,
    ]),
  ];
}
