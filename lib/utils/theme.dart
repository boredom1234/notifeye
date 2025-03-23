import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF6C63FF); // Modern Purple
  static const Color primaryDark = Color(0xFF4A44B0); // Darker Purple
  static const Color primaryLight = Color(0xFF8E87FF); // Light Purple

  // Secondary Colors
  static const Color secondaryColor = Color(0xFF00BFA6); // Teal
  static const Color secondaryLight = Color(0xFF33CCBB); // Light Teal
  static const Color secondaryDark = Color(0xFF008C7A); // Dark Teal

  // Dark Theme Colors
  static const Color backgroundColor = Color(0xFF121212); // Dark Background
  static const Color surfaceColor = Color(0xFF1E1E1E); // Dark Surface
  static const Color cardColor = Color(0xFF2C2C2C); // Dark Cards
  static const Color textPrimary = Color(0xFFFFFFFF); // White Text
  static const Color textSecondary = Color(0xFFB3B3B3); // Gray Text
  static const Color dividerColor = Color(0xFF3D3D3D); // Dark Divider

  // Alert Colors
  static const Color success = Color(0xFF00C853); // Bright Green
  static const Color warning = Color(0xFFFFD600); // Bright Yellow
  static const Color error = Color(0xFFFF5252); // Bright Red
  static const Color info = Color(0xFF40C4FF); // Bright Blue

  // Text Colors
  static const Color textColor = Color(0xFFFFFFFF);
  static const Color textLightColor = Color(0xFFB3B3B3);
  static const Color textDarkColor = Color(0xFF000000);

  // Text Styles
  static final headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0.25,
  );

  static final headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0,
  );

  static final titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.15,
  );

  static final titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static final titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static final bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static final bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    letterSpacing: 0.25,
  );

  static final bodySmall = TextStyle(
    fontSize: 12,
    color: textPrimary,
  );

  // Button Styles
  static final primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: textPrimary,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 4,
  );

  static final secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: cardColor,
    foregroundColor: primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    side: BorderSide(color: primaryColor),
    elevation: 2,
  );

  // Card Styles
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Input Decoration
  static final inputDecoration = InputDecoration(
    filled: true,
    fillColor: cardColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: dividerColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: dividerColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: primaryColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: error),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    hintStyle: bodyMedium.copyWith(color: textSecondary),
  );

  // App Bar Theme
  static AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: surfaceColor,
    foregroundColor: textPrimary,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: primaryColor),
    titleTextStyle: TextStyle(
      color: textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
    ),
  );

  // Bottom Navigation Bar Theme
  static final bottomNavBarTheme = BottomNavigationBarThemeData(
    backgroundColor: surfaceColor,
    selectedItemColor: primaryColor,
    unselectedItemColor: textSecondary,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );

  // Dialog Theme
  static final dialogTheme = DialogTheme(
    backgroundColor: cardColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    titleTextStyle: titleLarge,
    contentTextStyle: bodyMedium,
  );
}

class ThemeHelper {
  InputDecoration textInputDecoration(
      [String lableText = "", String hintText = ""]) {
    return AppTheme.inputDecoration.copyWith(
      labelText: lableText,
      hintText: hintText,
      labelStyle: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimary),
      hintStyle: AppTheme.bodyMedium,
    );
  }

  InputDecoration textInputDecoReport(
      [String hintText = "", Widget? suffixIcon, Color? fillColor]) {
    return AppTheme.inputDecoration.copyWith(
      hintText: hintText,
      suffixIcon: suffixIcon,
      fillColor: fillColor ?? AppTheme.cardColor,
    );
  }

  BoxDecoration inputBoxDecorationShaddow() {
    return BoxDecoration(boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 4),
      )
    ]);
  }

  BoxDecoration buttonBoxDecoration(BuildContext context,
      [String color1 = "", String color2 = ""]) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color1.isNotEmpty ? HexColor(color1) : AppTheme.primaryColor,
          color2.isNotEmpty ? HexColor(color2) : AppTheme.primaryDark,
        ],
      ),
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, 4),
            blurRadius: 8.0)
      ],
    );
  }

  BoxDecoration buttonblackBoxDecoration(BuildContext context,
      [String color1 = "", String color2 = ""]) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color1.isNotEmpty ? HexColor(color1) : AppTheme.cardColor,
          color2.isNotEmpty ? HexColor(color2) : AppTheme.surfaceColor,
        ],
      ),
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, 4),
            blurRadius: 8.0)
      ],
    );
  }

  ButtonStyle buttonStyle() {
    return AppTheme.primaryButtonStyle.copyWith(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  AlertDialog alartDialog(String title, String content, BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.cardColor,
      title: Text(title, style: AppTheme.titleLarge),
      content: Text(content, style: AppTheme.bodyMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      actions: [
        TextButton(
          child: Text(
            "OK",
            style: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryColor),
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
                AppTheme.primaryColor.withOpacity(0.1)),
            foregroundColor: MaterialStateProperty.all(AppTheme.primaryColor),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class LoginFormStyle {}
