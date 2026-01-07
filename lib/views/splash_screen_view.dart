import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/home.dart';
import 'package:flutter_application_1/providers/boot_loader.dart';
import 'package:flutter_application_1/services/network_service.dart'; // Ton service réseau

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _loadingText = "Initialisation...";
  bool _hasError = false; // Nouvel état pour gérer l'erreur

  @override
  void initState() {
    super.initState();
    _startAppProcess();
  }

  Future<void> _startAppProcess() async {
    setState(() {
      _hasError = false;
      _loadingText = "Vérification de la connexion...";
    });

    bool isConnected = await NetworkService.isConnected;

    if (!isConnected) {
      setState(() {
        _hasError = true;
        _loadingText = "Aucune connexion internet détectée.";
      });
      return;
    }

    try {
      await BootLoader.onAppStart(
        onStatusChanged: (message) {
          setState(() {
            _loadingText = message;
          });
        },
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage(title: "MangAnime")),
        );
      }
    } catch (e) {
      debugPrint("Erreur BootLoader: $e");
      setState(() {
        _hasError = true;
        _loadingText = "Une erreur est survenue pendant le chargement.";
      });
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
              // --- ICONE (Change selon l'état) ---
              Icon(
                _hasError ? Icons.wifi_off_rounded : Icons.downloading_rounded,
                size: 80,
                color: _hasError ? Colors.red : Colors.blue,
              ),
              const SizedBox(height: 30),

              // --- TEXTE D'ÉTAT ---
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

              // --- BOUTON RETRY OU LOADER ---
              if (_hasError)
                ElevatedButton.icon(
                  onPressed: _startAppProcess, // Relance la fonction
                  icon: const Icon(Icons.refresh),
                  label: const Text("Réessayer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
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
