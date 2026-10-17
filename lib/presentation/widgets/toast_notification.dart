import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ToastNotification {
  static void show(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1700),
        width: 220,
        backgroundColor: isDark ? AppColors.darkText : AppColors.lightText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}
