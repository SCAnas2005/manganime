import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/global_anime_favorites_provider.dart';
import 'package:flutter_application_1/providers/global_manga_favorites_provider.dart';
import 'package:flutter_application_1/viewmodels/anime_view_model.dart';
import 'package:flutter_application_1/viewmodels/manga_view_model.dart';
import 'package:flutter_application_1/widgets/anime_card.dart';
import 'package:flutter_application_1/widgets/anime_list_tile.dart';
import 'package:flutter_application_1/widgets/display_mode/adaptative_display.dart';
import 'package:flutter_application_1/widgets/display_mode/display_mode.dart';
import 'package:flutter_application_1/widgets/display_mode/display_mode_toggle.dart';
import 'package:flutter_application_1/widgets/manga_card.dart';
import 'package:flutter_application_1/widgets/manga_list_tile.dart';
import 'package:flutter_application_1/widgets/ui/tab_switcher.dart';
import 'package:provider/provider.dart';

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
    final animeVM = context.watch<GlobalAnimeFavoritesProvider>();
    final mangaVM = context.watch<GlobalMangaFavoritesProvider>();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                "Mes favoris",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
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

  Widget _buildAnimeFavorites(GlobalAnimeFavoritesProvider vm) {
    final items = vm.loadedFavoriteAnimes;
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
        onTap: (_) {
          context.read<AnimeViewModel>().openAnimePage(context, anime);
        },
        onLikeDoubleTap: (_) => vm.toggleFavorite(anime),
        isLiked: vm.isAnimeLiked(anime.id),
      ),
      listbuilder: (anime) => AnimeListTile(
        anime: anime,
        isLiked: true,
        onTap: (anime) {
          context.read<AnimeViewModel>().openAnimePage(context, anime);
        },
        onLikeToggle: (anime) => vm.toggleFavorite(anime),
      ),
    );
  }

  Widget _buildMangaFavorites(GlobalMangaFavoritesProvider vm) {
    final items = vm.loadedFavoriteMangas;
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
      gridBuilder: (manga) => MangaCard(
        manga: manga,
        onTap: (manga) {
          context.read<MangaViewModel>().openMangaPage(context, manga);
        },
        onLikeDoubleTap: (manga) => vm.toggleFavorite(manga),
      ),
      listbuilder: (manga) {
        return MangaListTile(
          manga: manga,
          isLiked: true,
          onTap: (manga) {
            context.read<MangaViewModel>().openMangaPage(context, manga);
          },
          onLikeToggle: (manga) => vm.toggleFavorite(manga),
        );
      },
    );
  }
}
