import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/app.dart';
import 'package:flutter_application_1/providers/anime_cache_provider.dart';
import 'package:flutter_application_1/providers/global_anime_favorites_provider.dart';
import 'package:flutter_application_1/providers/global_manga_favorites_provider.dart';
import 'package:flutter_application_1/providers/like_storage_provider.dart';
import 'package:flutter_application_1/providers/manga_cache_provider.dart';
import 'package:flutter_application_1/providers/user_stats_provider.dart';
import 'package:flutter_application_1/providers/screen_time_provider.dart';
import 'package:flutter_application_1/viewmodels/search_view_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  // Ouvre une box pour les likes
  await LikeStorage.init();
  // Ouvre une box pour les vues
  await UserStatsProvider.init();

  // Ouvre une box pour le cache d'anime
  await AnimeCache.instance.init();
  await MangaCache.instance.init();

  // Initialisation et démarrage du suivi du temps d'écran
  await ScreenTimeProvider.init();
  ScreenTimeProvider().startTracking();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GlobalAnimeFavoritesProvider()),
        ChangeNotifierProvider(create: (_) => GlobalMangaFavoritesProvider()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
      ],
      child: const App(),
    ),
  );
}
