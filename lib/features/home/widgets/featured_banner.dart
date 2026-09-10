import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../poetry/models.dart';
import 'auto_page_carousel.dart';

class FeaturedBanner extends StatelessWidget {
  const FeaturedBanner({
    super.key,
    required this.banners,
    required this.onTap,
  });

  final List<BannerRow> banners;
  final ValueChanged<BannerRow> onTap;

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) return const SizedBox.shrink();
    return AutoPageCarousel(
      itemCount: banners.length,
      itemBuilder: (context, index) {
        final banner = banners[index];
        return _BannerCard(
          banner: banner,
          onTap: () => onTap(banner),
        );
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner, required this.onTap});

  final BannerRow banner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final bookName = locale.pick(
      urdu: banner.bookTitleUrdu ?? banner.title ?? 'تم',
      english: banner.bookTitleEnglish ?? 'Tum',
    );
    final poetName = locale.pick(
      urdu: banner.poetNameUrdu ?? 'احمد جمیل',
      english: banner.poetNameEnglish ?? 'Ahmad Jamil',
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(gradient: context.colors.bannerGradient),
            ),
            Positioned(
              right: -30,
              top: -20,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFB71C1C).withValues(alpha: 0.35),
                  ),
                  child: const SizedBox(width: 160, height: 160),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (banner.teaserLine1 != null)
                            Text(
                              banner.teaserLine1!,
                              textDirection: TextDirection.rtl,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.nastaliq(
                                fontSize: 16,
                                height: 2,
                                color: context.colors.onDark,
                              ),
                            ),
                          if (banner.teaserLine2 != null)
                            Text(
                              banner.teaserLine2!,
                              textDirection: TextDirection.rtl,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.nastaliq(
                                fontSize: 14,
                                height: 1.9,
                                color: context.colors.onDarkMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          bookName,
                          textDirection: TextDirection.rtl,
                          style: AppTextStyles.nastaliq(
                            fontSize: 34,
                            height: 1.5,
                            fontWeight: FontWeight.w700,
                            color: context.colors.onDark,
                          ),
                        ),
                        Text(
                          poetName,
                          textDirection: TextDirection.rtl,
                          style: AppTextStyles.nastaliq(
                            fontSize: 15,
                            color: context.colors.onDarkMuted,
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
