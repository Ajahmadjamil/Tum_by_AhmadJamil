import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/haptics/app_haptics.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../favorites/favorite_button.dart';
import '../../poetry/models.dart';
import '../../reader/view.dart';

class KalamPoemList extends StatelessWidget {
  const KalamPoemList({
    super.key,
    required this.poems,
    this.padding = EdgeInsets.zero,
  });

  final List<PoetryCatalogRow> poems;
  final EdgeInsetsGeometry padding;

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

    return ScrollHaptics(
      child: ListView.separated(
        padding: padding,
        physics: const ClampingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: poems.length,
        cacheExtent: 320,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        itemBuilder: (context, i) {
          final poem = poems[i];
          return Directionality(
            textDirection: TextDirection.ltr,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              enableFeedback: false,
              leading: PoemFavoriteButton(poetryId: poem.id),
              title: Text(
                poem.titleUrdu,
                textDirection: TextDirection.rtl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.nastaliq(
                  fontSize: 18,
                  height: 2,
                  color: colors.text,
                ),
              ),
              subtitle: poem.firstBodyLine == null
                  ? null
                  : Text(
                      poem.firstBodyLine!,
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.nastaliq(
                        fontSize: 16,
                        height: 2,
                        color: colors.textMuted,
                      ),
                    ),
              onTap: () => openReader(
                context,
                poems: poems,
                initialIndex: i,
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => Divider(color: colors.border, height: 1),
      ),
    );
  }
}
