import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';
import '../locale/locale_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Lightweight alert helpers shared across features.
abstract final class ShowDialogs {
  static void snackBar(
    BuildContext context,
    String message, {
    bool long = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: long ? 6 : 3),
      ),
    );
  }

  static void editorAccess(BuildContext context) {
    final auth = context.read<AuthController>();
    if (!auth.hasEditPermission) return;

    final strings = context.read<LocaleController>().strings;
    final colors = context.colors;
    final message = auth.isSuperadmin
        ? strings.superadminAccessGranted
        : strings.poetEditorAccessGranted;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTextStyles.ui(color: Colors.white),
          ),
          backgroundColor: colors.primary,
          duration: const Duration(seconds: 4),
        ),
      );
  }

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
    Color? confirmColor,
  }) async {
    final locale = context.read<LocaleController>();
    final colors = context.colors;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            title,
            style: AppTextStyles.heading(
              locale.isUrdu,
              fontSize: 18,
              color: colors.text,
            ),
          ),
          content: Text(
            body,
            style: AppTextStyles.label(locale.isUrdu, color: colors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                locale.strings.cancel,
                style: AppTextStyles.label(locale.isUrdu, color: colors.textMuted),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                confirmLabel,
                style: AppTextStyles.label(
                  locale.isUrdu,
                  color: confirmColor ?? colors.accent,
                ),
              ),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  static Future<UnsavedDecision> unsaved(BuildContext context) async {
    final locale = context.read<LocaleController>();
    final colors = context.colors;
    final strings = locale.strings;
    final result = await showDialog<UnsavedDecision>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            strings.unsavedTitle,
            style: AppTextStyles.heading(
              locale.isUrdu,
              fontSize: 18,
              color: colors.text,
            ),
          ),
          content: Text(
            strings.unsavedBody,
            style: AppTextStyles.label(locale.isUrdu, color: colors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(UnsavedDecision.stay),
              child: Text(
                strings.cancel,
                style: AppTextStyles.label(locale.isUrdu, color: colors.textMuted),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(UnsavedDecision.discard),
              child: Text(
                strings.discardChanges,
                style: AppTextStyles.label(locale.isUrdu, color: colors.error),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(UnsavedDecision.save),
              child: Text(
                strings.savePoetry,
                style: AppTextStyles.label(locale.isUrdu, color: colors.accent),
              ),
            ),
          ],
        );
      },
    );
    return result ?? UnsavedDecision.stay;
  }
}

enum UnsavedDecision { save, discard, stay }
