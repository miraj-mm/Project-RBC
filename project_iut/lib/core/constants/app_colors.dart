import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryRed = Color(0xFFE53E3E);
  static const Color darkRed = Color(0xFFC53030);
  static const Color lightRed = Color(0xFFFC8181);
  
  // Secondary Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9CA3AF);
  static const Color lightGrey = Color(0xFFF3F4F6);
  static const Color darkGrey = Color(0xFF374151);
  
  // Light Theme Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFF9FAFB);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Dark Theme Colors - Black & Grey Palette
  static const Color darkBackground = Color(0xFF000000);        // Pure black
  static const Color darkSurface = Color(0xFF000000);          // Pure black surface (for app bars)
  static const Color darkCard = Color(0xFF1E1E1E);             // Dark grey card
  static const Color darkTextPrimary = Color(0xFFFFFFFF);      // White text
  static const Color darkTextSecondary = Color(0xFFBBBBBB);    // Light grey text
  static const Color darkBorder = Color(0xFF333333);           // Border grey
  static const Color darkElevated = Color(0xFF2A2A2A);         // Elevated surface
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Blood Group Colors
  static const Color bloodGroupA = Color(0xFFFF6B6B);
  static const Color bloodGroupB = Color(0xFF4ECDC4);
  static const Color bloodGroupAB = Color(0xFF45B7D1);
  static const Color bloodGroupO = Color(0xFF96CEB4);
  
  // Button Colors
  static const Color buttonPrimary = primaryRed;
  static const Color buttonSecondary = Color(0xFFF3F4F6);
  static const Color buttonDisabled = Color(0xFFD1D5DB);
  
  // Input Colors
  static const Color inputBorder = Color(0xFFD1D5DB);
  static const Color inputFocused = primaryRed;
  static const Color inputBackground = Color(0xFFF9FAFB);
  
  // Theme-aware getters
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkBackground 
        : background;
  }
  
  static Color getCardBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkCard 
        : cardBackground;
  }
  
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkSurface 
        : white;
  }
  
  static Color getTextPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkTextPrimary 
        : textPrimary;
  }
  
  static Color getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkTextSecondary 
        : textSecondary;
  }
  
  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkBorder 
        : lightGrey;
  }
  
  static Color getElevatedSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkElevated 
        : white;
  }
}