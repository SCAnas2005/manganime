import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/viewmodels/anime_info_view_model.dart';
import 'package:flutter_application_1/widgets/like_widget/like_animation.dart';
import 'package:flutter_application_1/widgets/like_widget/like_button.dart';
import 'package:provider/provider.dart';

class AnimeInfoView extends StatelessWidget {
  final Anime anime;

  const AnimeInfoView(this.anime, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Initialise le ViewModel et charge les données
      create: (_) => AnimeInfoViewModel()..loadAnimeDetail(anime.id),
      child: Consumer<AnimeInfoViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Erreur
          if (vm.hasError || vm.animeDetail == null) {
            return Scaffold(
              appBar: AppBar(title: Text(anime.title)),
              body: const Center(
                child: Text("Erreur lors du chargement des données"),
              ),
            );
          }
          final detail = vm.animeDetail!;

          return Scaffold(
            appBar: AppBar(title: Text(detail.title)),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image + animation du like au double tap
                  // Image + animation du like au double tap
                  GestureDetector(
                    onDoubleTap: vm.likeAnimeOnDoubleTap,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(detail.imageUrl),
                        LikeAnimation(show: vm.showLikeAnimation),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Titre
                  Text(
                    detail.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),

                  // Score
                  Text("Score : ${detail.score}"),
                  const SizedBox(height: 8),

                  // Statut
                  Text("Statut : ${detail.status}"),
                  const SizedBox(height: 16),

                  // Bouton like
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      LikeButton(isLiked: vm.isLiked, onTap: vm.toggleLike),
                      Text(vm.isLiked ? "Vous avez aimé" : "Like"),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Synopsis traduit
                  Text(
                    vm.translatedSynopsis.isNotEmpty
                        ? vm.translatedSynopsis
                        : "Chargement de la traduction...",
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
