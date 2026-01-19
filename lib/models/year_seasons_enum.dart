/// Représente les différentes saisons de diffusion.
///
/// Utilisé notamment pour filtrer ou catégoriser
/// les animes en fonction de leur période de sortie.
enum Season { winter, spring, summer, fall }

/// Extension utilitaire pour l'énumération [Season].
///
/// Elle fournit une clé texte correspondant
/// au nom de la saison, utilisable pour des clés d'API
/// ou des identifiants internes.
extension SeasonExtension on Season {
  String get key => toString().split(".").last;
}
