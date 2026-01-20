import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/anime_cache_provider.dart';
import 'package:flutter_application_1/providers/anime_repository_provider.dart';
import 'package:flutter_application_1/providers/database_provider.dart';
import 'package:flutter_application_1/providers/like_storage_provider.dart';
import 'package:flutter_application_1/providers/manga_cache_provider.dart';
import 'package:flutter_application_1/providers/manga_repository_provider.dart';
import 'package:flutter_application_1/providers/media_sections_provider.dart';
import 'package:flutter_application_1/providers/screen_time_provider.dart';
import 'package:flutter_application_1/providers/settings_repository_provider.dart';
import 'package:flutter_application_1/providers/settings_storage_provider.dart';
import 'package:flutter_application_1/providers/user_stats_provider.dart';
import 'package:flutter_application_1/services/image_sync_service.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_application_1/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BootLoader {
  // ignore: constant_identifier_names
  static const int CURRENT_DATA_VERSION = 4;
  static Future<void> initAll() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialisation de la base de donnée locale HIVE
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

    // Initialisation du suivi du temps d'écran
    await ScreenTimeProvider.init();

    // Initialisation des paramètres de l'app
    await SettingsStorage.instance.init();

    // Initialisation du service de notif
    void f(NotificationResponse response) {
      onNotificationClick(response.payload ?? "");
    }

    await NotificationService.instance.init(
      onDidReceiveNotificationResponse: f,
    );
  }

  static Future<void> _requireInternet() async {
    bool hasConnection = await NetworkService.isConnected;
    if (!hasConnection) {
      throw const SocketException("Connexion perdue pendant le téléchargement");
    }
  }

  static Future<void> scheduleForTomorrow(
    Identifiable identifiable,
    TimeOfDay time,
  ) async {
    String title = "";
    String body = "";
    if (identifiable is Anime) {
      title = "Anime du jour 📺";
      body = "Découvre ${identifiable.title}";
    } else {
      title = "Lecture du jour 📚";
      body = "Plonge dans ${identifiable.title}";
    }

    final now = DateTime.now();
    final date = DateTime(
      now.year,
      now.month,
      now.day + 1,
      time.hour,
      time.minute,
    );

    await NotificationService().scheduleDailyRecommendations(
      id: 0,
      title: title,
      body: body,
      identifiable: identifiable,
      date: date,
    );
  }

  static Future<void> scheduleFromNow(
    Identifiable identifiable,
    TimeOfDay addedTime,
  ) async {
    String title = "";
    String body = "";
    if (identifiable is Anime) {
      title = "Anime du jour 📺";
      body = "Découvre ${identifiable.title}";
    } else {
      title = "Lecture du jour 📚";
      body = "Plonge dans ${identifiable.title}";
    }

    final now = DateTime.now();
    final date = now.add(
      Duration(hours: addedTime.hour, minutes: addedTime.minute),
    );

    await NotificationService().scheduleDailyRecommendations(
      id: 0,
      title: title,
      body: body,
      identifiable: identifiable,
      date: date,
    );
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
    }
    await _performQuickStartup(onStatusChanged, provider);
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
    final lastNotificationDate = provider.getSettings().lastNotificationSent;
    // isSameDay gère le fait que les dates soit null ou pas.
    if (!provider.isSameDay(lastNotificationDate, DateTime.now())) {
      Identifiable? identifiable;
      bool isAnime = Random().nextBool();

      if (isAnime) {
        identifiable = await AnimeRepository(
          api: JikanService(),
        ).getAnimeOfTheDay();
      } else {
        identifiable = await MangaRepository(
          api: JikanService(),
        ).getMangaOfTheDay();
      }

      if (identifiable != null) {
        await scheduleFromNow(identifiable, TimeOfDay(hour: 0, minute: 2));
      }
    } else {
      debugPrint("No notification for today, already has one");
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
