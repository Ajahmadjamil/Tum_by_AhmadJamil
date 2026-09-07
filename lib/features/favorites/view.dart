import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/locale/locale_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../poetry/controller.dart';
import '../reader/view.dart';
import 'controller.dart';
import 'favorite_button.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final catalog = context.watch<CatalogController>();
    final favorites = context.watch<FavoritesController>();
    final colors = context.colors;
    final poems =
        catalog.catalog.where((poem) => favorites.isFavorite(poem.id)).toList();

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
            child: poems.isEmpty
                ? Center(
                    child: Text(
                      locale.strings.emptyFavorites,
                      style: AppTextStyles.label(
                        locale.isUrdu,
                        color: colors.textMuted,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: poems.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: colors.border),
                    itemBuilder: (context, index) {
                      final poem = poems[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          locale.pick(
                            urdu: poem.titleUrdu,
                            english: poem.titleEnglish ?? '',
                          ),
                          textDirection: TextDirection.rtl,
                          style: AppTextStyles.nastaliq(
                            fontSize: 18,
                            height: 1.9,
                            color: colors.text,
                          ),
                        ),
                        trailing: PoemFavoriteButton(poetryId: poem.id),
                        onTap: () => openReader(
                          context,
                          poems: poems,
                          initialIndex: index,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
