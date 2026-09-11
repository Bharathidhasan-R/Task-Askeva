import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskTheme {
  // Brand & Core Palette
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryDark = Color(0xFF3730A3); // Indigo 800
  static const Color primaryLight = Color(0xFFEEF2FF); // Indigo 50
  
  static const Color secondary = Color(0xFF0EA5E9); // Sky 500
  static const Color accent = Color(0xFF8B5CF6); // Purple 500

  // Status Colors
  static const Color statusAssigned = Color(0xFF3B82F6); // Blue
  static const Color statusAssignedBg = Color(0xFFEFF6FF);
  
  static const Color statusAccepted = Color(0xFF8B5CF6); // Purple
  static const Color statusAcceptedBg = Color(0xFFF5F3FF);

  static const Color statusInProgress = Color(0xFFF59E0B); // Amber
  static const Color statusInProgressBg = Color(0xFFFFFBEB);

  static const Color statusCompleted = Color(0xFF10B981); // Emerald
  static const Color statusCompletedBg = Color(0xFFECFDF5);

  // Priority Colors
  static const Color priorityUrgent = Color(0xFFEF4444); // Red 500
  static const Color priorityUrgentBg = Color(0xFFFEF2F2);
  
  static const Color priorityHigh = Color(0xFFF97316); // Orange 500
  static const Color priorityHighBg = Color(0xFFFFF7ED);

  static const Color priorityMedium = Color(0xFF3B82F6); // Blue 500
  static const Color priorityMediumBg = Color(0xFFEFF6FF);

  static const Color priorityLow = Color(0xFF64748B); // Slate 500
  static const Color priorityLowBg = Color(0xFFF8FAFC);

  // Background & Surface
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color cardSurface = Colors.white;
  static const Color surfaceElevated = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Borders
  static const Color borderSubtle = Color(0xFFE2E8F0); // Slate 200

  // Box Shadows
  static List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowGlow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.25),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF6366F1), Color(0xFF818CF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Typography
  static TextStyle headingBold({double size = 20, Color color = textPrimary}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.3,
      );

  static TextStyle headingSemiBold({double size = 16, Color color = textPrimary}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: -0.2,
      );

  static TextStyle bodyMedium({double size = 14, Color color = textPrimary}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle bodyRegular({double size = 13, Color color = textSecondary}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color,
      );
}
