import 'package:flutter/material.dart';

/// Paleta de colores de GuardIA
class AppColors {
  AppColors._();

  // Colores primarios (Azul oscuro principal)
  static const Color primaryBlue = Color(0xFF081221);
  static const Color primaryBlueDark = Color(0xFF040A14);
  static const Color primaryBlueLight = Color(0xFF122240);

  // Colores de acento (Cyan secundario)
  static const Color accentCyan = Color(0xFF00C6FF);
  static const Color accentCyanLight = Color(0xFF4DD8FF);

  // Variantes con alfa para gradientes y efectos
  static const Color primaryWithAlpha = Color(0xAA081221);
  static const Color accentWithAlpha = Color(0xAA00C6FF);

  // Colores de estado
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningYellow = Color(0xFFFFC107);
  static const Color errorRed = Color(0xFFF44336);
  static const Color infoBlue = Color(0xFF2196F3);

  // Grises (Light mode)
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Dark mode específicos
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);

  // Estado de cámaras
  static const Color cameraOnline = successGreen;
  static const Color cameraOffline = grey500;
  static const Color cameraMaintenance = warningYellow;

  // Prioridades de alertas
  static const Color priorityLow = infoBlue;
  static const Color priorityMedium = warningYellow;
  static const Color priorityHigh = accentCyan;
  static const Color priorityCritical = errorRed;
}
