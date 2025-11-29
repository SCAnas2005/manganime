import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/providers/global_anime_favorites_provider.dart';
import 'package:flutter_application_1/providers/user_stats_provider.dart';
import 'package:flutter_application_1/viewmodels/anime_info_view_model.dart';
import 'package:flutter_application_1/widgets/like_widget/like_animation.dart';
import 'package:flutter_application_1/widgets/like_widget/like_button.dart';
import 'package:provider/provider.dart';

class AnimeInfoView extends StatefulWidget {
  final Anime anime;

  const AnimeInfoView({super.key, required this.anime});

  @override
  State<AnimeInfoView> createState() => _AnimeInfoViewState();
}

class _AnimeInfoViewState extends State<AnimeInfoView> {
  late Anime anime;
  @override
  void initState() {
    super.initState();
    anime = widget.anime;

    // Ajouter la vue à l’ouverture de la page
    UserStatsProvider.addAnimeView(anime.id);
  }

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
                  GestureDetector(
                    onDoubleTap: () {
                      vm.likeAnimeOnDoubleTap();
                      context
                          .read<GlobalAnimeFavoritesProvider>()
                          .toggleFavorite(anime);
                    },
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

                  // Bloc Score, Statut et Like
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Colonne Score + Statut
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Score : ${detail.score}"),
                          Text("Statut : ${detail.status}"),
                        ],
                      ),

                      const Spacer(),
                      // Bouton Like
                      LikeButton(
                        isLiked: vm.isLiked,
                        onTap: () {
                          vm.toggleLike();
                          context
                              .read<GlobalAnimeFavoritesProvider>()
                              .toggleFavorite(anime);
                        },
                        iconSize: 30,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

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
