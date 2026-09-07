import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'primary_cta.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.onBack,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.canvas,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.tipBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Could not get recipes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              if (message.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
              const SizedBox(height: 28),
              PrimaryCta(
                label: 'Try again',
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
              if (onBack != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onBack,
                  child: const Text('Back'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
