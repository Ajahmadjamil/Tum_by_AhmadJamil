import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/locale/locale_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../poetry/controller.dart';
import 'widgets/category_pills.dart';
import 'widgets/kalam_poem_list.dart';

class CategoryBrowseView extends StatelessWidget {
  const CategoryBrowseView({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final catalog = context.watch<CatalogController>();
    final selected = catalog.categories.where(
      (category) => category.slug == catalog.selectedCategorySlug,
    );
    final title = catalog.selectedCategorySlug == null
        ? locale.strings.allCategories
        : locale.pick(
            urdu: selected.isEmpty
                ? locale.strings.allCategories
                : selected.first.nameUrdu,
            english: selected.isEmpty
                ? locale.strings.allCategories
                : selected.first.nameEnglish,
          );

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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          CategoryPills(
            categories: catalog.categories,
            selectedSlug: catalog.selectedCategorySlug,
            onSelected: catalog.selectCategory,
          ),
          const SizedBox(height: 16),
          KalamPoemList(poems: catalog.poemsForSelectedCategory()),
        ],
      ),
    );
  }
}
