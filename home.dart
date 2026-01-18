import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ViewModels
import 'package:flutter_application_1/viewmodels/anime_view_model.dart';
import 'package:flutter_application_1/viewmodels/manga_view_model.dart';
import 'package:flutter_application_1/viewmodels/search_view_model.dart';

// Models
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/models/identifiable.dart';

// Views
import 'package:flutter_application_1/views/anime_view.dart';
import 'package:flutter_application_1/views/manga_view.dart';
import 'package:flutter_application_1/views/favorite_view.dart';
import 'package:flutter_application_1/views/anime_stat_view.dart';
import 'package:flutter_application_1/views/app_settings_view.dart';

// Bottom nav
import 'package:flutter_application_1/app/bottom_nav/bottom_nav_view.dart';

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
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.indexPage ?? 0;
  }

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
        const AnimeStatView(),
        const AppSettingsView(),
      ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
      ],
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Image.asset(
            isDark
                ? 'assets/icons/app_icon.png'
                : 'assets/icons/logo_manganime.png',
            height: 35,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.movie_filter),
          ),
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavView(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
