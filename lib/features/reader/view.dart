import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/locale/locale_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../favorites/controller.dart';
import '../poetry/models.dart';
import 'controller.dart';

void openReader(
  BuildContext context, {
  required List<PoetryCatalogRow> poems,
  int initialIndex = 0,
}) {
  if (poems.isEmpty) return;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ReaderScreen(poems: poems, initialIndex: initialIndex),
    ),
  );
}

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({
    super.key,
    required this.poems,
    this.initialIndex = 0,
  });

  final List<PoetryCatalogRow> poems;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReaderController(
        poems: poems,
        initialIndex: initialIndex,
      ),
      child: const _ReaderBody(),
    );
  }
}

class _ReaderBody extends StatelessWidget {
  const _ReaderBody();

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final reader = context.watch<ReaderController>();
    final favorites = context.watch<FavoritesController>();
    final colors = context.colors;
    final poem = reader.current;
    final strings = locale.strings;

    if (poem == null) {
      return const Scaffold(body: Center(child: Text('—')));
    }

    final title = locale.pick(urdu: poem.titleUrdu, english: poem.titleEnglish ?? '');
    final book = locale.pick(
      urdu: poem.bookTitleUrdu ?? '',
      english: poem.bookTitleEnglish ?? '',
    );
    final poet = locale.pick(
      urdu: poem.poetNameUrdu,
      english: poem.poetNameEnglish ?? '',
    );
    final category = locale.pick(
      urdu: poem.categoryNameUrdu,
      english: poem.categoryNameEnglish,
    );
    final favorited = favorites.isFavorite(poem.id);
    final body = reader.body;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.chevron_left, size: 28),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.nastaliq(
                          fontSize: 18,
                          height: 1.7,
                          color: colors.text,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => favorites.toggle(poem.id),
                      icon: Icon(
                        favorited ? Icons.favorite : Icons.favorite_border,
                        color: favorited ? Colors.redAccent : colors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    '${reader.index + 1}',
                    style: AppTextStyles.ui(fontSize: 14, color: colors.textMuted),
                  ),
                  const Spacer(),
                  Text(
                    book,
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.nastaliq(
                      fontSize: 14,
                      height: 1.7,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: body.isEmpty
                  ? Center(
                      child: Text(
                        '—',
                        style: AppTextStyles.nastaliq(
                          fontSize: 22,
                          color: colors.textMuted,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            body,
                            textAlign: reader.align.textAlign,
                            textDirection: TextDirection.rtl,
                            style: AppTextStyles.nastaliq(
                              fontSize: reader.fontSize.fontSize,
                              height: reader.fontSize.lineHeight,
                              color: colors.text,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          strings.attribution(
                            poet: poet,
                            book: book,
                            category: category,
                          ),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: AppTextStyles.nastaliq(
                            fontSize: 13,
                            color: colors.textMuted,
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
            ),
            _ReaderToolbar(poet: poet, book: book),
          ],
        ),
      ),
    );
  }
}

class _ReaderToolbar extends StatelessWidget {
  const _ReaderToolbar({required this.poet, required this.book});

  final String poet;
  final String book;

  @override
  Widget build(BuildContext context) {
    final reader = context.watch<ReaderController>();
    final strings = context.watch<LocaleController>().strings;
    final colors = context.colors;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                IconButton(
                  onPressed: reader.hasPrevious ? reader.previous : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final align in BodyAlign.values)
                        _AlignButton(
                          align: align,
                          selected: reader.align == align,
                          onTap: () => reader.setAlign(align),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: reader.hasNext ? reader.next : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                for (final size in ReaderFontSize.values)
                  _SizeButton(
                    size: size,
                    selected: reader.fontSize == size,
                    onTap: () => reader.setFontSize(size),
                  ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    await reader.copy(poet: poet, book: book);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(strings.copied)),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_outlined),
                ),
                IconButton(
                  onPressed: () => reader.share(poet: poet, book: book),
                  icon: const Icon(Icons.ios_share),
                ),
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.text, width: 1.2),
                  ),
                  child: Text(
                    '${reader.index + 1}',
                    style: AppTextStyles.ui(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Slider(
          value: reader.progress,
          onChanged: reader.poems.length <= 1
              ? null
              : (value) {
                  final next = (value * (reader.poems.length - 1)).round();
                  reader.goTo(next);
                },
        ),
      ],
    );
  }
}

class _AlignButton extends StatelessWidget {
  const _AlignButton({
    required this.align,
    required this.selected,
    required this.onTap,
  });

  final BodyAlign align;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
      icon: Icon(
        align.icon,
        size: 22,
        color: selected ? colors.accent : colors.textMuted,
      ),
    );
  }
}

class _SizeButton extends StatelessWidget {
  const _SizeButton({
    required this.size,
    required this.selected,
    required this.onTap,
  });

  final ReaderFontSize size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.text : colors.canvas,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? colors.text : colors.border,
            ),
          ),
          child: Text(
            size.label,
            style: AppTextStyles.ui(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? colors.canvas : colors.text,
            ),
          ),
        ),
      ),
    );
  }
}
