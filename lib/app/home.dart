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

/// Page principale de l'application.
///
/// Elle gère la navigation entre les différentes sections
/// via une barre de navigation inférieure et affiche
/// les vues correspondantes (Anime, Manga, Favoris, Statistiques, Paramètres).
///
/// Elle permet également d'ouvrir directement un élément spécifique
/// (Anime ou Manga) et de définir l'onglet initial.
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

  /// Liste des pages affichées dans l'application.
  ///
  /// Chaque page correspond à un onglet de la barre de navigation
  /// et certaines sont encapsulées dans des providers dédiés.
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
  ];

  /// Initialise l'état de la page.
  ///
  /// Définit l'onglet actif à partir de l'index fourni,
  /// ou utilise le premier onglet par défaut.
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.indexPage ?? 0;
  }

  /// Construit l'interface principale de la page.
  ///
  /// Elle fournit les ViewModels nécessaires via des providers,
  /// affiche la page active à l'aide d'un [IndexedStack]
  /// et gère la navigation inférieure.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnimeViewModel()),
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
