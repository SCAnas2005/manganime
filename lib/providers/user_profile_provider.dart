import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';
import 'package:flutter_application_1/models/manga.dart';

class UserprofileProvider {
  final Map<Genres, int> animeGenreTagFrenquencies;
  final Map<Genres, int> mangaGenreTagFrenquencies;

  UserprofileProvider({
    required this.animeGenreTagFrenquencies,
    required this.mangaGenreTagFrenquencies,
  });

  // static fromLiked<T extends Identifiable>(List<T> likedList) {
  //   final Map<Genres, int> counts = {};

  //   for (final identifiable in likedList) {
  //     final allTags = identifiable.genres
  //         .where((g) => g != Genres.None)
  //         .toList();

  //     for (final tagName in allTags) {
  //       counts.update(tagName, (value) => value + 1, ifAbsent: () => 1);
  //     }
  //   }

  //   return UserprofileProvider(animeGenreTagFrenquencies: counts);
  // }

  Map<Genres, int> _getFrequenciesFromType<T extends Identifiable>() {
    if (T == Anime) return animeGenreTagFrenquencies;
    if (T == Manga) return mangaGenreTagFrenquencies;
    throw Exception(
      "[UserprofilProvider] _getFrequenciesFromType<$T>() : Type not supported",
    );
  }

  factory UserprofileProvider.create({
    List<Anime>? likedAnimes,
    List<Manga>? likedMangas,
  }) {
    return UserprofileProvider(
      animeGenreTagFrenquencies: _calculateFrequencies<Anime>(
        likedAnimes ?? [],
      ),
      mangaGenreTagFrenquencies: _calculateFrequencies<Manga>(
        likedMangas ?? [],
      ),
    );
  }

  /// Méthode pour récupérer le profil utilisateur en fonction des likes
  static Map<Genres, int> _calculateFrequencies<T extends Identifiable>(
    List<T> items,
  ) {
    final Map<Genres, int> counts = {};

    for (final item in items) {
      // On suppose que Identifiable a un getter 'genres'
      // Si 'genres' n'est pas dans Identifiable, il faudra faire un check de type (is Anime/is Manga)
      final allTags = item.genres.where((g) => g != Genres.None).toList();

      for (final tagName in allTags) {
        counts.update(tagName, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    return counts;
  }

  /// Obtient les $count genres les plus likées
  List<Genres> getTopGenres<T extends Identifiable>(int count) {
    final frequencies = _getFrequenciesFromType<T>();
    if (frequencies.isEmpty) return [];

    var sortedEntries = frequencies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.take(count).map((e) => e.key).toList();
  }

  /// Calcule le score d'un anime en fonction de son genres
  double calculateScoreFor<T extends Identifiable>(T candidate) {
    final frequencies = _getFrequenciesFromType<T>();
    double score = 0.0;
    final candidateTags = candidate.genres
        .where((g) => g != Genres.None)
        .toList();
    for (final tagName in candidateTags) {
      score += (frequencies[tagName] ?? 0);
    }

    return score;
  }

  @override
  String toString() {
    return "Anime: $animeGenreTagFrenquencies\nManga: $mangaGenreTagFrenquencies";
  }
}
