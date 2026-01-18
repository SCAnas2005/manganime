import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/bottom_nav/bottom_nav_view.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/viewmodels/anime_view_model.dart';
import 'package:flutter_application_1/viewmodels/manga_view_model.dart';
import 'package:flutter_application_1/viewmodels/search_view_model.dart';
import 'package:flutter_application_1/views/anime_view.dart';
import 'package:flutter_application_1/views/app_settings_view.dart';
import 'package:flutter_application_1/views/favorite_view.dart';
import 'package:flutter_application_1/views/manga_view.dart';

import 'package:provider/provider.dart';
import 'package:flutter_application_1/views/anime_stat_view.dart';

class HomePage extends StatefulWidget {
  final String title;
  final int? indexPage;
  final Identifiable? identifiableToOpen;
  const HomePage({
    super.key,
    required this.title,
    this.indexPage,
    this.identifiableToOpen,
  });

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    ChangeNotifierProvider(
      create: (_) => AnimeViewModel(),
      child: AnimeView(
        animeToOpen: widget.identifiableToOpen is Anime
            ? widget.identifiableToOpen as Anime?
            : null,
      ),
    ),
    ChangeNotifierProvider(
      create: (_) => MangaViewModel(),
      child: MangaView(
        mangaToOpen: widget.identifiableToOpen is Manga
            ? widget.identifiableToOpen as Manga?
            : null,
      ),
    ),

    const FavoriteView(),
    AnimeStatView(),
    AppSettingsView(),
    // Center(
    //   child: Text(
    //     "Page en construction",
    //     style: TextStyle(fontSize: 24, color: Colors.grey),
    //   ),
    // ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.indexPage ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnimeViewModel()),
        ChangeNotifierProvider(create: (_) => MangaViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
      ],
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: BottomNavView(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
        ),
      ),
    );
  }
}
