import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class IngredientChip extends StatelessWidget {
  const IngredientChip({
    super.key,
    required this.label,
    this.emoji,
    this.selected = false,
    this.onTap,
    this.onDeleted,
    this.showCheck = false,
  });

  final String label;
  final String? emoji;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.selectedSoft : AppColors.surface;
    final border = selected ? AppColors.selected : AppColors.border;
    final fg = selected ? AppColors.selected : AppColors.text;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: EdgeInsets.only(
            left: 12,
            right: onDeleted != null ? 6 : 12,
            top: 8,
            bottom: 8,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x143FA34D),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCheck && selected) ...[
                const Icon(Icons.check_circle, size: 16, color: AppColors.selected),
                const SizedBox(width: 6),
              ],
              if (emoji != null && emoji!.isNotEmpty) ...[
                Text(emoji!, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
              ),
              if (onDeleted != null) ...[
                const SizedBox(width: 2),
                InkWell(
                  onTap: onDeleted,
                  borderRadius: BorderRadius.circular(999),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 16, color: AppColors.textMuted),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
