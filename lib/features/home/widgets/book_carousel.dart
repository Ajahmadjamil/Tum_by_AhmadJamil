import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../poetry/models.dart';

class BookCarousel extends StatelessWidget {
  const BookCarousel({
    super.key,
    required this.books,
    required this.onTapBook,
  });

  final List<BookRow> books;
  final ValueChanged<BookRow> onTapBook;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();

    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final book = books[index];
          final title = locale.pick(
            urdu: book.titleUrdu,
            english: book.titleEnglish ?? '',
          );
          final poet = locale.pick(
            urdu: book.poetNameUrdu ?? '',
            english: book.poetNameEnglish ?? '',
          );
          return GestureDetector(
            onTap: () => onTapBook(book),
            child: SizedBox(
              width: 148,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (book.coverImageUrl != null &&
                              book.coverImageUrl!.isNotEmpty)
                            CachedNetworkImage(
                              imageUrl: book.coverImageUrl!,
                              fit: BoxFit.cover,
                            )
                          else
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: context.colors.bookGradient,
                              ),
                            ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0xCC000000),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    poet,
                                    textDirection: TextDirection.rtl,
                                    style: AppTextStyles.nastaliq(
                                      fontSize: 11,
                                      color: context.colors.onDarkMuted,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                  style: AppTextStyles.nastaliq(
                                    fontSize: 28,
                                    height: 1.5,
                                    fontWeight: FontWeight.w700,
                                    color: context.colors.onDark,
                                  ),
                                ),
                                const Spacer(),
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
                      fontSize: 14,
                      height: 1.6,
                      color: context.colors.text,
                    ),
                  ),
                  Text(
                    poet,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.nastaliq(
                      fontSize: 11,
                      color: context.colors.textMuted,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
