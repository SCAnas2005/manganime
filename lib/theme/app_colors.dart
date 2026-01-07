import 'dart:ui';

class AppColors {
  // Couleur d'accentuation (Le vert "Lime" des images)
  static const accent = Color(0xFFC6FF00);

  // --- THÈME LIGHT ---
  static const backgroundLight = Color(
    0xFFF5F5F5,
  ); // Un gris très clair pour le fond
  static const cardLight = Color(0xFFFFFFFF); // Blanc pur pour les cartes
  static const textLight = Color(0xFF121212); // Noir profond pour le texte

  // --- THÈME DARK ---
  static const backgroundDark = Color(
    0xFF121212,
  ); // Noir presque total pour le fond
  static const cardDark = Color(
    0xFF1E1E1E,
  ); // Gris foncé pour les cartes (comme sur l'image)
  static const textDark = Color(0xFFFFFFFF); // Blanc pour le texte
  static const dividerDark = Color(0xFF2C2C2C); // Pour les traits de séparation
}
