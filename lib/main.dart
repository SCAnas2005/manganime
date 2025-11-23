import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/app.dart';
import 'package:flutter_application_1/providers/like_storage.dart';
import 'package:flutter_application_1/providers/user_stats_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  // Ouvre une box pour les likes
  LikeStorage.init();
  // Ouvre une box pour les vues
  UserStatsProvider.init();

  runApp(const App());
}
