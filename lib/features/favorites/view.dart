import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/locale/locale_controller.dart';
import '../../core/shared/widgets/catalog_placeholders.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../home/widgets/kalam_poem_list.dart';
import '../poetry/controller.dart';
import 'controller.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final catalog = context.watch<CatalogController>();
    final favorites = context.watch<FavoritesController>();
    final colors = context.colors;
    final showSkeleton = catalog.showSkeleton ||
        (favorites.hydrating && catalog.catalog.isEmpty);
    final poems = showSkeleton
        ? CatalogPlaceholders.poems()
        : catalog.catalog
            .where((poem) => favorites.isFavorite(poem.id))
            .toList();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              locale.strings.favorites,
              style: AppTextStyles.heading(
                locale.isUrdu,
                fontSize: 22,
                color: colors.text,
              ),
            ),
          ),
          Expanded(
            child: !showSkeleton && poems.isEmpty
                ? Center(
                    child: Text(
                      locale.strings.emptyFavorites,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.label(
                        locale.isUrdu,
                        color: colors.textMuted,
                      ),
                    ),
                  )
                : IgnorePointer(
                    ignoring: showSkeleton,
                    child: Skeletonizer(
                      enabled: showSkeleton,
                      child: KalamPoemList(
                        poems: poems,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
