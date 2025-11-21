import 'package:flutter/material.dart';
import 'package:flutter_application_1/viewmodels/favorite_view_model.dart';
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

    return ListView.builder(
      itemCount: vm.favoris.length,
      itemBuilder: (context, index) {
        final anime = vm.favoris[index];

        return ListTile(
          leading: Image.network(anime.imageUrl),
          title: Text(anime.title),
          subtitle: Text("Score : ${anime.score}"),
          trailing: LikeButton(
            isLiked: true,
            onTap: () => vm.removeFavoris(anime.id),
            iconSize: 30,
          ),
        );
      },
    );
  }
}
