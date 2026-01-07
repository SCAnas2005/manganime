import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/anime_cache_provider.dart';
import 'package:flutter_application_1/providers/database_provider.dart';
import 'package:flutter_application_1/providers/like_storage_provider.dart';
import 'package:flutter_application_1/providers/manga_cache_provider.dart';
import 'package:flutter_application_1/providers/media_path_provider.dart';
import 'package:flutter_application_1/providers/media_sections_provider.dart';
import 'package:flutter_application_1/providers/screen_time_provider.dart';
import 'package:flutter_application_1/providers/settings_repository_provider.dart';
import 'package:flutter_application_1/providers/settings_storage_provider.dart';
import 'package:flutter_application_1/providers/user_stats_provider.dart';
import 'package:flutter_application_1/services/image_sync_service.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BootLoader {
  static Future<void> initAll() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Hive.initFlutter();

    // Ouvre une box pour la base de donnée
    await DatabaseProvider.init();

    // Ouvre une box pour les likes
    await LikeStorage.init();
    // Ouvre une box pour les vues
    await UserStatsProvider.init();

    // Ouvre une box pour le cache d'anime/manga
    await AnimeCache.instance.init();
    await MangaCache.instance.init();

    // Ouvre une box poru le service de synchronisation d'image
    await ImageSyncService.instance.init();
    await ImageSyncService.instance.processQueue();

    // Ouvre une box pour les sections anime/manga
    await MediaSectionsProvider.instance.init(JikanService());

    // Initialisation et démarrage du suivi du temps d'écran
    await ScreenTimeProvider.init();
    ScreenTimeProvider().startTracking();

    await SettingsStorage.instance.init();
  }

  static Future<void> onAppStart({
    Function(String message)? onStatusChanged,
  }) async {
    var provider = SettingsRepositoryProvider(SettingsStorage.instance);
    bool isFirstLaunch = provider.getSettings().isFirstLaunch;

    await provider.updateSettings(
      provider.getSettings().copyWith(isFirstLaunch: true),
    );

    if (isFirstLaunch) {
      debugPrint("========= App first launch");

      debugPrint("Database populate started");
      onStatusChanged?.call("Téléchargement des Mangas...");
      await DatabaseProvider.instance.clear<Manga>();
      await DatabaseProvider.instance.populate<Manga>(JikanService(), 300);

      onStatusChanged?.call("Téléchargement des Animes...");
      await DatabaseProvider.instance.clear<Anime>();
      await DatabaseProvider.instance.populate<Anime>(JikanService(), 300);

      onStatusChanged?.call("Mise à jour du cache...");
      debugPrint("Updating cache");
      await AnimeCache.instance.updateCache();

      onStatusChanged?.call("Finalisation...");

      await provider.updateSettings(
        provider.getSettings().copyWith(isFirstLaunch: false),
      );

      // if ((await MediaPathProvider.getLocalFileImage(
      //   (await DatabaseProvider.instance.getAnime(22))!,
      // )).existsSync()) {
      //   debugPrint("Anime 22 has a image file");
      // } else {
      //   debugPrint("Anime 22 has not image file");
      // }
    }
  }
}
