import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/haptics/app_haptics.dart';
import '../../core/locale/locale_controller.dart';
import '../../core/shared/widgets/catalog_placeholders.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../poetry/controller.dart';
import '../poetry/models.dart';
import '../reader/view.dart';
import 'widgets/category_pills.dart';
import 'widgets/kalam_poem_list.dart';

class CategoryBrowseView extends StatefulWidget {
  const CategoryBrowseView({super.key, this.categorySlug});

  final String? categorySlug;

  @override
  State<CategoryBrowseView> createState() => _CategoryBrowseViewState();
}

class _CategoryBrowseViewState extends State<CategoryBrowseView> {
  late String? _slug = widget.categorySlug;

  void _openCompose() {
    final catalog = context.read<CatalogController>();
    final auth = context.read<AuthController>();
    final books = catalog.booksEditableBy(
      canEdit: (poetId) => auth.canEditBook(poetId: poetId),
    );
    final categories = catalog.categories.where(
      (category) => category.slug == _slug,
    );
    if (books.isEmpty || categories.isEmpty) return;
    openComposer(
      context,
      draft: PoetryCatalogRow.compose(
        category: categories.first,
        book: books.first,
      ),
      categoryId: categories.first.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final catalog = context.watch<CatalogController>();
    final auth = context.watch<AuthController>();
    final colors = context.colors;
    final showSkeleton = catalog.showSkeleton;
    final selected = catalog.categories.where(
      (category) => category.slug == _slug,
    );
    final title = _slug == null
        ? locale.strings.allCategories
        : locale.pick(
            urdu: selected.isEmpty
                ? locale.strings.allCategories
                : selected.first.nameUrdu,
            english: selected.isEmpty
                ? locale.strings.allCategories
                : selected.first.nameEnglish,
          );
    final poems = showSkeleton && catalog.catalog.isEmpty
        ? CatalogPlaceholders.poems(count: 8)
        : catalog.poemsForCategory(_slug);
    final canAdd = auth.hasEditPermission &&
        _slug != null &&
        _slug != CategoryRow.mashoorSlug &&
        catalog
            .booksEditableBy(canEdit: (poetId) => auth.canEditBook(poetId: poetId))
            .isNotEmpty;
    final canReorder = !showSkeleton &&
        auth.hasEditPermission &&
        poems.isNotEmpty &&
        poems.every((poem) => auth.canEditPoet(poem.poetId));

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: Text(
          title,
          style: locale.isUrdu
              ? AppTextStyles.nastaliq(
                  fontSize: 20,
                  height: 1.7,
                  color: colors.text,
                )
              : AppTextStyles.ui(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.text,
                ),
        ),
      ),
      floatingActionButton: canAdd
          ? FloatingActionButton.extended(
              onPressed: () {
                AppHaptics.selection();
                _openCompose();
              },
              backgroundColor: colors.accent,
              foregroundColor: colors.onDark,
              icon: const Icon(Icons.add),
              label: Text(
                locale.strings.addPoetry,
                style: locale.isUrdu
                    ? AppTextStyles.nastaliq(
                        fontSize: 14,
                        height: 1.6,
                        color: colors.onDark,
                      )
                    : AppTextStyles.ui(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.onDark,
                      ),
              ),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: CategoryPills(
              categories: showSkeleton && catalog.categories.isEmpty
                  ? CatalogPlaceholders.categories
                  : catalog.categoriesForBrowse(_slug),
              selectedSlug: _slug,
              onSelected: (slug) {
                AppHaptics.selection();
                setState(() => _slug = slug);
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: IgnorePointer(
              ignoring: showSkeleton,
              child: Skeletonizer(
                enabled: showSkeleton,
                child: KalamPoemList(
                  poems: poems,
                  padding: EdgeInsets.fromLTRB(16, 8, 16, canAdd ? 96 : 32),
                  reorderable: canReorder,
                  showPosition: canReorder,
                  categorySlug: _slug,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
