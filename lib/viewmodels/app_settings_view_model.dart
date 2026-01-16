import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/app_settings.dart';
import 'package:flutter_application_1/providers/anime_cache_provider.dart';
import 'package:flutter_application_1/providers/global_anime_favorites_provider.dart';
import 'package:flutter_application_1/providers/global_manga_favorites_provider.dart';
import 'package:flutter_application_1/providers/like_storage_provider.dart';
import 'package:flutter_application_1/providers/manga_cache_provider.dart';
import 'package:flutter_application_1/providers/screen_time_provider.dart';
import 'package:flutter_application_1/providers/settings_repository_provider.dart';
import 'package:flutter_application_1/providers/user_stats_provider.dart';
import 'package:flutter_application_1/services/notification_service.dart';
import 'package:flutter_application_1/widgets/restart_widget.dart';
import 'package:provider/provider.dart';

class AppSettingsViewModel extends ChangeNotifier {
  final SettingsRepositoryProvider _settingsRepository;
  late AppSettings settings;
  bool loaded = false;

  AppSettingsViewModel(this._settingsRepository);

  Future<void> init() async {
    settings = _settingsRepository.getSettings();
    loaded = true;
    notifyListeners();
  }

  Future<void> toggleDarkMode({bool? value}) async {
    settings = settings = settings.copyWith(
      darkMode: value ?? !settings.darkMode,
    );
    notifyListeners();
    await _settingsRepository.updateSettings(
      settings.copyWith(darkMode: value ?? !settings.darkMode),
    );
  }

  Future<void> onToggleNotification({bool? value}) async {}
  Future<void> onToggleSuggestions({bool? value}) async {}
  Future<void> onNotificationTimeChanged(TimeOfDay time) async {}

  Future<void> onExportData() async {}
  Future<void> deleteMyData(BuildContext context) async {
    final confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Attention"),
            content: const Text(
              "Cette action est irréversible. Tout votre historique, vos favoris, vos stats seront effacés.",
            ),
            actions: [
              TextButton(
                onPressed: () => {Navigator.pop(context, false)},
                child: const Text("Annuler"),
              ),
              TextButton(
                onPressed: () => {Navigator.pop(context, true)},
                child: const Text(
                  "Supprimer tout",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Supprimer les stats
        await UserStatsProvider.clearAll();
        debugPrint("Suppression des stats");

        // Reset le temps d'écran
        await ScreenTimeProvider.reset();
        debugPrint("Reset du temps d'écran");

        // Nettoyage du cache
        await AnimeCache.instance.clear();
        await MangaCache.instance.clear();
        debugPrint("Suppression des caches anime et manga");

        // Supprimer les likes
        await LikeStorage.clearAll();
        GlobalAnimeFavoritesProvider animeProvider = context
            .read<GlobalAnimeFavoritesProvider>();
        await animeProvider.reset();
        GlobalMangaFavoritesProvider mangaProvider = context
            .read<GlobalMangaFavoritesProvider>();
        await mangaProvider.reset();
        debugPrint("Suppression des likes anime et manga");

        // Annuler les notifs
        NotificationService.instance.cancelAll();
        debugPrint("Annulation de toute les notifications");

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Toute les données ont été effacées."),
            ),
          );
          RestartWidget.restartApp(context);
        }
      } catch (e) {
        if (context.mounted) Navigator.pop(context);
        debugPrint("Erreur lors de la suppression : $e");
      }
    }
  }

  Future<void> toggleAutoSync({bool? value}) async {}
}
