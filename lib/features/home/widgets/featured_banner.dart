import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/haptics/app_haptics.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../poetry/models.dart';

class FeaturedBanner extends StatefulWidget {
  const FeaturedBanner({
    super.key,
    required this.banners,
    required this.onTap,
  });

  final List<BannerRow> banners;
  final ValueChanged<BannerRow> onTap;

  @override
  State<FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<FeaturedBanner> {
  PageController? _controller;

  @override
  void initState() {
    super.initState();
    _syncController();
  }

  @override
  void didUpdateWidget(covariant FeaturedBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length < 2 && widget.banners.length >= 2) {
      _syncController();
    } else if (oldWidget.banners.length >= 2 && widget.banners.length < 2) {
      _controller?.dispose();
      _controller = null;
    }
  }

  void _syncController() {
    if (widget.banners.length < 2) return;
    _controller ??= PageController(viewportFraction: 0.94);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    if (widget.banners.length == 1) {
      return SizedBox(
        height: 188,
        child: _BannerCard(
          banner: widget.banners.first,
          onTap: () => widget.onTap(widget.banners.first),
        ),
      );
    }

    return SizedBox(
      height: 188,
      child: ScrollHaptics(
        child: PageView.builder(
          itemCount: widget.banners.length,
          controller: _controller,
          itemBuilder: (context, index) {
            final banner = widget.banners[index];
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _BannerCard(
                banner: banner,
                onTap: () => widget.onTap(banner),
              ),
            );
          },
        ),
      ),
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
