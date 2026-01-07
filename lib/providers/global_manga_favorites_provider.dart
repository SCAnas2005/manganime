import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/like_storage_provider.dart';
import 'package:flutter_application_1/providers/manga_cache_provider.dart';
import 'package:flutter_application_1/providers/manga_repository_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';

class GlobalMangaFavoritesProvider extends ChangeNotifier {
  final JikanService _jikan = JikanService();
  MangaRepository get mangaRepository => MangaRepository(api: _jikan);

  // La liste des objets Manga complets pour l'affichage dans l'onglet Favoris
  List<Manga> _loadedFavoriteMangas = [];
  List<Manga> get loadedFavoriteMangas => _loadedFavoriteMangas;

  // Une liste simple des IDs pour vérifier rapidement si un manga est liké
  // C'est crucial pour la performance des AnimeCard
  final Set<int> _likedIds = {};

  bool isLoading = true;

  GlobalMangaFavoritesProvider() {
    _initialLoad();
  }

  // Chargement initial au démarrage de l'app
  Future<void> _initialLoad() async {
    isLoading = true;
    notifyListeners();

    // 1. On charge les IDs depuis le stockage synchrone
    final ids = LikeStorage.getIdMangaLiked();
    _likedIds.addAll(ids);

    // 2. On lance le chargement des objets complets en arrière-plan
    // On n'attend pas forcément la fin pour rendre l'UI interactive
    loadFullAnimeObjects();

    isLoading = false;
    notifyListeners();
  }

  // Méthode séparée pour charger les détails (pour la page favoris)
  Future<void> loadFullAnimeObjects() async {
    if (_loadedFavoriteMangas.length == _likedIds.length) return; // Déjà chargé

    final List<Manga> loaded = [];
    // Attention : faire des appels API en boucle peut être lent.
    // L'idéal serait une API qui accepte une liste d'IDs : getAnimesByIds([1, 5, 12])
    // Si Jikan ne le permet pas, ta boucle est la seule solution pour l'instant.
    for (int id in _likedIds) {
      try {
        final manga = await mangaRepository.getManga(id);
        if (manga != null) loaded.add(manga);
      } catch (e) {
        // Gérer l'erreur si un manga ne se charge pas
        debugPrint("Erreur chargement manga $id: $e");
      }
    }
    _loadedFavoriteMangas = loaded;
    notifyListeners();
  }

  // --- LA MÉTHODE CENTRALE ---

  // Vérifier si un manga est liké (très rapide grâce au Set)
  bool isAnimeLiked(int id) {
    return _likedIds.contains(id);
  }

  // La seule méthode à appeler pour liker/déliker
  void toggleFavorite(Manga manga) {
    final id = manga.id;
    final isCurrentlyLiked = _likedIds.contains(id);

    if (isCurrentlyLiked) {
      // On retire
      _likedIds.remove(id);
      _loadedFavoriteMangas.removeWhere((a) => a.id == id);
    } else {
      // On ajoute
      _likedIds.add(id);
      // On ajoute l'objet entier à la liste mémoire pour éviter un appel API
      _loadedFavoriteMangas.add(manga);
    }

    // Persistance : On appelle ton stockage
    LikeStorage.toggleMangaLike(id);

    if (!MangaCache.instance.exists(id)) {
      MangaCache.instance.save(manga);
    }

    // Notification : Tout le monde se met à jour !
    notifyListeners();
  }
}
