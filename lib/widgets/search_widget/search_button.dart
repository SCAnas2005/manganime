import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/viewmodels/anime_view_model.dart';
import 'package:flutter_application_1/viewmodels/manga_view_model.dart';
import 'package:flutter_application_1/widgets/Search.dart';
import 'package:flutter_application_1/viewmodels/search_view_model.dart';
import 'package:flutter_application_1/viewmodels/manga_search_view_model.dart';

/// Bouton de recherche pour les animes
Widget miniSearchBar(BuildContext context) {
  return InkWell(
    onTap: () {
      final vm = context.read<AnimeViewModel>();
      final searchViewModel = SearchViewModel();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: vm),
              ChangeNotifierProvider.value(value: searchViewModel),
            ],
            child: const Search(isAnime: true),
          ),
        ),
      );
    },
    child: Icon(
      Icons.search,
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.black
          : Colors.white,
    ),
  );
}

/// Bouton de recherche pour les mangas
Widget miniSearchBarManga(BuildContext context) {
  return InkWell(
    onTap: () {
      final vm = context.read<MangaViewModel>();
      final searchViewModel = MangaSearchViewModel();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: vm),
              ChangeNotifierProvider.value(value: searchViewModel),
            ],
            child: const Search(isAnime: false),
          ),
        ),
      );
    },
    child: Icon(
      Icons.search,
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.black
          : Colors.white,
    ),
  );
}
