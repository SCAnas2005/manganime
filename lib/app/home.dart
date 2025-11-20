import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/bottom_nav/bottom_nav_view.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/viewmodels/anime_view_model.dart';
import 'package:flutter_application_1/views/anime_view.dart';
import 'package:flutter_application_1/views/favorite_anime_view.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  List<Anime> _allAnimesUnique = [];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // final List<Widget> _pages = [
  //   ChangeNotifierProvider(
  //     create: (_) => AnimeViewModel(),
  //     child: const AnimeView(),
  //   ),
  // ];

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: _currentIndex >= _pages.length
  //         ? Container()
  //         : _pages[_currentIndex],
  //     bottomNavigationBar: BottomNavView(
  //       currentIndex: _currentIndex,
  //       onTap: (index) => setState(() => _currentIndex = index),
  //     ),
  //   );
  // }

  void _updateAllAnimesUnique(AnimeViewModel animeVM) {
    final Map<int, Anime> animeMap = {};
    for (var anime in [
      ...animeVM.popular,
      ...animeVM.airing,
      ...animeVM.mostLiked,
    ]) {
      animeMap[anime.id] = anime;
    }
    _allAnimesUnique = animeMap.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => AnimeViewModel(),
      child: Consumer<AnimeViewModel>(
        builder: (context, animeVM, _) {
          _updateAllAnimesUnique(animeVM);
          final pages = [
            AnimeView(),
            FavoriteAnimeView(allAnimes: _allAnimesUnique),
          ];

          return Scaffold(
            body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: pages,
            ),
            bottomNavigationBar: BottomNavView(
              currentIndex: _currentIndex,
              onTap: (index) {
                _pageController.jumpToPage(index);
                setState(() => _currentIndex = index);
              },
            ),
          );
        },
      ),
    );
  }
}
