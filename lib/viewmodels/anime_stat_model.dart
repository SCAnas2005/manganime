import 'package:flutter_application_1/providers/user_stats_provider.dart';
import 'package:flutter_application_1/providers/like_storage_provider.dart';
import 'package:flutter_application_1/providers/screen_time_provider.dart';
import 'package:flutter_application_1/providers/anime_cache_provider.dart';
import 'package:flutter_application_1/providers/user_profile_provider.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';
import 'package:flutter_application_1/models/rank_info.dart';
import 'package:flutter_application_1/models/achievement.dart';
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
    _initAchievements();
    _checkAchievements();
  }

  void _updateLikes() {
    likesNumber = LikeStorage.getIdAnimeLiked().length;
    _checkAchievements();
    notifyListeners();
  }

  void _updateViews() {
    viewNumber = UserStatsProvider.getAnimeViewsCount();
    _checkAchievements();
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

    _checkAchievements();
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
    _checkAchievements();
    notifyListeners();
  }

  void _updateTime(int totalSeconds) {
    totalSecondsWatched = totalSeconds;
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    if (hours >= 1) {
      timeFormatted = "${hours}h ${minutes}m";
    } else {
      timeFormatted = "$minutes m";
    }
    _checkAchievements();
    notifyListeners();
  }

  List<Achievement> allAchievements = [];
  List<Achievement> get recentAchievements =>
      allAchievements.where((a) => a.isUnlocked).toList();

  void _initAchievements() {
    allAchievements = [
      Achievement(
        id: 'first_step',
        title: 'Premier Pas',
        description: 'Regarder ton premier anime',
        icon: Icons.play_arrow,
        color: const Color(0xFFC7F141),
        condition: (model) => model.viewNumber >= 1,
      ),
      Achievement(
        id: 'getting_started',
        title: 'Débutant',
        description: 'Regarder 10 animes',
        icon: Icons.looks_one,
        color: const Color(0xFF51D95F),
        condition: (model) => model.viewNumber >= 10,
      ),
      Achievement(
        id: 'otaku_junior',
        title: 'Cap sur GrandLine',
        description: 'Regarder 50 animes',
        icon: Icons.accessibility_new,
        color: const Color(0xFFFFB84D),
        condition: (model) => model.viewNumber >= 50,
      ),
      Achievement(
        id: 'otaku_master',
        title: 'Curieux',
        description: 'Regarder 100 animes',
        icon: Icons.workspace_premium,
        color: const Color(0xFFFF6B9D),
        condition: (model) => model.viewNumber >= 100,
      ),
      Achievement(
        id: 'love_is_war',
        title: 'Love is War',
        description: 'Aimer 5 animes',
        icon: Icons.favorite_border,
        color: const Color(0xFF6B7FFF),
        condition: (model) => model.likesNumber >= 5,
      ),
      Achievement(
        id: 'heart_collector',
        title: 'Collectionneur de Cœurs',
        description: 'Aimer 20 animes',
        icon: Icons.favorite,
        color: const Color(0xFFFF6B9D),
        condition: (model) => model.likesNumber >= 20,
      ),
      Achievement(
        id: 'marathon_runner',
        title: 'Marathonien',
        description: 'Passer 10 heures sur l\'app',
        icon: Icons.timer,
        color: const Color(0xFFC7F141),
        condition: (model) {
          return model.totalSecondsWatched >= 36000;
        },
      ),
      Achievement(
        id: 'time_traveler',
        title: 'Voyageur Temporel',
        description: 'Passer 24 heures sur l\'app',
        icon: Icons.hourglass_full,
        color: const Color(0xFF51D95F),
        condition: (model) => model.totalSecondsWatched >= 86400,
      ),
       Achievement(
        id: 'explorer',
        title: 'Explorateur',
        description: 'Avoir un rang au-dessus de 10',
        icon: Icons.explore,
        color: const Color(0xFF2E7D32),
        condition: (model) => model.rankNumber >= 10,
      ),
      Achievement(
        id: 'rank_up',
        title: 'Level Up',
        description: 'Atteindre le rang "Chef Otaku"',
        icon: Icons.upgrade,
        color: const Color(0xFF2E7D32),
        condition: (model) => model.rankNumber >= 10,
      ),
      Achievement(
        id: 'legend',
        title: 'Légende Vivante',
        description: 'Atteindre le rang "Roi des Pirates"',
        icon: Icons.diamond,
        color: const Color(0xFFFFD700),
        condition: (model) => model.rankNumber >= 100,
      ),
      Achievement(
        id: 'diverse_taste',
        title: 'Goûts Variés',
        description: 'Avoir au moins 3 genres préférés',
        icon: Icons.category,
        color: const Color(0xFF6B7FFF),
        condition: (model) => model.categoryPercentage.length >= 3,
      ),
      Achievement(
        id: 'addicted',
        title: 'Accro',
        description: 'Regarder plus de 500 animes',
        icon: Icons.local_fire_department,
        color: Colors.redAccent,
        condition: (model) => model.viewNumber >= 500,
      ),
      Achievement(
        id: 'critic',
        title: 'Critique d\'Anime',
        description: 'Aimer 50 animes',
        icon: Icons.rate_review,
        color: Colors.purpleAccent,
        condition: (model) => model.likesNumber >= 50,
      )
    ];
  }

  void _checkAchievements() {
    bool hasChanged = false;
    for (var achievement in allAchievements) {
      if (!achievement.isUnlocked && achievement.condition(this)) {
        achievement.isUnlocked = true;
        achievement.unlockedAt = DateTime.now(); 
        hasChanged = true;
      }
    }
    if (hasChanged) {
      notifyListeners();
    }
  }

  int totalSecondsWatched = 0;

  @override
  void dispose() {
    LikeStorage.getLikesListenable().removeListener(_updateLikes);
    LikeStorage.getLikesListenable().removeListener(_updateGenreStats);
    UserStatsProvider.getViewsListenable().removeListener(_updateViews);
    _timeSubscription?.cancel();
    super.dispose();
  }
}
