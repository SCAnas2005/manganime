// ignore_for_file: constant_identifier_names

import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';
import 'package:flutter_application_1/models/manga.dart';

class UserprofileProvider {
  // Stats basées sur l'historique des likes
  final Map<Genres, int> animeGenreTagFrenquencies;
  final Map<Genres, int> mangaGenreTagFrenquencies;

  // Préférences explicites (venant des Settings)
  final List<Genres> preferredGenres;

  // CONFIGURATION DES POIDS
  // Combien de points vaut 1 like sur un anime ?
  static const double WEIGHT_PER_LIKE = 1.0;
  // Combien de points vaut le fait d'avoir coché le genre dans les paramètres ?
  // Ici, cocher un genre équivaut à avoir liké 5 animes de ce genre.
  static const double WEIGHT_PREFERRED_GENRE = 5.0;

  UserprofileProvider({
    required this.animeGenreTagFrenquencies,
    required this.mangaGenreTagFrenquencies,
    required this.preferredGenres,
  });

  factory UserprofileProvider.create({
    List<Anime>? likedAnimes,
    List<Manga>? likedMangas,
    List<Genres>? preferredGenres,
  }) {
    return UserprofileProvider(
      animeGenreTagFrenquencies: _calculateFrequencies<Anime>(
        likedAnimes ?? [],
      ),
      mangaGenreTagFrenquencies: _calculateFrequencies<Manga>(
        likedMangas ?? [],
      ),
      preferredGenres: preferredGenres ?? [],
    );
  }

  // --- Méthodes Privées ---

  Map<Genres, int> _getFrequenciesFromType<T extends Identifiable>() {
    if (T == Anime) return animeGenreTagFrenquencies;
    if (T == Manga) return mangaGenreTagFrenquencies;
    // Fallback safe : retourne une map vide plutôt que de crash
    return {};
  }

  static Map<Genres, int> _calculateFrequencies<T extends Identifiable>(
    List<T> items,
  ) {
    final Map<Genres, int> counts = {};
    for (final item in items) {
      final allTags = item.genres.where((g) => g != Genres.None).toList();
      for (final tagName in allTags) {
        counts.update(tagName, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    return counts;
  }

  // --- Méthodes Publiques Améliorées ---

  /// Obtient les genres les plus pertinents (Likes + Préférences combinés)
  List<Genres> getTopGenres<T extends Identifiable>(int count) {
    final frequencies = _getFrequenciesFromType<T>();
    return _computeTopGenres(frequencies, count);
  }

  /// Obtient les genres les plus pertinents globalement (Anime + Manga)
  List<Genres> getGlobalTopGenres(int count) {
    final Map<Genres, int> globalFrequencies = {};

    // Fusionner les fréquences Anime
    for (var entry in animeGenreTagFrenquencies.entries) {
      globalFrequencies.update(
        entry.key,
        (v) => v + entry.value,
        ifAbsent: () => entry.value,
      );
    }
    // Fusionner les fréquences Manga
    for (var entry in mangaGenreTagFrenquencies.entries) {
      globalFrequencies.update(
        entry.key,
        (v) => v + entry.value,
        ifAbsent: () => entry.value,
      );
    }

    return _computeTopGenres(globalFrequencies, count);
  }

  List<Genres> _computeTopGenres(Map<Genres, int> frequencies, int count) {
    // On crée une map temporaire qui fusionne Likes et Préférences
    final Map<Genres, double> globalScores = {};

    // 1. Ajouter les scores basés sur l'historique
    for (var entry in frequencies.entries) {
      globalScores[entry.key] = entry.value * WEIGHT_PER_LIKE;
    }

    // 2. Ajouter le bonus pour les genres préférés explicitement
    for (var genre in preferredGenres) {
      globalScores.update(
        genre,
        (val) => val + WEIGHT_PREFERRED_GENRE,
        ifAbsent: () => WEIGHT_PREFERRED_GENRE,
      );
    }

    // 3. Trier
    var sortedEntries = globalScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.take(count).map((e) => e.key).toList();
  }

  /// Calcule le score d'un candidat (Anime/Manga)
  /// Score = (Nombre de likes du genre * 1) + (Bonus si genre préféré * 5)
  double calculateScoreFor<T extends Identifiable>(T candidate) {
    final frequencies = _getFrequenciesFromType<T>();
    double score = 0.0;

    final candidateTags = candidate.genres
        .where((g) => g != Genres.None)
        .toList();

    for (final genre in candidateTags) {
      // Point basés sur l'historique
      final int historicalCount = frequencies[genre] ?? 0;
      score += historicalCount * WEIGHT_PER_LIKE;

      // Bonus si c'est un genre favori défini dans les settings
      if (preferredGenres.contains(genre)) {
        score += WEIGHT_PREFERRED_GENRE;
      }
    }

    return score;
  }

  @override
  String toString() {
    return "UserStats: AnimeLikes=${animeGenreTagFrenquencies.length}, MangaLikes=${mangaGenreTagFrenquencies.length}, Preferences=${preferredGenres.length}";
  }
}
