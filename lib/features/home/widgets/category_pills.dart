import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/haptics/app_haptics.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../poetry/models.dart';

class CategoryPills extends StatelessWidget {
  const CategoryPills({
    super.key,
    required this.categories,
    required this.selectedSlug,
    required this.onSelected,
  });

  final List<CategoryRow> categories;
  final String? selectedSlug;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final colors = context.colors;
    final chips = <_ChipData>[
      _ChipData(slug: null, label: locale.strings.allCategories),
      ...categories.map(
        (category) => _ChipData(
          slug: category.slug,
          label: locale.pick(
            urdu: category.nameUrdu,
            english: category.nameEnglish,
          ),
        ),
      ),
    ];

    return SizedBox(
      height: 46,
      child: ScrollHaptics(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          cacheExtent: 120,
          addAutomaticKeepAlives: false,
          itemCount: chips.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final chip = chips[index];
            final selected = chip.slug == selectedSlug;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(chip.slug),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? colors.accentSoft : colors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: selected ? colors.accent : colors.border,
                    width: selected ? 1.4 : 1,
                  ),
                ),
                child: Text(
                  chip.label,
                  style: locale.isUrdu
                      ? AppTextStyles.nastaliq(
                          fontSize: 14,
                          height: 1.6,
                          color: selected ? colors.accent : colors.text,
                        )
                      : AppTextStyles.ui(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? colors.accent : colors.text,
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ChipData {
  const _ChipData({required this.slug, required this.label});

  final String? slug;
  final String label;
}
