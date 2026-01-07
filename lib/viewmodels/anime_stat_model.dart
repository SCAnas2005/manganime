import 'package:flutter_application_1/providers/user_stats_provider.dart';
import 'package:flutter_application_1/providers/like_storage_provider.dart';
import 'package:flutter_application_1/providers/screen_time_provider.dart';
import 'package:flutter_application_1/providers/anime_cache_provider.dart';
import 'package:flutter_application_1/providers/user_profile_provider.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';
import 'package:flutter_application_1/models/rank_info.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

class AnimeStatModel extends ChangeNotifier {
  int viewsNumber = 0;

  int rankNumber = 0;

  double rankProgress = 0.0;

  String currentRankTitle = "Otaku-chaaan";
  Color currentRankColor = const Color(0xFFC7F141);

  final List<RankInfo> _ranks = [
    const RankInfo(
      name: "Otaku-chaaan",
      threshold: 0,
      color: Color(0xFFC7F141),
    ),
    const RankInfo(name: "Petit Chef", threshold: 5, color: Color(0xFF51D95F)),
    const RankInfo(name: "Chef Otaku", threshold: 10, color: Color(0xFF2E7D32)),
    const RankInfo(
      name: "Leaker One Piece",
      threshold: 15,
      color: Colors.white,
    ),
    const RankInfo(name: "Gintoki", threshold: 20, color: Color(0xFF6B7FFF)),
    const RankInfo(name: "Bankai", threshold: 25, color: Color(0xFFFFB84D)),
    const RankInfo(name: "Zoro Perdu", threshold: 30, color: Color(0xFF1B5E20)),
    const RankInfo(name: "Le Mont Corvo", threshold: 35, color: Colors.brown),
    const RankInfo(
      name: "El Psy Kongroo",
      threshold: 35,
      color: Colors.blueAccent,
    ),
    const RankInfo(name: "Espada", threshold: 40, color: Colors.cyan),
    const RankInfo(name: "SSJ3", threshold: 45, color: Colors.yellowAccent),
    const RankInfo(name: "Gear 5", threshold: 50, color: Color(0xFFFFFDD0)),
    const RankInfo(name: "La Zone", threshold: 55, color: Colors.redAccent),
    const RankInfo(
      name: "Sakura Hate Club",
      threshold: 60,
      color: Color(0xFFFF6B9D),
    ),
    const RankInfo(
      name: "Aura Farmer",
      threshold: 65,
      color: Color(0xFF000080),
    ),
    const RankInfo(
      name: "No Enemies",
      threshold: 70,
      color: Colors.lightBlueAccent,
    ),
    const RankInfo(name: "Titan Originel", threshold: 75, color: Colors.purple),
    const RankInfo(name: "Hokage", threshold: 80, color: Color(0xFFC0C0C0)),
    const RankInfo(
      name: "Le Roi des Pirates",
      threshold: 100,
      color: Color(0xFFFFD700),
    ),
  ];

  int likesNumber = 0;

  int viewNumber = 0;

  String timeFormatted = "0m";

  Map<String, int> categoryPercentage = {};

  StreamSubscription? _timeSubscription;

  void init() {
    rankNumber = 12;
    categoryPercentage = {};

    // valeurs initiales
    _updateLikes();
    _updateViews();
    _updateTime(ScreenTimeProvider.getTotalScreenTime());
    _updateGenreStats();
    _updateRank();

    LikeStorage.getLikesListenable().addListener(_updateLikes);
    LikeStorage.getLikesListenable().addListener(_updateGenreStats);

    UserStatsProvider.getViewsListenable().addListener(_updateViews);
    UserStatsProvider.getViewsListenable().addListener(_updateRank);

    _timeSubscription = ScreenTimeProvider().timeStream.listen(_updateTime);
  }

  void _updateLikes() {
    likesNumber = LikeStorage.getIdAnimeLiked().length;
    notifyListeners();
  }

  void _updateViews() {
    viewNumber = UserStatsProvider.getAnimeViewsCount();
    notifyListeners();
  }

  void _updateRank() {
    final double divisor = ((1 + sqrt(5)) / 2) * 1000;
    final int totalScore =
        ScreenTimeProvider.getTotalScreenTime() +
        LikeStorage.getIdAnimeLiked().length +
        UserStatsProvider.getAnimeViewsCount();

    rankNumber = totalScore ~/ divisor;
    rankProgress = (totalScore % divisor) / divisor;

    // Mis à jour des informations du rang actuel
    RankInfo currentRank = _ranks.first;
    for (final rank in _ranks) {
      if (rankNumber >= rank.threshold) {
        currentRank = rank;
      } else {
        break;
      }
    }
    currentRankTitle = currentRank.name;
    currentRankColor = currentRank.color;

    notifyListeners();
  }

  Future<void> _updateGenreStats() async {
    final likedIds = LikeStorage.getIdAnimeLiked();
    final List<Anime> likedAnimes = [];

    for (final id in likedIds) {
      final anime = await AnimeCache.instance.get(id);
      if (anime != null) {
        likedAnimes.add(anime);
      }
    }

    if (likedAnimes.isEmpty) {
      categoryPercentage = {};
      notifyListeners();
      return;
    }

    final userProfile = UserprofileProvider.create(likedAnimes: likedAnimes);
    final topGenres = userProfile.getTopGenres<Anime>(5);

    final Map<String, int> newStats = {};

    // calcule total des occurrences des genres pour le top 5 pour normaliser le pourcentage pour le pie chart
    int sumTop5 = 0;
    for (final genre in topGenres) {
      sumTop5 += userProfile.animeGenreTagFrenquencies[genre] ?? 0;
    }

    for (final genre in topGenres) {
      final count = userProfile.animeGenreTagFrenquencies[genre] ?? 0;
      if (sumTop5 > 0) {
        final percent = (count * 100) ~/ sumTop5;
        newStats[genre.toReadableString()] = percent;
      }
    }

    categoryPercentage = newStats;
    notifyListeners();
  }

  void _updateTime(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    if (hours >= 1) {
      timeFormatted = "${hours}h ${minutes}m";
    } else {
      timeFormatted = "${minutes} m";
    }
    notifyListeners();
  }

  @override
  void dispose() {
    LikeStorage.getLikesListenable().removeListener(_updateLikes);
    LikeStorage.getLikesListenable().removeListener(_updateGenreStats);
    UserStatsProvider.getViewsListenable().removeListener(_updateViews);
    _timeSubscription?.cancel();
    super.dispose();
  }
}
