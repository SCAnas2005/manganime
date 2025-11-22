import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/viewmodels/favorite_view_model.dart';
import 'package:flutter_application_1/widgets/anime_card.dart';
import 'package:flutter_application_1/widgets/anime_list_item.dart';
import 'package:flutter_application_1/widgets/like_widget/like_button.dart';
import 'package:provider/provider.dart';

class FavoriteAnimeView extends StatelessWidget {
  const FavoriteAnimeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FavoriteViewModel>();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.favoris.isEmpty) {
      return const Center(child: Text("Aucun favori pour le moment"));
    }

    // return ListView.builder(
    //   itemCount: vm.favoris.length,
    //   itemBuilder: (context, index) {
    //     final anime = Anime.fromDetail(vm.favoris[index]);

    //     return AnimeListItem(
    //       anime: anime,
    //       onTap: () => {},
    //       isLiked: true,
    //       onLikeToggle: () => vm.removeFavoris(anime.id),
    //     );
    //   },
    // );

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: vm.favoris.length,
      itemBuilder: (context, index) {
        final anime = Anime.fromDetail(vm.favoris[index]);

        return AnimeCard(
          anime: anime,
          onTap: (anime) =>
              {}, // Test console : print('Tapped ${anime.title}'),
          onLikeDoubleTap: (anime) => vm.removeFavoris(anime.id),
        );
      },
    );
  }
}
