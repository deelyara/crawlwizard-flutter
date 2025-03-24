import 'package:flutter/material.dart';

class AppTheme {
  // Primary Easyling color
  static const Color primaryColor = Color(0xFF266DAF);

  // Define color scheme
  static final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: primaryColor,
    brightness: Brightness.light,
    primary: primaryColor, // Force exact primary color
  );

  // Typography
  static final TextTheme textTheme = TextTheme(
    headlineLarge: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 28,
      letterSpacing: -0.5,
      color: colorScheme.onSurface,
    ),
    headlineMedium: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 24,
      letterSpacing: -0.5,
      color: colorScheme.onSurface,
    ),
    headlineSmall: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      letterSpacing: -0.25,
      color: colorScheme.onSurface,
    ),
    titleLarge: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 18,
      letterSpacing: 0,
      color: colorScheme.onSurface,
    ),
    titleMedium: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      letterSpacing: 0,
      color: colorScheme.onSurface,
    ),
    titleSmall: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      letterSpacing: 0,
      color: colorScheme.onSurface,
    ),
    bodyLarge: TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 16,
      letterSpacing: 0.15,
      color: colorScheme.onSurface.withOpacity(0.9),
    ),
    bodyMedium: TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      letterSpacing: 0.15,
      color: colorScheme.onSurface.withOpacity(0.9),
    ),
    bodySmall: TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 12,
      letterSpacing: 0.1,
      color: colorScheme.onSurfaceVariant,
    ),
    labelLarge: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 14,
      letterSpacing: 0.1,
      color: colorScheme.primary,
    ),
  );

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true, // Enable Material Design 3
    colorScheme: colorScheme,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: primaryColor,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleMedium?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: primaryColor, size: 22),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.8), width: 1),
      ),
      color: colorScheme.surface,
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        textStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: 0.1,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: primaryColor),
        textStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: 0.1,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: 0.1,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      isDense: true,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      hintStyle: TextStyle(
        color: colorScheme.onSurface.withOpacity(0.5),
        fontSize: 14,
      ),
      labelStyle: TextStyle(
        color: colorScheme.onSurface.withOpacity(0.7),
        fontSize: 14,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.transparent;
      }),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.grey;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.white;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor.withOpacity(0.4);
        }
        return Colors.grey.withOpacity(0.3);
      }),
      trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      dense: true,
      titleTextStyle: textTheme.bodyLarge,
      subtitleTextStyle: textTheme.bodySmall,
    ),
    dividerTheme: const DividerThemeData(space: 16, thickness: 1),
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surfaceVariant,
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: primaryColor,
      unselectedLabelColor: Colors.grey,
      indicator: BoxDecoration(
        border: Border(bottom: BorderSide(color: primaryColor, width: 2)),
      ),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      textColor: primaryColor,
      iconColor: primaryColor,
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryColor,
      inactiveTrackColor: colorScheme.surfaceVariant,
      thumbColor: primaryColor,
      overlayColor: primaryColor.withOpacity(0.2),
      valueIndicatorColor: primaryColor,
      valueIndicatorTextStyle: const TextStyle(color: Colors.white),
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: TextStyle(color: colorScheme.onInverseSurface),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    scaffoldBackgroundColor: colorScheme.background,
    bottomSheetTheme: BottomSheetThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: colorScheme.surface,
    ),
  );
}
