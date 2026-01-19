/// Sections disponibles pour l'affichage des animes.
///
/// Chaque valeur représente un type de classement
/// ou de filtrage des animes.
enum AnimeSections { popular, airing, mostLiked }

/// Sections disponibles pour l'affichage des mangas.
///
/// Chaque valeur représente un type de classement
/// ou de filtrage des mangas.
enum MangaSections { popular, publishing, mostLiked }

/// Extension utilitaire pour [AnimeSections].
///
/// Elle fournit une clé texte correspondant
/// au nom de la section, utilisable par exemple
/// pour des clés d'API ou des identifiants internes.
extension AnimeSectionExtension on AnimeSections {
  String get key => toString().split(".").last;
}

/// Extension utilitaire pour [MangaSections].
///
/// Elle fournit une clé texte correspondant
/// au nom de la section, utilisable par exemple
/// pour des clés d'API ou des identifiants internes.
extension MangaSectionExtension on MangaSections {
  String get key => toString().split(".").last;
}
