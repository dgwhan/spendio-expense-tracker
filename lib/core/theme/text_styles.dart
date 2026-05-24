import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextStyles {
  TextStyles._();

  // display
  static TextStyle displayLarge({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: 36,
      fontWeight: fontWeight ?? FontWeight.bold,
      color: color,
      height: 1.2,
    );
  }

  static TextStyle displayMedium({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: 30,
      fontWeight: fontWeight ?? FontWeight.bold,
      color: color,
      height: 1.2,
    );
  }

  // heading
  static TextStyle heading1({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: 24,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color,
      height: 1.3,
    );
  }

  static TextStyle heading2({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: 20,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color,
      height: 1.3,
    );
  }

  static TextStyle heading3({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: 18,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color,
      height: 1.4,
    );
  }

  // body
  static TextStyle bodyLarge({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      height: 1.5,
    );
  }

  static TextStyle bodyMedium({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      height: 1.5,
    );
  }

  static TextStyle bodySmall({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      height: 1.4,
    );
  }

  // button
  static TextStyle button({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color,
      letterSpacing: 0.2,
    );
  }

  // caption
  static TextStyle caption({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      height: 1.3,
    );
  }
}