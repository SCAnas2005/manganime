import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';

class UserprofileProvider {
  final Map<Genres, int> animeGenreTagFrenquencies;

  UserprofileProvider({required this.animeGenreTagFrenquencies});

  /// Méthode pour récupérer le profil utilisateur en fonction des likes
  factory UserprofileProvider.fromLikedAnimes(List<Anime> likedAnimes) {
    final Map<Genres, int> counts = {};

    for (final anime in likedAnimes) {
      final allTags = anime.genres.where((g) => g != Genres.None).toList();

      for (final tagName in allTags) {
        counts.update(tagName, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    return UserprofileProvider(animeGenreTagFrenquencies: counts);
  }

  /// Obtient les $count genres les plus likées
  List<Genres> getTopGenres(int count) {
    if (animeGenreTagFrenquencies.isEmpty) return [];

    var sortedEntries = animeGenreTagFrenquencies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.take(count).map((e) => e.key).toList();
  }

  /// Calcule le score d'un anime en fonction de son genres
  double calculateScoreFor(Anime candidate) {
    double score = 0.0;
    final candidateTags = candidate.genres
        .where((g) => g != Genres.None)
        .toList();
    for (final tagName in candidateTags) {
      score += (animeGenreTagFrenquencies[tagName] ?? 0);
    }

    return score;
  }

  @override
  String toString() {
    return "$animeGenreTagFrenquencies";
  }
}
