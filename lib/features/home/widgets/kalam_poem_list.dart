import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/alerts/show_dialogs.dart';
import '../../../core/haptics/app_haptics.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../favorites/favorite_button.dart';
import '../../poetry/controller.dart';
import '../../poetry/models.dart';
import '../../poetry/popular_button.dart';
import '../../reader/view.dart';

class KalamPoemList extends StatelessWidget {
  const KalamPoemList({
    super.key,
    required this.poems,
    this.padding = EdgeInsets.zero,
    this.reorderable = false,
    this.showPosition = false,
    this.categorySlug,
  });

  final List<PoetryCatalogRow> poems;
  final EdgeInsets padding;
  final bool reorderable;
  final bool showPosition;
  final String? categorySlug;

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

    final canReorder = reorderable && poems.length > 1;

    if (canReorder) {
      return ScrollHaptics(
        child: ReorderableListView.builder(
          padding: padding,
          physics: const ClampingScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: poems.length,
          proxyDecorator: (child, index, animation) {
            return Material(
              elevation: 6,
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              child: child,
            );
          },
          onReorder: (oldIndex, newIndex) async {
            AppHaptics.medium();
            try {
              await context.read<CatalogController>().reorderPoems(
                    categorySlug: categorySlug,
                    oldIndex: oldIndex,
                    newIndex: newIndex,
                  );
            } catch (error) {
              if (!context.mounted) return;
              ShowDialogs.snackBar(context, '$error');
            }
          },
          itemBuilder: (context, i) {
            return ReorderableDelayedDragStartListener(
              key: ValueKey(poems[i].id),
              index: i,
              child: _PoemTile(
                poem: poems[i],
                poems: poems,
                index: i,
                showPosition: showPosition,
                showDivider: true,
              ),
            );
          },
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
          return _PoemTile(
            poem: poems[i],
            poems: poems,
            index: i,
            showPosition: showPosition,
            showDivider: false,
          );
        },
        separatorBuilder: (_, __) => Divider(color: colors.border, height: 1),
      ),
    );
  }
}

class _PoemTile extends StatelessWidget {
  const _PoemTile({
    required this.poem,
    required this.poems,
    required this.index,
    required this.showPosition,
    required this.showDivider,
  });

  final PoetryCatalogRow poem;
  final List<PoetryCatalogRow> poems;
  final int index;
  final bool showPosition;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            minLeadingWidth: showPosition ? 84 : 40,
            enableFeedback: false,
            leading: SizedBox(
              width: showPosition ? 84 : 48,
              child: Row(
                children: [
                  if (showPosition)
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${index + 1}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.ui(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.accent,
                        ),
                      ),
                    ),
                  PoemFavoriteButton(poetryId: poem.id),
                ],
              ),
            ),
            trailing: PoemPopularButton(poem: poem),
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
              initialIndex: index,
            ),
          ),
          if (showDivider) Divider(color: colors.border, height: 1),
        ],
      ),
    );
  }
}
