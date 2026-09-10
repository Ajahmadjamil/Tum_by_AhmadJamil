import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/locale/locale_controller.dart';
import '../../core/shared/widgets/catalog_placeholders.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../home/widgets/kalam_poem_list.dart';
import '../poetry/controller.dart';

class CollectionView extends StatelessWidget {
  const CollectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final catalog = context.watch<CatalogController>();
    final showSkeleton = catalog.showSkeleton;
    final poems = showSkeleton && catalog.catalog.isEmpty
        ? CatalogPlaceholders.poems(count: 8)
        : catalog.catalog;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale.strings.appName,
          style: AppTextStyles.nastaliq(
            fontSize: 20,
            height: 1.7,
            color: context.colors.text,
          ),
        ),
      ),
      body: IgnorePointer(
        ignoring: showSkeleton,
        child: Skeletonizer(
          enabled: showSkeleton,
          child: KalamPoemList(
            poems: poems,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          ),
        ),
      ),
    );
  }
}
