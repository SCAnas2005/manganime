import 'package:flutter/material.dart';
import 'package:flutter_application_1/viewmodels/app_settings_view_model.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class AppSettingsView extends StatefulWidget {
  const AppSettingsView({super.key});
  @override
  State<StatefulWidget> createState() => AppSettingsViewState();
}

class AppSettingsViewState extends State<AppSettingsView> {
  bool darkMode = true;
  bool notificationsEnabled = true;
  bool dailySuggestions = true;

  TimeOfDay notificationTime = const TimeOfDay(hour: 9, minute: 0);

  final Set<String> selectedGenres = {'Action', 'Shōnen'};

  final List<String> allGenres = [
    'Action',
    'Shōnen',
    'Romance',
    'Fantaisie',
    'Seinen',
    'Thriller',
    'Comédie',
    'Horreur',
  ];

  Future<void> _pickNotificationTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: notificationTime,
    );

    if (picked != null) {
      setState(() => notificationTime = picked);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppSettingsViewModel>();

    if (!vm.loaded) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: SettingsList(
        darkTheme: SettingsThemeData(settingsListBackground: Colors.black),
        sections: [
          /// 🎨 Apparence
          SettingsSection(
            title: const Text('Apparence'),
            tiles: [
              SettingsTile.switchTile(
                initialValue: vm.settings.darkMode,
                onToggle: (value) => vm.toggleDarkMode(value: value),
                leading: const Icon(Icons.dark_mode),
                title: const Text('Mode sombre'),
                description: const Text(
                  'Activer le thème sombre pour un meilleur confort visuel',
                ),
              ),
            ],
          ),

          /// 🔔 Notifications
          SettingsSection(
            title: const Text('Notifications'),
            tiles: [
              SettingsTile.switchTile(
                initialValue: notificationsEnabled,
                onToggle: (value) =>
                    setState(() => notificationsEnabled = value),
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications activées'),
                description: const Text(
                  'Recevoir des notifications de l\'application',
                ),
              ),
              SettingsTile.switchTile(
                initialValue: dailySuggestions,
                onToggle: (value) => setState(() => dailySuggestions = value),
                leading: const Icon(Icons.recommend),
                title: const Text('Suggestions quotidiennes'),
                description: const Text(
                  'Recevoir une recommandation personnalisée chaque jour',
                ),
              ),
              
            ],
          ),
          
          /// 🔐 Données
          SettingsSection(
            title: const Text('Données et confidentialité'),
            tiles: [
              SettingsTile.navigation(
                leading: const Icon(Icons.download),
                title: const Text('Exporter mes données'),
                description: const Text('Télécharger une copie de vos données'),
                onPressed: (_) {},
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Supprimer mes données',
                  style: TextStyle(color: Colors.red),
                ),
                description: const Text('Effacer toutes vos données locales'),
                onPressed: (_) {},
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.refresh),
                title: const Text('Réinitialiser les préférences'),
                description: const Text('Revenir aux paramètres par défaut'),
                onPressed: (_) {
                  setState(() {
                    darkMode = false;
                    notificationsEnabled = false;
                    dailySuggestions = false;
                    selectedGenres.clear();
                    notificationTime = const TimeOfDay(hour: 9, minute: 0);
                  });
                },
              ),
            ],
          ),

          /// ℹ️ Footer
          SettingsSection(
            tiles: [
              SettingsTile(
                title: const Center(
                  child: Text(
                    'Version 1.0.0\n© 2025 MangAnime',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
