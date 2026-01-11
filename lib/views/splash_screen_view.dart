import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/home.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_application_1/providers/boot_loader.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_application_1/providers/settings_repository_provider.dart';
import 'package:flutter_application_1/providers/settings_storage_provider.dart';

class SplashScreen extends StatefulWidget {
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

  Future<void> _checkAndStart() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _loadingText = "Analyse...");

    var settingsRepo = SettingsRepositoryProvider(SettingsStorage.instance);
    final settings = settingsRepo.getSettings();

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
      }
    } else {
      debugPrint("Mode Hors-Ligne supporté");
    }

    try {
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _hasError ? Icons.wifi_off_rounded : Icons.downloading_rounded,
                size: 80,
                color: _hasError ? Colors.red : Colors.blue,
              ),
              const SizedBox(height: 30),
              Text(
                _loadingText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _hasError ? Colors.red : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 30),
              if (_hasError)
                ElevatedButton.icon(
                  onPressed: _checkAndStart, // On relance la vérif
                  icon: const Icon(Icons.refresh),
                  label: const Text("Réessayer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                )
              else
                const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
