import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/locale/locale_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/theme_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final theme = context.watch<ThemeController>();
    final auth = context.watch<AuthController>();
    final colors = context.colors;
    final strings = locale.strings;
    final profile = auth.profile;
    final signedIn = auth.isSignedIn;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: colors.surface,
              backgroundImage: profile?.avatarUrl != null
                  ? CachedNetworkImageProvider(profile!.avatarUrl!)
                  : null,
              child: profile?.avatarUrl == null
                  ? Icon(Icons.person, size: 40, color: colors.text)
                  : null,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            signedIn
                ? (profile?.visibleName.isNotEmpty == true
                    ? profile!.visibleName
                    : strings.appName)
                : strings.guestName,
            textAlign: TextAlign.center,
            style: AppTextStyles.heading(
              locale.isUrdu,
              fontSize: 24,
              color: colors.text,
            ),
          ),
          if (signedIn && (profile?.email?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 4),
            Text(
              profile!.email!,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: AppTextStyles.ui(fontSize: 13, color: colors.textMuted),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            signedIn ? strings.signedInHint : strings.guestHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.label(
              locale.isUrdu,
              fontSize: 13,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          if (signedIn)
            _SettingCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.logout, color: colors.error),
                title: Text(
                  strings.signOut,
                  style: AppTextStyles.heading(
                    locale.isUrdu,
                    fontSize: 16,
                    color: colors.text,
                  ),
                ),
                onTap: auth.isBusy ? null : () => auth.signOut(),
              ),
            )
          else
            _GoogleSignInButton(
              loading: auth.isBusy,
              label: strings.signInWithGoogle,
              onPressed: () => _signIn(context),
            ),
          const SizedBox(height: 28),
          _SettingCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    strings.language,
                    style: AppTextStyles.heading(
                      locale.isUrdu,
                      fontSize: 16,
                      color: colors.text,
                    ),
                  ),
                ),
                Text(
                  strings.urduLabel,
                  style: AppTextStyles.nastaliq(
                    fontSize: 14,
                    color: locale.isUrdu ? colors.accent : colors.textMuted,
                    height: 1.6,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: !locale.isUrdu,
                  onChanged: locale.setEnglish,
                ),
                const SizedBox(width: 8),
                Text(
                  strings.englishLabel,
                  style: AppTextStyles.ui(
                    fontSize: 14,
                    color: locale.isUrdu ? colors.textMuted : colors.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SettingCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    strings.theme,
                    style: AppTextStyles.heading(
                      locale.isUrdu,
                      fontSize: 16,
                      color: colors.text,
                    ),
                  ),
                ),
                Text(
                  strings.lightTheme,
                  style: AppTextStyles.label(
                    locale.isUrdu,
                    color: theme.isDark ? colors.textMuted : colors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: theme.isDark,
                  onChanged: (enabled) => theme.setDark(enabled),
                ),
                const SizedBox(width: 8),
                Text(
                  strings.darkTheme,
                  style: AppTextStyles.label(
                    locale.isUrdu,
                    color: theme.isDark ? colors.accent : colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signIn(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final strings = context.read<LocaleController>().strings;
    final colors = context.colors;
    try {
      await context.read<AuthController>().signInWithGoogle();
    } catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${strings.signInFailed}: $error',
            style: AppTextStyles.ui(color: Colors.white),
          ),
          backgroundColor: colors.error,
        ),
      );
    }
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.label,
    required this.onPressed,
    required this.loading,
  });

  final String label;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: colors.surface,
          side: BorderSide(color: colors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: loading
            ? Skeletonizer(
                enabled: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _GoogleMark(),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.heading(
                          context.watch<LocaleController>().isUrdu,
                          fontSize: 16,
                          color: colors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _GoogleMark(),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading(
                        context.watch<LocaleController>().isUrdu,
                        fontSize: 16,
                        color: colors.text,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF4285F4),
          height: 1,
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}
