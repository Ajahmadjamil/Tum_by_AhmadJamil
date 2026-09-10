import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/haptics/app_haptics.dart';
import '../../core/locale/locale_controller.dart';
import '../../core/navigation/snappy_route.dart';
import '../../core/shared/widgets/catalog_placeholders.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../poetry/controller.dart';
import '../poetry/models.dart';
import '../reader/view.dart';
import 'collection_view.dart';
import 'category_browse_view.dart';
import 'widgets/aaj_ka_shair_card.dart';
import 'widgets/book_carousel.dart';
import 'widgets/category_tiles.dart';
import 'widgets/featured_banner.dart';
import 'widgets/home_header.dart';
import 'widgets/kalam_poem_list.dart';
import 'widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final catalog = context.watch<CatalogController>();
    final colors = context.colors;
    final strings = locale.strings;
    final showSkeleton = catalog.showSkeleton;
    final poet = catalog.poets.isEmpty ? null : catalog.poets.first;
    final banners = catalog.banners.isEmpty && showSkeleton
        ? [BannerRow.placeholder()]
        : catalog.banners;
    final quote =
        catalog.quote ?? (showSkeleton ? QuoteRow.placeholder() : null);
    final categories = catalog.categories.isEmpty && showSkeleton
        ? CatalogPlaceholders.categories
        : catalog.categories;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: HomeHeader(
              onSearchChanged: catalog.setSearchQuery,
            ),
          ),
          Expanded(
            child: catalog.searchQuery.trim().isNotEmpty
                ? KalamPoemList(
                    poems: catalog.visibleCatalog,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  )
                : RefreshIndicator(
                    color: colors.accent,
                    onRefresh: catalog.refreshFromNetwork,
                    child: ScrollHaptics(
                      child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: ClampingScrollPhysics(),
                      ),
                      cacheExtent: 420,
                      addAutomaticKeepAlives: false,
                      children: [
                        if (catalog.error != null &&
                            catalog.catalog.isEmpty &&
                            !showSkeleton)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              locale.isUrdu
                                  ? 'ڈیٹا لوڈ نہیں ہوا۔ کلید لگائیں یا دوبارہ کوشش کریں۔'
                                  : 'Could not load poetry. Add the Supabase key and retry.',
                              style: AppTextStyles.label(
                                locale.isUrdu,
                                color: colors.textMuted,
                              ),
                            ),
                          ),
                        IgnorePointer(
                          ignoring: showSkeleton,
                          child: Skeletonizer(
                            enabled: showSkeleton,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                FeaturedBanner(
                                  banners: banners,
                                  onTap: (banner) {
                                    _openPoetry(
                                      context,
                                      catalog,
                                      banner.poetryId,
                                    );
                                  },
                                ),
                                const SizedBox(height: 22),
                                if (showSkeleton || catalog.isSinglePoetKalam)
                                  _SinglePoetKalamSection(
                                    catalog: catalog,
                                    categories: categories,
                                  )
                                else ...[
                                  SectionHeader(
                                    title: poet == null
                                        ? strings.appName
                                        : strings.kalamOf(
                                            locale.pick(
                                              urdu: poet.nameUrdu,
                                              english: poet.nameEnglish ?? '',
                                            ),
                                          ),
                                    actionLabel: strings.seeMore,
                                    onAction: () {
                                      AppHaptics.heavy();
                                      Navigator.of(context).push(
                                        snappyRoute(const CollectionView()),
                                      );
                                    },
                                  ),
                                  BookCarousel(
                                    books: catalog.books,
                                    onTapBook: (book) {
                                      final poems =
                                          catalog.poemsForBook(book.id);
                                      openReader(context, poems: poems);
                                    },
                                  ),
                                ],
                                const SizedBox(height: 22),
                                if (quote != null) ...[
                                  Text(
                                    formatQuoteStamp(quote.displayDate),
                                    style: AppTextStyles.ui(
                                      fontSize: 11,
                                      color: colors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SectionHeader(title: strings.aajKaShair),
                                  AajKaShairCard(
                                    quote: quote,
                                    onTap: () {
                                      _openPoetry(
                                        context,
                                        catalog,
                                        quote.poetryId,
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

void _openPoetry(
  BuildContext context,
  CatalogController catalog,
  String? poetryId,
) {
  final poems = _queueForPoetry(catalog, poetryId);
  var index = 0;
  if (poetryId != null) {
    final found = poems.indexWhere((poem) => poem.id == poetryId);
    if (found >= 0) index = found;
  }
  openReader(context, poems: poems, initialIndex: index);
}

List<PoetryCatalogRow> _queueForPoetry(
  CatalogController catalog,
  String? poetryId,
) {
  if (poetryId == null) return catalog.catalog;
  final poem = catalog.poemById(poetryId);
  if (poem?.bookId != null) {
    final bookPoems = catalog.poemsForBook(poem!.bookId!);
    if (bookPoems.isNotEmpty) return bookPoems;
  }
  if (poem != null) return [poem];
  return catalog.catalog;
}

class _SinglePoetKalamSection extends StatelessWidget {
  const _SinglePoetKalamSection({
    required this.catalog,
    required this.categories,
  });

  final CatalogController catalog;
  final List<CategoryRow> categories;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final poet = catalog.poets.isEmpty ? null : catalog.poets.first;
    final book = catalog.books.isEmpty ? null : catalog.books.first;
    final poetName = poet == null
        ? 'احمد جمیل'
        : locale.pick(
            urdu: poet.nameUrdu,
            english: poet.nameEnglish ?? '',
          );
    final bookName = book == null
        ? 'تم'
        : locale.pick(urdu: book.titleUrdu, english: book.titleEnglish ?? '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: locale.strings.kalamOf(poetName),
          actionLabel: bookName.isEmpty ? null : bookName,
        ),
        CategoryTiles(
          categories: categories,
          countFor: (slug) => catalog.countForCategory(slug),
          onTap: (slug) {
            AppHaptics.heavy();
            Navigator.of(context).push(
              snappyRoute(CategoryBrowseView(categorySlug: slug)),
            );
          },
        ),
      ],
    );
  }
}
