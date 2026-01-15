import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_application_1/providers/global_anime_favorites_provider.dart';
import 'package:flutter_application_1/providers/global_manga_favorites_provider.dart';
import 'package:flutter_application_1/viewmodels/anime_view_model.dart';
import 'package:flutter_application_1/viewmodels/manga_view_model.dart';
import 'package:flutter_application_1/viewmodels/search_view_model.dart';
import 'package:flutter_application_1/viewmodels/manga_search_view_model.dart';
import 'package:flutter_application_1/widgets/anime_card.dart';
import 'package:flutter_application_1/widgets/manga_card.dart';
import 'package:provider/provider.dart';

class Search extends StatefulWidget {
  /// true = recherche anime, false = recherche manga
  final bool isAnime;

  const Search({super.key, this.isAnime = true});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  int index = 0;
  String _selectedFilter = 'Note'; // Filtre par défaut
  final List<String> filters = ['Popularité', 'Note', 'date de sortie'];
  final List<String> mainGenres = [
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Fantasy',
    'Horror',
    'Mecha',
    'Music',
    'Romance',
    'SciFi',
    'SliceOfLife',
    'Sports',
  ];
  Set<String> selectedGenres = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.isAnime) {
        context.read<SearchViewModel>().searchEmpty(filter: _selectedFilter);
      } else {
        context.read<MangaSearchViewModel>().searchEmpty(filter: _selectedFilter);
      }
    });
  }

  void _onSearchTextChanged(String text) {
    if (widget.isAnime) {
      context.read<SearchViewModel>().onSearchTextChanged(text, _selectedFilter);
    } else {
      context.read<MangaSearchViewModel>().onSearchTextChanged(text, _selectedFilter);
    }
  }

  void _onFilterChanged() {
    if (widget.isAnime) {
      context.read<SearchViewModel>().onFilterChanged(_selectedFilter);
    } else {
      context.read<MangaSearchViewModel>().onFilterChanged(_selectedFilter);
    }
  }

  void _updateSelectedGenres() {
    if (widget.isAnime) {
      context.read<SearchViewModel>().updateSelectedGenres(selectedGenres);
    } else {
      context.read<MangaSearchViewModel>().updateSelectedGenres(selectedGenres);
    }
  }

  List<Identifiable> _getResults() {
    if (widget.isAnime) {
      return context.watch<SearchViewModel>().results;
    } else {
      return context.watch<MangaSearchViewModel>().results;
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _getResults();

    if (suggestions.isNotEmpty) {
      index = index % suggestions.length;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAnime ? "Recherche Anime" : "Recherche Manga"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: SearchBar(
              hintText: widget.isAnime ? "Rechercher un anime" : "Rechercher un manga",
              onChanged: (text) => _onSearchTextChanged(text),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PopupMenuButton<String>(
                  child: SizedBox(
                    width: 170,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedGenres.isEmpty
                            ? "Choisir les genres"
                            : selectedGenres.join(", "),
                      ),
                    ),
                  ),
                  itemBuilder: (context) => mainGenres.map((genre) {
                    final isSelected = selectedGenres.contains(genre);
                    return CheckedPopupMenuItem<String>(
                      value: genre,
                      checked: isSelected,
                      child: Text(genre),
                    );
                  }).toList(),
                  onSelected: (genre) {
                    setState(() {
                      if (selectedGenres.contains(genre)) {
                        selectedGenres.remove(genre);
                      } else {
                        selectedGenres.add(genre);
                      }
                      _updateSelectedGenres();
                    });
                  },
                ),
                DropdownButton<String>(
                  value: _selectedFilter,
                  items: filters
                      .map(
                        (filters) => DropdownMenuItem(
                          value: filters,
                          child: Text(filters),
                        ),
                      )
                      .toList(),
                  onChanged: (newValue) async {
                    if (newValue != null) {
                      setState(() {
                        _selectedFilter = newValue;
                      });
                      _onFilterChanged();
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          if (suggestions.isNotEmpty)
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: suggestions.length,
                itemBuilder: (context, i) {
                  final item = suggestions[i];

                  if (widget.isAnime && item is Anime) {
                    final vm = context.read<AnimeViewModel>();
                    return AnimeCard(
                      anime: item,
                      onTap: (anime) => vm.openAnimePage(context, anime),
                      onLikeDoubleTap: (anime) => {
                        context
                            .read<GlobalAnimeFavoritesProvider>()
                            .toggleFavorite(anime),
                      },
                      isLiked: context
                          .read<GlobalAnimeFavoritesProvider>()
                          .isAnimeLiked(item.id),
                    );
                  } else if (!widget.isAnime && item is Manga) {
                    final vm = context.read<MangaViewModel>();
                    return MangaCard(
                      manga: item,
                      onTap: (manga) => vm.openMangaPage(context, manga),
                      onLikeDoubleTap: (manga) => {
                        context
                            .read<GlobalMangaFavoritesProvider>()
                            .toggleFavorite(manga),
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
        ],
      ),
    );
  }
}
