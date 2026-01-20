import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/app_settings.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';
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

/// ViewModel gérant la logique métier de l'écran des paramètres de l'application.
///
/// Il agit comme un pont entre l'interface utilisateur (View) et le repository de stockage.
/// Il est responsable de :
/// - La modification du thème (Dark Mode).
/// - La gestion des genres favoris pour l'algorithme de recommandation.
/// - La suppression complète et irréversible des données utilisateur ("Hard Reset").
class AppSettingsViewModel extends ChangeNotifier {
  final SettingsRepositoryProvider _settingsRepository;

  /// L'état actuel des paramètres (immuable, remplacé à chaque modification).
  late AppSettings settings;

  /// Indique si les paramètres ont fini de charger depuis le disque.
  bool loaded = false;

  AppSettingsViewModel(this._settingsRepository);

  /// Initialise le ViewModel en chargeant les paramètres sauvegardés.
  Future<void> init() async {
    settings = _settingsRepository.getSettings();
    loaded = true;
    notifyListeners();
  }

  /// Active ou désactive le mode sombre et persiste le choix.
  Future<void> toggleDarkMode({bool? value}) async {
    settings = settings.copyWith(darkMode: value ?? !settings.darkMode);
    notifyListeners();
    await _settingsRepository.updateSettings(
      settings.copyWith(darkMode: value ?? !settings.darkMode),
    );
  }

  Future<void> onToggleNotification(BuildContext context, {bool? value}) async {
    bool newValue = value ?? !settings.isNotificationAllowed;

    debugPrint("notification value : $newValue");

    if (newValue == true) {
      bool authorized = await NotificationService.instance
          .checkAndRequestPermission(context);
      debugPrint("checking notification permission");

      if (!authorized) {
        newValue = false;
      }
    }

    settings = settings.copyWith(isNotificationAllowed: newValue);
    await _settingsRepository.updateSettings(settings);
    notifyListeners();
  }

  /// Active ou désactive les suggestions (Algorithme de recommandation)
  Future<void> onToggleSuggestions({bool? value}) async {
    // 1. Calcul de la nouvelle valeur
    // (J'assume que ton modèle AppSettings a un champ 'enableSuggestions', adapte le nom si besoin)
    final bool newValue =
        value ?? !settings.isPersonalizedRecommendationAllowed;

    // 2. Mise à jour de l'état et sauvegarde
    settings = settings.copyWith(isPersonalizedRecommendationAllowed: newValue);
    notifyListeners();
    await _settingsRepository.updateSettings(settings);

    debugPrint("Suggestions mises à jour : $newValue");
  }

  /// Change l'heure de la notification quotidienne
  Future<void> onNotificationTimeChanged(TimeOfDay time) async {
    settings = settings.copyWith(notificationTime: time);
    await _settingsRepository.updateSettings(settings);
    debugPrint("temps sauvegardé : $time");
    notifyListeners();
  }

  /// Ajoute ou retire un genre de la liste des favoris.
  ///
  /// Cette liste est utilisée par l'algorithme "Cocktail" pour personnaliser
  /// les recommandations de l'utilisateur.
  Future<void> toggleFavoriteGenre(Genres genre) async {
    final currentList = List<Genres>.from(settings.favoriteGenres ?? []);

    if (currentList.contains(genre)) {
      currentList.remove(genre);
    } else {
      currentList.add(genre);
    }

    settings = settings.copyWith(favoriteGenres: currentList);
    notifyListeners();
    await _settingsRepository.updateSettings(settings);
  }

  Future<void> onExportData() async {}

  /// Lance la procédure de suppression totale des données de l'utilisateur.
  ///
  /// Cette méthode suit un processus strict :
  /// 1. Demande de confirmation via une boîte de dialogue.
  /// 2. Affichage d'un loader bloquant.
  /// 3. Nettoyage en cascade de tous les Providers et Caches (Hive, SQL, Preferences).
  /// 4. Annulation des notifications programmées.
  /// 5. Redémarrage forcé de l'application via [RestartWidget].
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
