import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KColors {
  static const brown = Color(0xFF754A13);
  static const brownDark = Color(0xFF4C300D);
  static const ink = Color(0xFF271908);
  static const inkSoft = Color(0xFF514535);
  static const muted = Color(0xFF847563);
  static const grey = Color(0xFF7A6A5E);

  static const navy = Color(0xFF3A5482);
  static const navyDark = Color(0xFF2F4366);
  static const navyLight = Color(0xFF4B5F83);

  static const amber = Color(0xFFE59E2C);
  static const amberDisabled = Color(0xFFEFC78A);
  static const rust = Color(0xFFB5530F);
  static const rustDark = Color(0xFF8E3B0B);

  static const border = Color(0xFFE5CFB1);
  static const divider = Color(0xFFF1E4D0);
  static const cream = Color(0xFFFAF7F0);
  static const creamField = Color(0xFFFFF1E6);
  static const creamCard = Color(0xFFFFF7F0);
  static const peach = Color(0xFFFFE3CA);
  static const sand = Color(0xFFF4EBDB);
  static const iconBg = Color(0xFFFBE3B6);
  static const qtyBg = Color(0xFFFCE2B8);

  static const green = Color(0xFF2E7D32);
  static const greenBg = Color(0xFFDDF1D8);
  static const red = Color(0xFFD4372A);
  static const redBg = Color(0xFFFBDDD8);
  static const danger = Color(0xFFC62828);
  static const dangerBg = Color(0xFFFDE2E0);
}

/// Shortcut gaya teks (font Plus Jakarta Sans).
TextStyle ks(
  double size, {
  FontWeight w = FontWeight.w400,
  Color c = KColors.ink,
  double? h,
}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: w,
      color: c,
      height: h,
    );
