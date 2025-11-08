import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/home.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MangAnime",
      theme: ThemeData.dark(),
      home: HomePage(title: "MangAnime"),
    );
  }
}
