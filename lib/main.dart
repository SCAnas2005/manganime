import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/app.dart';
import 'package:flutter_application_1/providers/anime_cache_provider.dart';
import 'package:flutter_application_1/providers/anime_sections_provider.dart';
import 'package:flutter_application_1/providers/database_provider.dart';
import 'package:flutter_application_1/providers/global_anime_favorites_provider.dart';
import 'package:flutter_application_1/providers/global_manga_favorites_provider.dart';
import 'package:flutter_application_1/providers/like_storage_provider.dart';
import 'package:flutter_application_1/providers/manga_cache_provider.dart';
import 'package:flutter_application_1/providers/settings_repository_provider.dart';
import 'package:flutter_application_1/providers/settings_storage_provider.dart';
import 'package:flutter_application_1/providers/user_stats_provider.dart';
import 'package:flutter_application_1/providers/screen_time_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/viewmodels/app_settings_view_model.dart';
import 'package:flutter_application_1/viewmodels/search_view_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
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

  // Ouvre une box pour les sections anime/manga
  await AnimeSectionsProvider.instance.init();

  // Initialisation et démarrage du suivi du temps d'écran
  await ScreenTimeProvider.init();
  ScreenTimeProvider().startTracking();

  await SettingsStorage.instance.init();

  await onAppStart();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GlobalAnimeFavoritesProvider()),
        ChangeNotifierProvider(create: (_) => GlobalMangaFavoritesProvider()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(
          create: (_) => AppSettingsViewModel(
            SettingsRepositoryProvider(SettingsStorage.instance),
          )..init(),
        ),
      ],
      child: const App(),
    ),
  );
}

Future<void> onAppStart() async {
  var provider = SettingsRepositoryProvider(SettingsStorage.instance);
  bool isFirstLaunch = true;
  //provider.getSettings().isFirstLaunch;

  await provider.updateSettings(
    provider.getSettings().copyWith(isFirstLaunch: true),
  );

  if (isFirstLaunch) {
    debugPrint("========= App first launch");

    // debugPrint("Database populate started");
    // await DatabaseProvider.instance.clear<Anime>();
    // await DatabaseProvider.instance.populate<Anime>(JikanService(), 300);
    // debugPrint("Updating cache");
    // await AnimeCache.instance.updateCache();

    await provider.updateSettings(
      provider.getSettings().copyWith(isFirstLaunch: false),
    );
  }
}
