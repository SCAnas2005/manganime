import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/app.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/anime_repository_provider.dart';
import 'package:flutter_application_1/providers/boot_loader.dart';
import 'package:flutter_application_1/providers/global_anime_favorites_provider.dart';
import 'package:flutter_application_1/providers/global_manga_favorites_provider.dart';
import 'package:flutter_application_1/providers/manga_repository_provider.dart';
import 'package:flutter_application_1/providers/settings_repository_provider.dart';
import 'package:flutter_application_1/providers/settings_storage_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/viewmodels/app_settings_view_model.dart';
import 'package:flutter_application_1/viewmodels/search_view_model.dart';
import 'package:flutter_application_1/views/splash_screen_view.dart';
import 'package:provider/provider.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  await BootLoader.initAll();

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

void onNotificationClick(String payload) async {
  final parts = payload.split(":");
  String type = parts.first;
  int id = int.parse(parts.last);

  Identifiable? identifiable;

  if (type == "anime") {
    identifiable = await AnimeRepository(api: JikanService()).getAnime(id);
  } else {
    identifiable = await MangaRepository(api: JikanService()).getManga(id);
  }
  if (identifiable != null) {
    final navigator = navigatorKey.currentState;
    await navigator?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (builder) => SplashScreen(identifiableToOpen: identifiable),
      ),
      (route) => false,
    );
  }
}
