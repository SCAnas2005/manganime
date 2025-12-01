import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ScreenTimeProvider with WidgetsBindingObserver {
  static const String BOX_NAME = "screen_time_box";
  static const String TOTAL_TIME_KEY = "total_time_seconds";

  static final Box _box = Hive.box(BOX_NAME);
  
  Timer? _timer;
  int _sessionSeconds = 0;

  // Modèle singleton pour garantir qu'une seule instance gère l'observateur
  static final ScreenTimeProvider _instance = ScreenTimeProvider._internal();
  factory ScreenTimeProvider() => _instance;
  ScreenTimeProvider._internal();

  static Future<void> init() async {
    await Hive.openBox(BOX_NAME);
  }

  void startTracking() {
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  void stopTracking() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    _saveTime();
  }

  void _startTimer() {
    _stopTimer(); // Assurez-vous qu'aucun minuteur existant n'est en cours
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _sessionSeconds++;
      // Optionnel : Enregistrer périodiquement (par exemple, chaque minute) pour éviter la perte de données en cas de plantage
      if (_sessionSeconds % 60 == 0) {
        _saveTime();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _saveTime() async {
    if (_sessionSeconds > 0) {
      final currentTotal = getTotalScreenTime();
      await _box.put(TOTAL_TIME_KEY, currentTotal + _sessionSeconds);
      _sessionSeconds = 0; // Réinitialiser le compteur de session après l'enregistrement
    }
  }

  static int getTotalScreenTime() {
    return _box.get(TOTAL_TIME_KEY, defaultValue: 0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTimer();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _stopTimer();
      _saveTime();
    }
  }
}
