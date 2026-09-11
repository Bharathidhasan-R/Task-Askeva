import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

enum ToastType { success, error, warning, info }

class AppToast {
  static void show({
    required String title,
    required String message,
    ToastType type = ToastType.info,
    SnackPosition position = SnackPosition.TOP,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color primaryColor;
    Color bgColor;
    Color borderColor;
    IconData icon;

    switch (type) {
      case ToastType.success:
        primaryColor = const Color(0xFF10B981); // Emerald 500
        bgColor = const Color(0xFF064E3B); // Dark rich Emerald
        borderColor = const Color(0xFF059669);
        icon = Icons.check_circle_rounded;
        break;
      case ToastType.error:
        primaryColor = const Color(0xFFEF4444); // Red 500
        bgColor = const Color(0xFF7F1D1D); // Dark rich Red
        borderColor = const Color(0xFFDC2626);
        icon = Icons.error_outline_rounded;
        break;
      case ToastType.warning:
        primaryColor = const Color(0xFFF59E0B); // Amber 500
        bgColor = const Color(0xFF78350F); // Dark rich Amber
        borderColor = const Color(0xFFD97706);
        icon = Icons.warning_amber_rounded;
        break;
      case ToastType.info:
        primaryColor = const Color(0xFF6366F1); // Indigo 500
        bgColor = const Color(0xFF1E1B4B); // Dark rich Indigo
        borderColor = const Color(0xFF4F46E5);
        icon = Icons.info_outline_rounded;
        break;
    }

    Get.rawSnackbar(
      snackPosition: position,
      duration: duration,
      backgroundColor: Colors.transparent,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.zero,
      overlayBlur: 0,
      snackStyle: SnackStyle.FLOATING,
      messageText: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0F172A).withValues(alpha: 0.96),
              bgColor.withValues(alpha: 0.45),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: borderColor.withValues(alpha: 0.6), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor.withValues(alpha: 0.4), width: 1),
              ),
              child: Icon(icon, color: primaryColor, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 11.5.sp,
                      color: Colors.white70,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: () => Get.closeCurrentSnackbar(),
              child: Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white38,
                  size: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void success(String title, String message, {SnackPosition position = SnackPosition.TOP}) {
    show(
      title: title,
      message: message,
      type: ToastType.success,
      position: position,
    );
  }

  static void error(String title, String message, {SnackPosition position = SnackPosition.TOP}) {
    show(
      title: title,
      message: message,
      type: ToastType.error,
      position: position,
    );
  }

  static void warning(String title, String message, {SnackPosition position = SnackPosition.TOP}) {
    show(
      title: title,
      message: message,
      type: ToastType.warning,
      position: position,
    );
  }

  static void info(String title, String message, {SnackPosition position = SnackPosition.TOP}) {
    show(
      title: title,
      message: message,
      type: ToastType.info,
      position: position,
    );
  }
}
