import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/haptics/app_haptics.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({
    super.key,
    required this.onSearchChanged,
  });

  final ValueChanged<String> onSearchChanged;

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 80), () {
      widget.onSearchChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final colors = context.colors;
    final strings = locale.strings;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colors.searchFill,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: colors.textMuted, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: _onChanged,
                      textAlign: locale.isUrdu ? TextAlign.right : TextAlign.left,
                      style: locale.isUrdu
                          ? AppTextStyles.nastaliq(
                              fontSize: 14,
                              height: 1.6,
                              color: colors.text,
                            )
                          : AppTextStyles.ui(fontSize: 14, color: colors.text),
                      decoration: InputDecoration(
                        hintText: strings.searchHint,
                        hintStyle: locale.isUrdu
                            ? AppTextStyles.nastaliq(
                                fontSize: 14,
                                color: colors.textMuted,
                                height: 1.6,
                              )
                            : AppTextStyles.ui(
                                fontSize: 14,
                                color: colors.textMuted,
                              ),
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () => AppHaptics.selection(),
            icon: Icon(Icons.notifications_none, color: colors.text),
          ),
        ],
      ),
    );
  }
}
