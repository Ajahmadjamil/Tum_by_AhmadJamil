import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/locale/locale_controller.dart';
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
import 'widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final catalog = context.watch<CatalogController>();
    final colors = context.colors;
    final strings = locale.strings;
    final poet = catalog.poets.isEmpty ? null : catalog.poets.first;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: colors.accent,
        onRefresh: catalog.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            HomeHeader(
              onSearchChanged: catalog.setSearchQuery,
            ),
            const SizedBox(height: 18),
            if (catalog.loading && catalog.books.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              if (catalog.error != null && catalog.books.isEmpty)
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
              FeaturedBanner(
                banners: catalog.banners,
                onTap: (banner) {
                  final poems = _queueForPoetry(catalog, banner.poetryId);
                  openReader(context, poems: poems);
                },
              ),
              const SizedBox(height: 22),
              if (catalog.isSinglePoetKalam)
                _SinglePoetKalamSection(catalog: catalog)
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
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CollectionView()),
                    );
                  },
                ),
                BookCarousel(
                  books: catalog.books,
                  onTapBook: (book) {
                    final poems = catalog.poemsForBook(book.id);
                    openReader(context, poems: poems);
                  },
                ),
              ],
              const SizedBox(height: 22),
              if (catalog.quote != null) ...[
                Text(
                  formatQuoteStamp(catalog.quote!.displayDate),
                  style: AppTextStyles.ui(
                    fontSize: 11,
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                SectionHeader(title: strings.aajKaShair),
                AajKaShairCard(
                  quote: catalog.quote!,
                  onTap: () {
                    final poems = _queueForPoetry(
                      catalog,
                      catalog.quote!.poetryId,
                    );
                    openReader(context, poems: poems);
                  },
                ),
              ],
              if (catalog.searchQuery.trim().isNotEmpty) ...[
                const SizedBox(height: 22),
                ...catalog.visibleCatalog.map(
                  (poem) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      locale.pick(
                        urdu: poem.titleUrdu,
                        english: poem.titleEnglish ?? '',
                      ),
                      textDirection: TextDirection.rtl,
                      style: AppTextStyles.nastaliq(
                        fontSize: 16,
                        height: 1.8,
                        color: colors.text,
                      ),
                    ),
                    onTap: () => openReader(
                      context,
                      poems: catalog.visibleCatalog,
                      initialIndex: catalog.visibleCatalog.indexOf(poem),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
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
  const _SinglePoetKalamSection({required this.catalog});

  final CatalogController catalog;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final poet = catalog.poets.first;
    final book = catalog.books.isEmpty ? null : catalog.books.first;
    final poetName = locale.pick(
      urdu: poet.nameUrdu,
      english: poet.nameEnglish ?? '',
    );
    final bookName = book == null
        ? ''
        : locale.pick(urdu: book.titleUrdu, english: book.titleEnglish ?? '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: locale.strings.kalamOf(poetName),
          actionLabel: bookName.isEmpty ? null : bookName,
        ),
        CategoryTiles(
          categories: catalog.categories,
          countFor: (slug) => catalog.countForCategory(slug),
          onTap: (slug) {
            catalog.selectCategory(slug);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CategoryBrowseView(),
              ),
            );
          },
        ),
      ],
    );
  }
}
