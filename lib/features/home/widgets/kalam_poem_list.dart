import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../favorites/favorite_button.dart';
import '../../poetry/models.dart';
import '../../reader/view.dart';

class KalamPoemList extends StatelessWidget {
  const KalamPoemList({super.key, required this.poems});

  final List<PoetryCatalogRow> poems;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final colors = context.colors;

    if (poems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Text(
          locale.strings.emptyCategory,
          textAlign: TextAlign.center,
          style: AppTextStyles.label(locale.isUrdu, color: colors.textMuted),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < poems.length; i++) ...[
          if (i > 0) Divider(color: colors.border, height: 1),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            title: Text(
              poems[i].teaserLine1 ??
                  locale.pick(
                    urdu: poems[i].titleUrdu,
                    english: poems[i].titleEnglish ?? '',
                  ),
              textDirection: TextDirection.rtl,
              style: AppTextStyles.nastaliq(
                fontSize: 18,
                height: 2,
                color: colors.text,
              ),
            ),
            subtitle: poems[i].teaserLine2 == null
                ? null
                : Text(
                    poems[i].teaserLine2!,
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.nastaliq(
                      fontSize: 16,
                      height: 2,
                      color: colors.textMuted,
                    ),
                  ),
            trailing: PoemFavoriteButton(poetryId: poems[i].id),
            onTap: () => openReader(
              context,
              poems: poems,
              initialIndex: i,
            ),
          ),
        ],
      ],
    );
  }
}
