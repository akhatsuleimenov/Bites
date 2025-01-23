// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:bites/core/constants/app_colors.dart';

class TypographyStyles {
  /// fontSize: 32, lineHeight: 115%
  static TextStyle h1({Color? color}) {
    return TextStyle(
      fontFamily: 'YourFont',
      fontSize: 32,
      height: 1.15,
      color: color ?? AppColors.textPrimary,
      fontWeight: FontWeight.bold,
    );
  }

  /// fontSize: 16, lineHeight: 120%
  static TextStyle body({Color? color}) {
    return TextStyle(
      fontFamily: 'YourFont',
      fontSize: 16,
      height: 1.2,
      color: color ?? AppColors.textPrimary,
    );
  }

  /// fontSize: 16, lineHeight: 120%
  static TextStyle bodyBold({Color? color}) {
    return TextStyle(
      fontFamily: 'YourFont',
      fontSize: 16,
      height: 1.2,
      color: color ?? AppColors.textPrimary,
      fontWeight: FontWeight.bold,
    );
  }

  /// fontSize: 16, lineHeight: 120%
  static TextStyle bodyMedium({Color? color}) {
    return TextStyle(
      fontFamily: 'YourFont',
      fontSize: 16,
      height: 1.2,
      color: color ?? AppColors.textPrimary,
      fontWeight: FontWeight.w500,
    );
  }

  /// fontSize: 16, lineHeight: 120%
  static TextStyle bodyLight({Color? color}) {
    return TextStyle(
      fontFamily: 'YourFont',
      fontSize: 16,
      height: 1.2,
      color: color ?? AppColors.textPrimary,
      fontWeight: FontWeight.w300,
    );
  }

  /// fontSize: 12, lineHeight: 120%
  static TextStyle subtitle({Color? color}) {
    return TextStyle(
      fontFamily: 'YourFont',
      fontSize: 12,
      height: 1.2,
      color: color ?? AppColors.textSecondary,
    );
  }
}
