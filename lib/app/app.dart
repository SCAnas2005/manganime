import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/themes.dart';
import 'package:flutter_application_1/viewmodels/app_settings_view_model.dart';
import 'package:flutter_application_1/views/splash_screen_view.dart';
import 'package:provider/provider.dart';

/// Widget racine de l'application.
///
/// Il configure le thème (clair, sombre ou système)
/// en fonction des paramètres utilisateur
/// et définit l'écran initial de l'application.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<StatefulWidget> createState() => AppState();
}

/// État principal de l'application.
///
/// Il construit le [MaterialApp] et applique dynamiquement
/// le thème en fonction du [AppSettingsViewModel].
class AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    final settingsVM = context.watch<AppSettingsViewModel>();
    return MaterialApp(
      title: "MangAnime",
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsVM.loaded
          ? settingsVM.settings.darkMode
                ? ThemeMode.dark
                : ThemeMode.light
          : ThemeMode.system,
      home: SplashScreen(),
    );
  }
}
