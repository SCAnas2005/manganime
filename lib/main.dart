import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/app.dart';
import 'package:flutter_application_1/providers/boot_loader.dart';
import 'package:flutter_application_1/providers/global_anime_favorites_provider.dart';
import 'package:flutter_application_1/providers/global_manga_favorites_provider.dart';
import 'package:flutter_application_1/providers/settings_repository_provider.dart';
import 'package:flutter_application_1/providers/settings_storage_provider.dart';
import 'package:flutter_application_1/viewmodels/app_settings_view_model.dart';
import 'package:flutter_application_1/viewmodels/search_view_model.dart';
import 'package:provider/provider.dart';

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
