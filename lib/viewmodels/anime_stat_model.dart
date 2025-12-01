import 'package:flutter_application_1/providers/user_stats_provider.dart';
import 'package:flutter_application_1/providers/like_storage_provider.dart';

class AnimeStatModel {
  late int viewsNumber;

  late int rankNumber;

  late int likesNumber;

  late int viewNumber;

  late int timeNumber;

  late Map<String,int> categoryPercentage; 

  void init() {
    rankNumber = 12;
    likesNumber = LikeStorage.getIdAnimeLiked().length;
    viewNumber = UserStatsProvider.getAnimeViewsCount();
    timeNumber = 32;
    categoryPercentage = {"Action":35, "Shonen":28,"Romance":18,"Fantaisie":12,"Seinen":7};
  } 
}