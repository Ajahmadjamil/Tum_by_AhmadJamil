import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/alerts/show_dialogs.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/haptics/app_haptics.dart';
import '../../core/locale/locale_controller.dart';
import '../../core/theme/app_colors.dart';
import '../poetry/controller.dart';
import '../poetry/models.dart';

class PoemPopularButton extends StatelessWidget {
  const PoemPopularButton({super.key, required this.poem});

  final PoetryCatalogRow poem;

  @override
  Widget build(BuildContext context) {
    if (poem.isDraft) return const SizedBox.shrink();

    final auth = context.watch<AuthController>();
    if (!auth.canEditPoet(poem.poetId)) return const SizedBox.shrink();

    final strings = context.watch<LocaleController>().strings;
    final starred = poem.isPopular;
    return IconButton(
      tooltip: starred ? strings.unstarPoetry : strings.starPoetry,
      visualDensity: VisualDensity.compact,
      enableFeedback: false,
      onPressed: () async {
        AppHaptics.selection();
        try {
          await context.read<CatalogController>().setPopular(
                poem.id,
                !starred,
              );
        } catch (error) {
          if (!context.mounted) return;
          ShowDialogs.snackBar(context, '$error');
        }
      },
      icon: Icon(
        starred ? Icons.star : Icons.star_border,
        color: starred ? const Color(0xFFE0B44A) : context.colors.textMuted,
      ),
    );
  }
}
