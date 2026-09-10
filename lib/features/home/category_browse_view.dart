import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/haptics/app_haptics.dart';
import '../../core/locale/locale_controller.dart';
import '../../core/shared/widgets/catalog_placeholders.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../poetry/controller.dart';
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

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final catalog = context.watch<CatalogController>();
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

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: Text(
          title,
          style: locale.isUrdu
              ? AppTextStyles.nastaliq(
                  fontSize: 20,
                  height: 1.7,
                  color: context.colors.text,
                )
              : AppTextStyles.ui(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.colors.text,
                ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: CategoryPills(
              categories: showSkeleton && catalog.categories.isEmpty
                  ? CatalogPlaceholders.categories
                  : catalog.categories,
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
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
