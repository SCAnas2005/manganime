import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/global_manga_favorites_provider.dart';
import 'package:flutter_application_1/providers/manga_repository_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/viewmodels/manga_info_view_model.dart';
import 'package:flutter_application_1/widgets/like_widget/like_animation.dart';
import 'package:flutter_application_1/widgets/like_widget/like_button.dart';
import 'package:provider/provider.dart';

class MangaInfoView extends StatefulWidget {
  final Manga manga;

  const MangaInfoView(this.manga, {super.key});

  @override
  State<StatefulWidget> createState() => MangaInfoViewState();
}

class MangaInfoViewState extends State<MangaInfoView> {
  late Manga manga;

  Image? _mangaCover;
  bool _hasCoverError = false;

  @override
  void initState() {
    super.initState();
    manga = widget.manga;
    _loadAnimeCover();
  }

  Future<void> _loadAnimeCover() async {
    try {
      // On tente de récupérer l'image
      final image = await MangaRepository(
        api: JikanService(),
      ).getMangaImage(widget.manga);

      if (mounted) {
        setState(() {
          _mangaCover = image;
          _hasCoverError = false;
        });
      }
    } catch (e) {
      // CRASH : Pas d'internet et pas de fichier local
      debugPrint("Erreur chargement image : $e");

      if (mounted) {
        setState(() {
          _hasCoverError = true;
          _mangaCover = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MangaInfoViewModel(manga: manga)..loadMangaDetail(),
      child: Consumer<MangaInfoViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (vm.hasError) {
            return Scaffold(
              appBar: AppBar(title: Text(manga.title)),
              body: const Center(
                child: Text("Erreur lors du chargement des données"),
              ),
            );
          }

          final mangaInfo = vm.manga;

          return Scaffold(
            appBar: AppBar(title: Text(mangaInfo.title)),
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
                        if (_hasCoverError)
                          // 1. CAS ERREUR
                          Container(
                            color: Colors.grey[900],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.white24,
                                  size: 32,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Erreur",
                                  style: TextStyle(
                                    color: Colors.white24,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (_mangaCover != null)
                          // 2. CAS SUCCÈS
                          _mangaCover!
                        else
                          // 3. CAS CHARGEMENT (Par défaut)
                          Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white10,
                              ),
                            ),
                          ),
                        LikeAnimation(show: vm.showLikeAnimation),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    mangaInfo.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Score : ${mangaInfo.score}"),
                          Text("Statut : ${mangaInfo.status}"),
                          Text("Type : ${mangaInfo.type}"),
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
                    mangaInfo.genres.join(", "),
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
