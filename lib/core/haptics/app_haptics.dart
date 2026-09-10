import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AppHaptics {
  static void selection() => HapticFeedback.selectionClick();

  static void light() => HapticFeedback.lightImpact();

  static void medium() => HapticFeedback.mediumImpact();

  static void heavy() => HapticFeedback.heavyImpact();
}

class ScrollHaptics extends StatelessWidget {
  const ScrollHaptics({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification &&
            notification.dragDetails != null) {
          AppHaptics.light();
        }
        return false;
      },
      child: child,
    );
  }
}
