import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/app.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  // Ouvre une box pour les likes
  await Hive.openBox<List>('likes_box');
  runApp(const App());
}
