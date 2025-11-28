import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/bottom_nav/bottom_nav_view.dart';
import 'package:flutter_application_1/viewmodels/anime_view_model.dart';
import 'package:flutter_application_1/viewmodels/favorite_anime_view_model.dart';
import 'package:flutter_application_1/viewmodels/favorite_manga_view_model.dart';
import 'package:flutter_application_1/viewmodels/manga_view_model.dart';
import 'package:flutter_application_1/views/anime_view.dart';
import 'package:flutter_application_1/views/favorite_view.dart';
import 'package:flutter_application_1/views/manga_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/views/anime_stat_view.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ChangeNotifierProvider(
      create: (_) => AnimeViewModel(),
      child: const AnimeView(),
    ),
    ChangeNotifierProvider(
      create: (_) => MangaViewModel(),
      child: const MangaView(),
    ),
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoriteAnimeViewModel()),
        ChangeNotifierProvider(create: (_) => FavoriteMangaViewModel()),
      ],
      child: const FavoriteView(),
    ),
    AnimeStatView(),
    Container(),

    AnimeStatView(),
    Container(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex >= _pages.length
          ? Container()
          : _pages[_currentIndex],
      bottomNavigationBar: BottomNavView(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
