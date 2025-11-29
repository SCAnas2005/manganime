import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/global_manga_favorites_provider.dart';
import 'package:flutter_application_1/viewmodels/manga_info_view_model.dart';
import 'package:flutter_application_1/widgets/like_widget/like_animation.dart';
import 'package:flutter_application_1/widgets/like_widget/like_button.dart';
import 'package:provider/provider.dart';

class MangaInfoView extends StatelessWidget {
  final Manga manga;

  const MangaInfoView(this.manga, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MangaInfoViewModel()..loadMangaDetail(manga.id),
      child: Consumer<MangaInfoViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (vm.hasError || vm.mangaDetail == null) {
            return Scaffold(
              appBar: AppBar(title: Text(manga.title)),
              body: const Center(
                child: Text("Erreur lors du chargement des données"),
              ),
            );
          }

          final detail = vm.mangaDetail!;

          return Scaffold(
            appBar: AppBar(title: Text(detail.title)),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onDoubleTap: () {
                      vm.likeMangaOnDoubleTap();
                      context
                          .read<GlobalMangaFavoritesProvider>()
                          .toggleFavorite(manga);
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
                  Text(
                    detail.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Score : ${detail.score}"),
                          Text("Statut : ${detail.status}"),
                          Text("Type : ${detail.type}"),
                        ],
                      ),
                      const Spacer(),
                      LikeButton(
                        isLiked: vm.isLiked,
                        onTap: () {
                          vm.toggleLike();
                          context
                              .read<GlobalMangaFavoritesProvider>()
                              .toggleFavorite(manga);
                        },
                        iconSize: 30,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    detail.genres.join(", "),
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),
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
