import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/locale/locale_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../favorites/favorite_button.dart';
import '../poetry/controller.dart';
import '../reader/view.dart';

class CollectionView extends StatelessWidget {
  const CollectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final catalog = context.watch<CatalogController>();
    final colors = context.colors;
    final poems = catalog.catalog;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale.strings.appName,
          style: AppTextStyles.nastaliq(
            fontSize: 20,
            height: 1.7,
            color: colors.text,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: poems.length,
        separatorBuilder: (_, __) => Divider(color: colors.border),
        itemBuilder: (context, index) {
          final poem = poems[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              locale.pick(urdu: poem.titleUrdu, english: poem.titleEnglish ?? ''),
              textDirection: TextDirection.rtl,
              style: AppTextStyles.nastaliq(
                fontSize: 18,
                height: 1.9,
                color: colors.text,
              ),
            ),
            subtitle: Text(
              locale.pick(
                urdu: poem.categoryNameUrdu,
                english: poem.categoryNameEnglish,
              ),
              style: AppTextStyles.label(locale.isUrdu, color: colors.textMuted),
            ),
            trailing: PoemFavoriteButton(poetryId: poem.id),
            onTap: () => openReader(context, poems: poems, initialIndex: index),
          );
        },
      ),
    );
  }
}
