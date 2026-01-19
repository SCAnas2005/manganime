import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/home.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_application_1/providers/boot_loader.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_application_1/providers/settings_repository_provider.dart';
import 'package:flutter_application_1/providers/settings_storage_provider.dart';

/// Écran de démarrage (Splash) gérant l'initialisation des données et la vérification
/// des mises à jour obligatoires avant l'accès à l'application.
class SplashScreen extends StatefulWidget {
  /// Objet optionnel à ouvrir directement après le chargement (ex: via une notification).
  final Identifiable? identifiableToOpen;
  const SplashScreen({this.identifiableToOpen, super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _loadingText = "Chargement...";
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _checkAndStart();
  }

  /// Logique principale de démarrage :
  /// 1. Vérification de la version des données.
  /// 2. Vérification de la connexion si une mise à jour est nécessaire.
  /// 3. Lancement du BootLoader pour charger le cache/DB.
  Future<void> _checkAndStart() async {
    setState(() => _hasError = false); // Reset l'erreur si on "Réessaie"

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _loadingText = "Analyse...");

    var settingsRepo = SettingsRepositoryProvider(SettingsStorage.instance);
    final settings = settingsRepo.getSettings();

    // Vérifie si c'est le premier lancement ou si une nouvelle version de la DB est requise
    bool needUpdate =
        settings.isFirstLaunch ||
        (settings.dataVersion < BootLoader.CURRENT_DATA_VERSION);

    if (needUpdate) {
      if (mounted) setState(() => _loadingText = "Vérification connexion...");

      bool isConnected = await NetworkService.isConnected;

      if (!isConnected) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _loadingText = "Mise à jour requise : Internet nécessaire.";
          });
        }
        return; // On stoppe ici tant qu'on n'a pas internet
      }
    } else {
      debugPrint("Mode Hors-Ligne supporté");
    }

    try {
      // Exécute les tâches lourdes d'initialisation (Hive, Database, etc.)
      await BootLoader.onAppStart(
        forceUpdate: needUpdate,
        onStatusChanged: (message) {
          if (mounted) {
            setState(() {
              _loadingText = message;
            });
          }
        },
      );

      // 4. NAVIGATION FINALE
      _navigateToHome();
    } catch (e) {
      debugPrint("Erreur critique au démarrage: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
          _loadingText = "Erreur : ${e.toString()}";
        });
      }
    }
  }

  /// Calcule la page de destination et redirige vers la HomePage.
  void _navigateToHome() {
    if (mounted) {
      int? indexPageToOpen = widget.identifiableToOpen == null
          ? null
          : widget.identifiableToOpen is Anime
          ? 0
          : 1;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(
            title: "MangAnime",
            indexPage: indexPageToOpen,
            identifiableToOpen: widget.identifiableToOpen,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Utilisation du thème pour les couleurs et styles
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Utilise la couleur de fond du thème (souvent ScaffoldBackgroundColor)
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône dynamique selon l'état d'erreur
              Icon(
                _hasError ? Icons.wifi_off_rounded : Icons.downloading_rounded,
                size: 80,
                color: _hasError ? colorScheme.error : colorScheme.primary,
              ),
              const SizedBox(height: 30),
              // Texte d'état stylisé selon le thème
              Text(
                _loadingText,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: _hasError
                      ? colorScheme.error
                      : theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 30),
              if (_hasError)
                // Bouton de retry utilisant les couleurs d'erreur du thème
                ElevatedButton.icon(
                  onPressed: _checkAndStart,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Réessayer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  ),
                )
              else
                // Loader utilisant la couleur primaire du thème
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
