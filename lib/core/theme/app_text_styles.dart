import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  static TextStyle nastaliq({
    double fontSize = 18,
    Color? color,
    double height = 2.2,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.notoNastaliqUrdu(
      fontSize: fontSize,
      color: color,
      height: height,
      fontWeight: fontWeight,
    );
  }

  static TextStyle ui({
    double fontSize = 14,
    Color? color,
    FontWeight fontWeight = FontWeight.w500,
    double height = 1.3,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: height,
    );
  }

  static TextStyle heading(bool urdu, {double fontSize = 20, Color? color}) {
    return urdu
        ? nastaliq(
            fontSize: fontSize,
            height: 1.8,
            fontWeight: FontWeight.w600,
            color: color,
          )
        : ui(fontSize: fontSize, fontWeight: FontWeight.w700, color: color);
  }

  static TextStyle label(bool urdu, {double fontSize = 13, Color? color}) {
    return urdu
        ? nastaliq(fontSize: fontSize, color: color, height: 1.8)
        : ui(fontSize: fontSize, color: color, fontWeight: FontWeight.w500);
  }
}
