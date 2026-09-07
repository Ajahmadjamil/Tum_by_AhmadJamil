import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../poetry/models.dart';

class CategoryTiles extends StatelessWidget {
  const CategoryTiles({
    super.key,
    required this.categories,
    required this.countFor,
    required this.onTap,
  });

  final List<CategoryRow> categories;
  final int Function(String? slug) countFor;
  final ValueChanged<String?> onTap;

  @override
  Widget build(BuildContext context) {
    final items = <CategoryRow?>[null, ...categories];
    return SizedBox(
      height: 236,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = items[index];
          return _CategoryTile(
            category: category,
            count: countFor(category?.slug),
            onTap: () => onTap(category?.slug),
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.count,
    required this.onTap,
  });

  final CategoryRow? category;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final slug = category?.slug ?? 'all';
    final title = category == null
        ? locale.strings.allCategories
        : locale.pick(
            urdu: category!.nameUrdu,
            english: category!.nameEnglish,
          );
    final english = category?.nameEnglish ?? 'All';
    final palette = _paletteFor(slug);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 152,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(gradient: palette.gradient),
                    ),
                    Positioned(
                      top: -28,
                      left: -20,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: palette.glow.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -36,
                      right: -24,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.28),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              english.toUpperCase(),
                              style: AppTextStyles.ui(
                                fontSize: 10,
                                color: context.colors.onDarkMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: AppTextStyles.nastaliq(
                              fontSize: 32,
                              height: 1.45,
                              fontWeight: FontWeight.w700,
                              color: context.colors.onDark,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            locale.strings.poemCount(count),
                            style: AppTextStyles.ui(
                              fontSize: 11,
                              color: context.colors.onDarkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.nastaliq(
                fontSize: 15,
                height: 1.6,
                color: context.colors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TilePalette {
  const _TilePalette({required this.gradient, required this.glow});

  final LinearGradient gradient;
  final Color glow;
}

_TilePalette _paletteFor(String slug) {
  switch (slug) {
    case 'all':
      return const _TilePalette(
        glow: Color(0xFFFF8A3D),
        gradient: LinearGradient(
          colors: [Color(0xFF3A2010), Color(0xFF120C08), Color(0xFF2A160C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    case 'ghazal':
      return const _TilePalette(
        glow: Color(0xFF8B5CF6),
        gradient: LinearGradient(
          colors: [Color(0xFF2A1458), Color(0xFF0C0A16), Color(0xFF1A1030)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    case 'nazm':
      return const _TilePalette(
        glow: Color(0xFF2EC4B6),
        gradient: LinearGradient(
          colors: [Color(0xFF0E2A28), Color(0xFF081210), Color(0xFF12302C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    case 'shair':
      return const _TilePalette(
        glow: Color(0xFFE0B44A),
        gradient: LinearGradient(
          colors: [Color(0xFF3A2410), Color(0xFF120C08), Color(0xFF2A160C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    case 'qataa':
      return const _TilePalette(
        glow: Color(0xFFEF4444),
        gradient: LinearGradient(
          colors: [Color(0xFF3A1014), Color(0xFF12080A), Color(0xFF2A0C12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    case 'tehreer':
      return const _TilePalette(
        glow: Color(0xFF60A5FA),
        gradient: LinearGradient(
          colors: [Color(0xFF102033), Color(0xFF0A1018), Color(0xFF163044)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    default:
      return const _TilePalette(
        glow: Color(0xFFE0B44A),
        gradient: LinearGradient(
          colors: [Color(0xFF2A1810), Color(0xFF0E0E0E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      );
  }
}
