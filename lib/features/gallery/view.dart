import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/haptics/app_haptics.dart';
import '../../core/locale/locale_controller.dart';
import '../../core/shared/widgets/catalog_placeholders.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../poetry/controller.dart';
import '../reader/view.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final catalog = context.watch<CatalogController>();
    final colors = context.colors;
    final showSkeleton = catalog.showSkeleton;
    final cards = showSkeleton
        ? CatalogPlaceholders.poems(count: 6)
        : catalog.latestGallery;

    return ColoredBox(
      color: colors.canvas,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                locale.strings.gallery,
                style: AppTextStyles.heading(
                  locale.isUrdu,
                  fontSize: 22,
                  color: colors.text,
                ),
              ),
            ),
            Expanded(
              child: !showSkeleton && cards.isEmpty
                  ? Center(
                      child: Text(
                        locale.strings.emptyGallery,
                        style: AppTextStyles.label(
                          locale.isUrdu,
                          color: colors.textMuted,
                        ),
                      ),
                    )
                  : Skeletonizer(
                      enabled: showSkeleton,
                      child: ScrollHaptics(
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          physics: const ClampingScrollPhysics(),
                          cacheExtent: 400,
                          addAutomaticKeepAlives: false,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.78,
                          ),
                          itemCount: cards.length,
                          itemBuilder: (context, index) {
                            final poem = cards[index];
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: showSkeleton
                                  ? null
                                  : () => openReader(
                                        context,
                                        poems: cards,
                                        initialIndex: index,
                                      ),
                              child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  border: Border.all(color: colors.border),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      poem.teaserLine1 ?? poem.titleUrdu,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.rtl,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.nastaliq(
                                        fontSize: 15,
                                        height: 2,
                                        color: colors.text,
                                      ),
                                    ),
                                    if (poem.teaserLine2 != null)
                                      Text(
                                        poem.teaserLine2!,
                                        textAlign: TextAlign.center,
                                        textDirection: TextDirection.rtl,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.nastaliq(
                                          fontSize: 15,
                                          height: 2,
                                          color: colors.textMuted,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
