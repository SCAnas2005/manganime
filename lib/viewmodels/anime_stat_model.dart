import 'package:flutter_application_1/providers/user_stats_provider.dart';
import 'package:flutter_application_1/providers/like_storage_provider.dart';
import 'package:flutter_application_1/providers/screen_time_provider.dart';

class AnimeStatModel {
  late int viewsNumber;

  late int rankNumber;

  late int likesNumber;

  late int viewNumber;

  late String timeFormatted;

  late Map<String,int> categoryPercentage; 

  void init() {
    rankNumber = 12;
    likesNumber = LikeStorage.getIdAnimeLiked().length;
    viewNumber = UserStatsProvider.getAnimeViewsCount();
    final int totalSeconds = ScreenTimeProvider.getTotalScreenTime();
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    if(hours >= 1) {
      timeFormatted = "${hours}h${minutes}m";
    } else {
      timeFormatted = "${minutes} m";
    }
    categoryPercentage = {"Action":35, "Shonen":28,"Romance":18,"Fantaisie":12,"Seinen":7};
  } 
}