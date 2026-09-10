import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../poetry/models.dart';
import 'auto_page_carousel.dart';

class PopularBanner extends StatelessWidget {
  const PopularBanner({
    super.key,
    required this.poems,
    required this.onTap,
  });

  final List<PoetryCatalogRow> poems;
  final ValueChanged<PoetryCatalogRow> onTap;

  @override
  Widget build(BuildContext context) {
    if (poems.isEmpty) return const SizedBox.shrink();
    return AutoPageCarousel(
      itemCount: poems.length,
      itemBuilder: (context, index) {
        final poem = poems[index];
        return _PopularCard(
          poem: poem,
          onTap: () => onTap(poem),
        );
      },
    );
  }
}

class _PopularCard extends StatelessWidget {
  const _PopularCard({required this.poem, required this.onTap});

  final PoetryCatalogRow poem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final colors = context.colors;
    final title = locale.pick(
      urdu: poem.titleUrdu,
      english: poem.titleEnglish ?? poem.titleUrdu,
    );
    final category = locale.pick(
      urdu: poem.categoryNameUrdu,
      english: poem.categoryNameEnglish,
    );
    final line = poem.firstBodyLine;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF3A2A0C),
                    Color(0xFF120E08),
                    Color(0xFF2A220C),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              left: -28,
              top: -24,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE0B44A).withValues(alpha: 0.28),
                  ),
                  child: const SizedBox(width: 150, height: 150),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: const Color(0xFFE0B44A).withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category.toUpperCase(),
                        style: AppTextStyles.ui(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colors.onDarkMuted,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.nastaliq(
                      fontSize: 26,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                      color: colors.onDark,
                    ),
                  ),
                  if (line != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      line,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.nastaliq(
                        fontSize: 15,
                        height: 1.9,
                        color: colors.onDarkMuted,
                      ),
                    ),
                  ],
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
