import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../poetry/models.dart';

class AajKaShairCard extends StatelessWidget {
  const AajKaShairCard({
    super.key,
    required this.quote,
    required this.onTap,
  });

  final QuoteRow quote;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              Text(
                quote.teaserLine1 ?? '',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: AppTextStyles.nastaliq(
                  fontSize: 20,
                  height: 2.1,
                  color: colors.text,
                ),
              ),
              if (quote.teaserLine2 != null)
                Text(
                  quote.teaserLine2!,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.nastaliq(
                    fontSize: 20,
                    height: 2.1,
                    color: colors.text,
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                locale.pick(
                  urdu: quote.poetNameUrdu,
                  english: quote.poetNameEnglish ?? '',
                ),
                textAlign: TextAlign.center,
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
      ),
    );
  }
}

String formatQuoteStamp(String isoDate) {
  final parsed = DateTime.tryParse(isoDate) ?? DateTime.now();
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final now = DateTime.now();
  final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
  final minute = now.minute.toString().padLeft(2, '0');
  final suffix = now.hour >= 12 ? 'PM' : 'AM';
  return '${days[parsed.weekday - 1]} ${months[parsed.month - 1]} ${parsed.day.toString().padLeft(2, '0')}, ${parsed.year} $hour:$minute $suffix';
}
