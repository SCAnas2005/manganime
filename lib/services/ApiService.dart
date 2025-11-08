import 'package:flutter_application_1/models/AnimeDetail.dart';
import 'package:flutter_application_1/models/anime.dart';

/// Interface abstraite définissant la structure de base pour tout service d’API
/// utilisé pour récupérer et convertir les données d’animes.
///
/// Cette classe doit être implémentée par tout service spécifique (ex: `JikanService`,
/// `AniListService`) afin d’assurer une interface commune à l’ensemble du code.
///
/// Chaque service API devra :
//// - Définir son `baseUrl`
/// - Implémenter les appels pour obtenir les animes les plus populaires (`getTopAnime`)
/// - Implémenter la récupération des détails d’un anime (`getFullDetailAnime`)
/// - Fournir les fonctions de conversion JSON → modèles (`jsonToAnime`, `jsonToAnimeDetail`)
///
/// Exemple d’utilisation :
/// ```dart
/// final api = JikanService();
/// final topAnimes = await api.getTopAnime();
/// final details = await api.getFullDetailAnime(topAnimes.first.id);
/// ```
abstract class ApiService {
  /// URL de base de l’API (exemple : `https://api.jikan.moe/v4`).
  String get baseUrl;

  /// Récupère la liste des animes les plus populaires depuis l’API.
  ///
  /// Retourne une [Future] contenant une liste d’objets [Anime].
  /// En cas d’erreur réseau ou d’erreur JSON, une exception doit être levée.
  Future<List<Anime>> getTopAnime();

  /// Récupère toutes les informations détaillées concernant un anime spécifique.
  ///
  /// [id] correspond à l’identifiant unique de l’anime dans l’API.
  /// Retourne un objet [AnimeDetail] contenant les informations complètes.
  Future<AnimeDetail> getFullDetailAnime(int id);

  /// Convertit une réponse JSON d’un anime basique (liste, recherche, top, etc.)
  /// en un objet [Anime].
  ///
  /// Doit être implémentée de manière spécifique à chaque API.
  Anime jsonToAnime(Map<String, dynamic> json);

  /// Convertit une réponse JSON détaillée d’un anime en un objet [AnimeDetail].
  ///
  /// Utilisée pour le parsing des résultats d’un appel détaillé (`getFullDetailAnime`).
  AnimeDetail jsonToAnimeDetail(Map<String, dynamic> json);
}
