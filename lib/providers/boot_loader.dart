import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/anime_cache_provider.dart';
import 'package:flutter_application_1/providers/database_provider.dart';
import 'package:flutter_application_1/providers/like_storage_provider.dart';
import 'package:flutter_application_1/providers/manga_cache_provider.dart';
import 'package:flutter_application_1/providers/media_sections_provider.dart';
import 'package:flutter_application_1/providers/screen_time_provider.dart';
import 'package:flutter_application_1/providers/settings_repository_provider.dart';
import 'package:flutter_application_1/providers/settings_storage_provider.dart';
import 'package:flutter_application_1/providers/user_stats_provider.dart';
import 'package:flutter_application_1/services/image_sync_service.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BootLoader {
  // ignore: constant_identifier_names
  static const int CURRENT_DATA_VERSION = 4;
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

    // Ouvre une box pour les sections anime/manga
    await MediaSectionsProvider.instance.init(JikanService());

    // Initialisation et démarrage du suivi du temps d'écran
    await ScreenTimeProvider.init();

    await SettingsStorage.instance.init();
  }

  static Future<void> _requireInternet() async {
    // Si tu as une classe NetworkService, utilise-la ici
    // Exemple basique :
    bool hasConnection = await NetworkService.isConnected;
    if (!hasConnection) {
      throw const SocketException("Connexion perdue pendant le téléchargement");
    }
  }

  static Future<void> onAppStart({
    Function(String message)? onStatusChanged,
    bool forceUpdate = false,
  }) async {
    debugPrint("App started : data version : $CURRENT_DATA_VERSION");
    ImageSyncService.instance.processQueue();
    ScreenTimeProvider().startTracking();

    var provider = SettingsRepositoryProvider(SettingsStorage.instance);
    bool isFirstLaunch = provider.getSettings().isFirstLaunch;
    int dataVersion = provider.getSettings().dataVersion;

    bool needUpdate =
        isFirstLaunch || (forceUpdate || dataVersion < CURRENT_DATA_VERSION);

    if (isFirstLaunch) debugPrint("First application launch");
    if (dataVersion < CURRENT_DATA_VERSION) {
      debugPrint(
        "Data version aren't the same : $dataVersion < $CURRENT_DATA_VERSION",
      );
    }

    if (needUpdate) {
      await _performFullUpdate(onStatusChanged, provider);
    } else {
      await _performQuickStartup(onStatusChanged, provider);
    }
  }

  static Future<void> _performFullUpdate(
    Function(String)? onStatusChanged,
    SettingsRepositoryProvider provider,
  ) async {
    debugPrint("Performing full update");
    await MediaSectionsProvider.instance.clearAll();
    await AnimeCache.instance.clear();
    await MangaCache.instance.clear();
    await DatabaseProvider.instance.clear<Manga>();
    await DatabaseProvider.instance.clear<Anime>();

    await _requireInternet();
    debugPrint("Database populate started");
    onStatusChanged?.call("Téléchargement des Mangas...");
    await DatabaseProvider.instance.populate<Manga>(JikanService(), 300);

    await _requireInternet();
    onStatusChanged?.call("Téléchargement des Animes...");
    await DatabaseProvider.instance.populate<Anime>(JikanService(), 300);

    await _requireInternet();
    onStatusChanged?.call("Initialisation du cache");
    await MediaSectionsProvider.instance.reloadSections(JikanService());

    onStatusChanged?.call("Mise à jour du cache...");
    debugPrint("Updating cache");
    await AnimeCache.instance.updateCache();

    onStatusChanged?.call("Finalisation...");

    await provider.updateSettings(
      provider.getSettings().copyWith(
        isFirstLaunch: false,
        dataVersion: CURRENT_DATA_VERSION,
      ),
    );
  }

  static Future<void> _performQuickStartup(
    Function(String)? onStatusChanged,
    SettingsRepositoryProvider provider,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
