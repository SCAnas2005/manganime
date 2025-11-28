import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/anime_list.dart';
import 'package:flutter_application_1/widgets/display_mode/adaptative_display.dart';
import 'package:flutter_application_1/widgets/display_mode/display_mode.dart';
import 'package:flutter_application_1/widgets/display_mode/display_mode_toggle.dart';
import 'package:provider/provider.dart';
import '../viewmodels/favorite_anime_view_model.dart';
import '../viewmodels/favorite_manga_view_model.dart';
import '../widgets/ui/tab_switcher.dart';
import '../widgets/anime_card.dart';
import '../widgets/manga_card.dart';
import '../models/anime.dart';
import '../models/manga.dart';

enum FavoriteDisplayMode { grid, list }

class FavoriteView extends StatefulWidget {
  const FavoriteView({super.key});

  @override
  State<FavoriteView> createState() => _FavoriteViewState();
}

class _FavoriteViewState extends State<FavoriteView> {
  int selectedTab = 0;
  DisplayMode displayMode = DisplayMode.grid;

  @override
  Widget build(BuildContext context) {
    final animeVM = context.watch<FavoriteAnimeViewModel>();
    final mangaVM = context.watch<FavoriteMangaViewModel>();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "Mes favoris",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 16),

          TabSwitcher(
            tabs: const ["Animes", "Mangas"],
            selectedIndex: selectedTab,
            onChanged: (index) => setState(() => selectedTab = index),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: DisplayModeToggle(
                mode: displayMode,
                onChanged: (m) => setState(() => displayMode = m),
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: selectedTab == 0
                  ? _buildAnimeFavorites(animeVM)
                  : _buildMangaFavorites(mangaVM),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimeFavorites(FavoriteAnimeViewModel vm) {
    final items = vm.favoris.map((d) => Anime.fromDetail(d)).toList();
    if (items.isEmpty) {
      return const Center(
        child: Text(
          "Aucun favori pour le moment",
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return AdaptativeDisplay<Anime>(
      mode: displayMode,
      items: items,
      gridBuilder: (anime) => AnimeCard(
        anime: anime,
        onTap: (_) {},
        onLikeDoubleTap: (_) => vm.removeFavoris(anime.id),
      ),
      listbuilder: (anime) => AnimeList(
        anime: anime,
        isLiked: true,
        onTap: () {},
        onLikeToggle: () => vm.removeFavoris(anime.id),
      ),
    );
  }

  Widget _buildMangaFavorites(FavoriteMangaViewModel vm) {
    final items = vm.favoris.map((d) => Manga.fromDetail(d)).toList();
    if (items.isEmpty) {
      return const Center(
        child: Text(
          "Aucun favori pour le moment",
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return AdaptativeDisplay<Manga>(
      mode: displayMode,
      items: items,
      gridBuilder: (manga) => MangaCard(manga: manga, onTap: (_) {}),
      listbuilder: (manga) {
        // TODO : Créer MangaList
        return ListTile(
          leading: Image.network(manga.imageUrl, width: 55),
          title: Text(manga.title),
        );
      },
    );
  }
}
