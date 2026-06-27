import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/theme_service.dart';

// Extensión para acceder a los colores según el tema
extension AppColorsExtension on BuildContext {
  AppColorsTheme get colors => AppColors.of(this);
}

class AppColors {
  // ==================== CONSTRUCTOR Y GETTER ====================
  static AppColorsTheme of(BuildContext context) {
    // Obtener el estado del tema desde ThemeService
    final isDark = Get.find<ThemeService>().isDarkMode;
    return isDark ? dark() : light();
  }

  // ==================== MODO OSCURO ====================
  static AppColorsTheme dark() {
    return const AppColorsTheme(
      background: Color(0xFF0B1320),
      surface: Color(0xFF1C2541),
      surfaceVariant: Color(0xFF2A3357),
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFFB8C5D6),
      textTertiary: Color(0xFF6C7A8E),
      textHint: Color(0xFF4A5568),
      border: Color(0xFF2A3357),
      borderLight: Color(0xFF3A456B),
      shadow: Color(0x40000000),
      cardBackground: Color(0xFF1C2541),
      dialogBackground: Color(0xFF1C2541),
      bottomNavBackground: Color(0xFF1C2541),
      appBarBackground: Color(0xFF0B1320),
      primary: Color(0xFF5BC0BE),
      secondary: Color(0xFFFA7921),
      accent: Color(0xFFFDE74C),
      primaryLight: Color(0xFF8CD4D2),
      primaryDark: Color(0xFF3A8F8D),
      secondaryLight: Color(0xFFFF9A55),
      secondaryDark: Color(0xFFC45E1A),
      accentLight: Color(0xFFFFF17A),
      accentDark: Color(0xFFCBB83D),
      lost: Color(0xFFFA7921),
      found: Color(0xFF5BC0BE),
      adoption: Color(0xFFFDE74C),
      rescued: Color(0xFF8B5CF6),
      success: Color(0xFF10B981),
      urgent: Color(0xFFFA7921),
      like: Color(0xFFEF4444),
      warning: Color(0xFFFDE74C),
      error: Color(0xFFEF4444),
      info: Color(0xFF5BC0BE),
      pending: Color(0xFFFDE74C),
      inProgress: Color(0xFF5BC0BE),
      completed: Color(0xFF10B981),
      cancelled: Color(0xFFEF4444),
      primaryGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF5BC0BE), Color(0xFF3A8F8D)],
      ),
      secondaryGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFA7921), Color(0xFFC45E1A)],
      ),
      accentGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFDE74C), Color(0xFFCBB83D)],
      ),
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0B1320), Color(0xFF1C2541)],
      ),
      cardGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1C2541), Color(0xFF2A3357)],
      ),
      lostGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFA7921), Color(0xFFC45E1A)],
      ),
      foundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF5BC0BE), Color(0xFF3A8F8D)],
      ),
      adoptionGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFDE74C), Color(0xFFCBB83D)],
      ),
    );
  }

  // ==================== MODO CLARO ====================
  static AppColorsTheme light() {
    return const AppColorsTheme(
      background: Color(0xFFF5F7FA),
      surface: Color(0xFFFFFFFF),
      surfaceVariant: Color(0xFFF0F2F5),
      textPrimary: Color(0xFF1A2332),
      textSecondary: Color(0xFF4A5568),
      textTertiary: Color(0xFF8A95A8),
      textHint: Color(0xFFB0B8C8),
      border: Color(0xFFE2E8F0),
      borderLight: Color(0xFFCBD5E1),
      shadow: Color(0x1A000000),
      cardBackground: Color(0xFFFFFFFF),
      dialogBackground: Color(0xFFFFFFFF),
      bottomNavBackground: Color(0xFFFFFFFF),
      appBarBackground: Color(0xFFFFFFFF),
      primary: Color(0xFF5BC0BE),
      secondary: Color(0xFFFA7921),
      accent: Color(0xFFFDE74C),
      primaryLight: Color(0xFF8CD4D2),
      primaryDark: Color(0xFF3A8F8D),
      secondaryLight: Color(0xFFFF9A55),
      secondaryDark: Color(0xFFC45E1A),
      accentLight: Color(0xFFFFF17A),
      accentDark: Color(0xFFCBB83D),
      lost: Color(0xFFFA7921),
      found: Color(0xFF5BC0BE),
      adoption: Color(0xFFFDE74C),
      rescued: Color(0xFF8B5CF6),
      success: Color(0xFF10B981),
      urgent: Color(0xFFFA7921),
      like: Color(0xFFEF4444),
      warning: Color(0xFFFDE74C),
      error: Color(0xFFEF4444),
      info: Color(0xFF5BC0BE),
      pending: Color(0xFFFDE74C),
      inProgress: Color(0xFF5BC0BE),
      completed: Color(0xFF10B981),
      cancelled: Color(0xFFEF4444),
      primaryGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF5BC0BE), Color(0xFF3A8F8D)],
      ),
      secondaryGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFA7921), Color(0xFFC45E1A)],
      ),
      accentGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFDE74C), Color(0xFFCBB83D)],
      ),
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF5F7FA), Color(0xFFFFFFFF)],
      ),
      cardGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFF0F2F5)],
      ),
      lostGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFA7921), Color(0xFFC45E1A)],
      ),
      foundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF5BC0BE), Color(0xFF3A8F8D)],
      ),
      adoptionGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFDE74C), Color(0xFFCBB83D)],
      ),
    );
  }
}

// ==================== CLASE TEMA ====================
class AppColorsTheme {
  // Colores base
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  
  // Colores de texto
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textHint;
  
  // Bordes y sombras
  final Color border;
  final Color borderLight;
  final Color shadow;
  
  // Fondos
  final Color cardBackground;
  final Color dialogBackground;
  final Color bottomNavBackground;
  final Color appBarBackground;
  
  // Colores de resalte
  final Color primary;
  final Color secondary;
  final Color accent;
  
  // Variantes
  final Color primaryLight;
  final Color primaryDark;
  final Color secondaryLight;
  final Color secondaryDark;
  final Color accentLight;
  final Color accentDark;
  
  // Colores de estado
  final Color lost;
  final Color found;
  final Color adoption;
  final Color rescued;
  final Color success;
  final Color urgent;
  
  // Interacción
  final Color like;
  final Color warning;
  final Color error;
  final Color info;
  
  // Status
  final Color pending;
  final Color inProgress;
  final Color completed;
  final Color cancelled;
  
  // Gradientes
  final LinearGradient primaryGradient;
  final LinearGradient secondaryGradient;
  final LinearGradient accentGradient;
  final LinearGradient backgroundGradient;
  final LinearGradient cardGradient;
  final LinearGradient lostGradient;
  final LinearGradient foundGradient;
  final LinearGradient adoptionGradient;

  const AppColorsTheme({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textHint,
    required this.border,
    required this.borderLight,
    required this.shadow,
    required this.cardBackground,
    required this.dialogBackground,
    required this.bottomNavBackground,
    required this.appBarBackground,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.accentLight,
    required this.accentDark,
    required this.lost,
    required this.found,
    required this.adoption,
    required this.rescued,
    required this.success,
    required this.urgent,
    required this.like,
    required this.warning,
    required this.error,
    required this.info,
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.cancelled,
    required this.primaryGradient,
    required this.secondaryGradient,
    required this.accentGradient,
    required this.backgroundGradient,
    required this.cardGradient,
    required this.lostGradient,
    required this.foundGradient,
    required this.adoptionGradient,
  });
}