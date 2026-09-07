import 'package:flutter/material.dart';

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
}
