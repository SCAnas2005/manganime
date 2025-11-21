import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/widgets/anime_list_item.dart';
import 'package:provider/provider.dart';
import '../viewmodels/favorite_view_model.dart';

class FavoriteAnimeView extends StatelessWidget {
  final List<Anime> allAnimes;
  const FavoriteAnimeView({super.key, required this.allAnimes});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FavoriteViewModel(allAnimes: allAnimes)..loadFavorites(),
      child: Consumer<FavoriteViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.favoriteAnimes.isEmpty) {
            return const Center(
              child: Text(
                "Aucun anime en favoris",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: viewModel.favoriteAnimes.length,
            itemBuilder: (context, index) {
              final item = viewModel.favoriteAnimes[index];

              return AnimeListItem(
                anime: item.toAnime(),
                onLikeToggle: () => viewModel.removeFavorite(item),
              );
            },
          );
        },
      ),
    );
  }
}
