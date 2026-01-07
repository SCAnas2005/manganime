import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // ===========================================================================
  // THÈME CLAIR (LIGHT)
  // ===========================================================================
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundLight,

    // Définition des couleurs principales
    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      surface: AppColors.cardLight,
      onSurface: AppColors.textLight,
      background: AppColors.backgroundLight,
      // outline: AppColors.dividerLight,
    ),

    // Barre d'application
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textLight,
      ),
      iconTheme: IconThemeData(color: AppColors.textLight),
    ),

    // Cartes (Card)
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Switchs (Mise à jour WidgetStateProperty)
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accent;
        }
        return Colors.grey.shade300;
      }),
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
  );

  // ===========================================================================
  // THÈME SOMBRE (DARK)
  // ===========================================================================
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,

    // Couleurs principales
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.cardDark,
      onSurface: AppColors.textDark,
      background: AppColors.backgroundDark,
      outline: AppColors.dividerDark,
    ),

    // Barre d'application
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      iconTheme: IconThemeData(color: AppColors.textDark),
    ),

    // Cartes (Card)
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Switchs (Mise à jour WidgetStateProperty)
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accent;
        }
        return AppColors.cardDark;
      }),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.black;
        }
        return Colors.grey;
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),

    // ListTiles
    listTileTheme: const ListTileThemeData(
      tileColor: Colors.transparent,
      textColor: AppColors.textDark,
      iconColor: AppColors.textDark,
    ),

    // Dividers
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerDark,
      thickness: 1,
    ),
  );
}
