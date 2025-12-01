// global_favorites_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/providers/anime_cache_provider.dart';
import 'package:flutter_application_1/providers/anime_repository_provider.dart';
import 'package:flutter_application_1/providers/like_storage_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
// ... tes autres imports

class GlobalAnimeFavoritesProvider extends ChangeNotifier {
  final JikanService _jikan = JikanService();
  AnimeRepository get animeRepository => AnimeRepository(api: _jikan);

  // La liste des objets Anime complets pour l'affichage dans l'onglet Favoris
  List<Anime> _loadedFavoriteAnimes = [];
  List<Anime> get loadedFavoriteAnimes => _loadedFavoriteAnimes;

  // Une liste simple des IDs pour vérifier rapidement si un anime est liké
  // C'est crucial pour la performance des AnimeCard
  final Set<int> _likedIds = {};

  bool isLoading = true;

  GlobalAnimeFavoritesProvider() {
    _initialLoad();
  }

  // Chargement initial au démarrage de l'app
  Future<void> _initialLoad() async {
    isLoading = true;
    notifyListeners();

    // 1. On charge les IDs depuis le stockage synchrone
    final ids = LikeStorage.getIdAnimeLiked();
    _likedIds.addAll(ids);

    // 2. On lance le chargement des objets complets en arrière-plan
    // On n'attend pas forcément la fin pour rendre l'UI interactive
    loadFullAnimeObjects();

    isLoading = false;
    notifyListeners();
    debugPrint("_initialLoad() : Loading favorites animes $_likedIds");
  }

  // Méthode séparée pour charger les détails (pour la page favoris)
  Future<void> loadFullAnimeObjects() async {
    if (_loadedFavoriteAnimes.length == _likedIds.length) return; // Déjà chargé

    final List<Anime> loaded = [];
    // Attention : faire des appels API en boucle peut être lent.
    // L'idéal serait une API qui accepte une liste d'IDs : getAnimesByIds([1, 5, 12])
    // Si Jikan ne le permet pas, ta boucle est la seule solution pour l'instant.
    for (int id in _likedIds) {
      try {
        final anime = await animeRepository.getAnime(id);
        loaded.add(anime);
      } catch (e) {
        // Gérer l'erreur si un anime ne se charge pas
        debugPrint("Erreur chargement anime $id: $e");
      }
    }
    _loadedFavoriteAnimes = loaded;
    notifyListeners();
  }

  // --- LA MÉTHODE CENTRALE ---

  // Vérifier si un anime est liké (très rapide grâce au Set)
  bool isAnimeLiked(int id) {
    return _likedIds.contains(id);
  }

  // La seule méthode à appeler pour liker/déliker
  void toggleFavorite(Anime anime) {
    final id = anime.id;
    final isCurrentlyLiked = _likedIds.contains(id);

    if (isCurrentlyLiked) {
      // On retire
      _likedIds.remove(id);
      _loadedFavoriteAnimes.removeWhere((a) => a.id == id);
    } else {
      // On ajoute
      _likedIds.add(id);
      // On ajoute l'objet entier à la liste mémoire pour éviter un appel API
      _loadedFavoriteAnimes.add(anime);
    }

    // Persistance : On appelle ton stockage
    LikeStorage.toggleAnimeLike(id);

    if (!AnimeCache.instance.exists(id)) {
      AnimeCache.instance.save(anime);
    }

    // Notification : Tout le monde se met à jour !
    notifyListeners();
  }
}

// // generic_favorites_provider.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/models/identifiable.dart';

// // Définition de types pour les fonctions de chargement et de stockage
// typedef FetchItemCallback<T> = Future<T> Function(int id);
// typedef StorageCallback = Future<void> Function(int id);
// typedef GetStoredIdsCallback = List<int> Function();

// // Fonction pour vérifier si un item est en cache et le récupérer
// typedef GetFromCacheCallback<T> = T? Function(int id);
// // Fonction pour sauvegarder un item dans le cache
// typedef SaveToCacheCallback<T> = void Function(T item);

// // La classe devient générique : <T extends Identifiable>
// class GlobalFavoritesProvider<T extends Identifiable> extends ChangeNotifier {
//   // On injecte les dépendances spécifiques via le constructeur
//   final FetchItemCallback<T> _fetchItem; // Ex: animeRepo.getAnime(id)
//   final StorageCallback _toggleStorage; // Ex: LikeStorage.toggleAnimeLike(id)
//   final GetStoredIdsCallback _getStoredIds; // Ex: LikeStorage.getIdAnimeLiked()

//   // Les données, maintenant de type T
//   List<T> _loadedItems = [];
//   List<T> get loadedItems => _loadedItems;

//   final Set<int> _likedIds = {};

//   bool isLoading = true;

//   // Le constructeur prend les fonctions spécifiques en paramètre
//   GenericFavoritesProvider({
//     required FetchItemCallback<T> fetchItem,
//     required StorageCallback toggleStorage,
//     required GetStoredIdsCallback getStoredIds,
//   }) : _fetchItem = fetchItem,
//        _toggleStorage = toggleStorage,
//        _getStoredIds = getStoredIds {
//     _initialLoad();
//   }

//   Future<void> _initialLoad() async {
//     isLoading = true;
//     notifyListeners();

//     // Utilise la fonction injectée
//     final ids = _getStoredIds();
//     _likedIds.addAll(ids);

//     // Lance le chargement complet
//     loadFullItems();

//     isLoading = false;
//     notifyListeners();
//   }

//   Future<void> loadFullItems() async {
//     if (_loadedItems.length == _likedIds.length) return;

//     final List<T> loaded = [];
//     for (int id in _likedIds) {
//       try {
//         // Utilise la fonction de fetch injectée
//         final item = await _fetchItem(id);
//         loaded.add(item);
//       } catch (e) {
//         debugPrint("Erreur chargement item $id: $e");
//       }
//     }
//     _loadedItems = loaded;
//     notifyListeners();
//   }

//   // --- MÉTHODES PUBLIQUES ---

//   bool isItemLiked(int id) {
//     return _likedIds.contains(id);
//   }

//   void toggleFavorite(T item) {
//     final id = item.id; // On accède à l'id grâce à l'interface Identifiable
//     final isCurrentlyLiked = _likedIds.contains(id);

//     if (isCurrentlyLiked) {
//       _likedIds.remove(id);
//       _loadedItems.removeWhere((i) => i.id == id);
//     } else {
//       _likedIds.add(id);
//       _loadedItems.add(item);
//     }

//     // Utilise la fonction de stockage injectée
//     _toggleStorage(id);
//     notifyListeners();
//   }
// }
