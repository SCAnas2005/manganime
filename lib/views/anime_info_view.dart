import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/anime_enums.dart';
import 'package:flutter_application_1/providers/anime_repository_provider.dart';
import 'package:flutter_application_1/providers/global_anime_favorites_provider.dart';
import 'package:flutter_application_1/providers/user_stats_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
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
  Image? _animeCover;
  bool _hasCoverError = false;

  @override
  void initState() {
    super.initState();
    anime = widget.anime;
    UserStatsProvider.addAnimeView(anime.id);

    _loadAnimeCover();
  }

  Future<void> _loadAnimeCover() async {
    try {
      // On tente de récupérer l'image
      final image = await AnimeRepository(
        api: JikanService(),
      ).getAnimeImage(widget.anime);

      if (mounted) {
        setState(() {
          _animeCover = image;
          _hasCoverError = false;
        });
      }
    } catch (e) {
      // CRASH : Pas d'internet et pas de fichier local
      debugPrint("Erreur chargement image : $e");

      if (mounted) {
        setState(() {
          _hasCoverError = true;
          _animeCover = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          AnimeInfoViewModel(anime: widget.anime)..loadAnimeDetail(anime.id),
      child: Consumer<AnimeInfoViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (vm.hasError || vm.anime == null) {
            return Scaffold(
              appBar: AppBar(title: Text(anime.title)),
              body: const Center(
                child: Text("Erreur lors du chargement des données"),
              ),
            );
          }
          final animeInfo = vm.anime!;

          // Utilisation d'un CustomScrollView pour le SliverAppBar flexible
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                // --- En-tête Flexible avec l'Image ---
                SliverAppBar(
                  expandedHeight: 350.0, // Hauteur de l'image déployée
                  pinned: true, // La barre reste visible en haut lors du scroll
                  leading: const BackButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.black45),
                      iconColor: WidgetStatePropertyAll(Colors.white),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: GestureDetector(
                      onDoubleTap: () {
                        vm.likeAnimeOnDoubleTap();
                        context
                            .read<GlobalAnimeFavoritesProvider>()
                            .toggleFavorite(anime);
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // L'image de l'anime
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
                          else if (_animeCover != null)
                            // 2. CAS SUCCÈS
                            _animeCover!
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
                          // Image.network(
                          //   animeInfo.imageUrl,
                          //   fit: BoxFit.cover,
                          //   errorBuilder: (context, error, stackTrace) =>
                          //       const Center(child: Icon(Icons.error)),
                          // ),
                          // Un dégradé sombre en bas pour la lisibilité du texte
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black87],
                                stops: [0.6, 1.0],
                              ),
                            ),
                          ),
                          // L'animation du cœur au double tap
                          Center(
                            child: LikeAnimation(show: vm.showLikeAnimation),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // --- Contenu de la page ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Titre, Score et Like ---
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    animeInfo.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  // Bloc Score et Statut avec des icônes
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        animeInfo.score != null &&
                                                animeInfo.score! > 0
                                            ? animeInfo.score!.toStringAsFixed(
                                                1,
                                              )
                                            : "N/A",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      _buildStatusChip(animeInfo.status),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Bouton Like
                            LikeButton(
                              isLiked: vm.isLiked,
                              onTap: () {
                                vm.toggleLike();
                                context
                                    .read<GlobalAnimeFavoritesProvider>()
                                    .toggleFavorite(anime);
                              },
                              iconSize: 36, // Un peu plus gros
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // --- Liste des Genres (Tags) ---
                        Wrap(
                          spacing: 8.0, // Espace horizontal entre les tags
                          runSpacing:
                              4.0, // Espace vertical si ça passe à la ligne
                          children: animeInfo.genres
                              .where((g) => g != AnimeGenre.None)
                              .map(
                                (genre) => Chip(
                                  label: Text(genre.toReadableString()),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  labelStyle: const TextStyle(fontSize: 12),
                                  padding: EdgeInsets
                                      .zero, // Rendre le chip plus compact
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              )
                              .toList(),
                        ),

                        const SizedBox(height: 24),
                        const Divider(), // Une petite ligne de séparation
                        const SizedBox(height: 16),

                        // --- Synopsis ---
                        Text(
                          "Synopsis",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: vm.translatedSynopsis != "error"
                              ? Text(
                                  vm.translatedSynopsis,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        height: 1.5, // Meilleur interlignage
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color,
                                      ),
                                )
                              : Row(
                                  children: const [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Traduction en cours...",
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 30), // Espace en bas de page
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Petit widget utilitaire pour le statut
  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    // Logique simple pour la couleur et l'icône du statut
    if (status.toLowerCase().contains("airing")) {
      color = Colors.green;
      icon = Icons.play_circle_outline;
    } else if (status.toLowerCase().contains("finished")) {
      color = Colors.blueGrey;
      icon = Icons.check_circle_outline;
    } else {
      color = Colors.grey;
      icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
