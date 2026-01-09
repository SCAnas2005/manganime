import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';
import 'package:flutter_application_1/providers/anime_repository_provider.dart';
import 'package:flutter_application_1/providers/global_anime_favorites_provider.dart';
import 'package:flutter_application_1/providers/user_stats_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/viewmodels/anime_info_view_model.dart';
import 'package:flutter_application_1/widgets/like_widget/like_animation.dart';
import 'package:flutter_application_1/widgets/like_widget/like_button.dart';
import 'package:intl/intl.dart';
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
      debugPrint("Erreur chargement image : $e");
      if (mounted) {
        setState(() {
          _hasCoverError = true;
          _animeCover = null;
        });
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "?";
    return DateFormat.yMMMd().format(date);
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
                child: Text("Oups ! Impossible de charger les détails."),
              ),
            );
          }
          final animeInfo = vm.anime!;

          return Scaffold(
            body: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // --- 1. L'IMAGE EN HAUT (SLIVER APP BAR) ---
                    SliverAppBar(
                      expandedHeight: 400.0,
                      pinned: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.black45,
                          child: const BackButton(color: Colors.white),
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
                              _buildCoverImage(),
                              // Dégradé pour la lisibilité
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black38,
                                      Colors.transparent,
                                      Colors.black54,
                                    ],
                                  ),
                                ),
                              ),
                              Center(
                                child: LikeAnimation(
                                  show: vm.showLikeAnimation,
                                  size: 100,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // --- 2. LE CONTENU (CARTE BLANCHE) ---
                    SliverToBoxAdapter(
                      child: Container(
                        transform: Matrix4.translationValues(0, -20, 0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ligne Titre + Like Button
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      animeInfo.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            height: 1.1,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  LikeButton(
                                    isLiked: vm.isLiked,
                                    onTap: () {
                                      vm.toggleLike();
                                      context
                                          .read<GlobalAnimeFavoritesProvider>()
                                          .toggleFavorite(anime);
                                    },
                                    iconSize: 32,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // --- 3. GRID D'INFOS (Score, Statut, Date) ---
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildInfoColumn(
                                      context,
                                      icon: Icons.star_rounded,
                                      color: Colors.amber,
                                      label: "Score",
                                      value: animeInfo.score != null
                                          ? animeInfo.score!.toStringAsFixed(1)
                                          : "N/A",
                                    ),
                                    _buildVerticalDivider(context),
                                    _buildInfoColumn(
                                      context,
                                      icon: _getStatusIcon(animeInfo.status),
                                      color: _getStatusColor(animeInfo.status),
                                      label: "Statut",
                                      value: animeInfo.status.key,
                                    ),
                                    _buildVerticalDivider(context),
                                    _buildInfoColumn(
                                      context,
                                      icon: Icons.calendar_today_rounded,
                                      color: Colors.blueAccent,
                                      label: "Année",
                                      value:
                                          animeInfo.startDate?.year
                                              .toString() ??
                                          "?",
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // --- 4. DATES DE DIFFUSION ---
                              _buildSectionTitle(context, "Diffusion"),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.date_range,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${_formatDate(animeInfo.startDate)} — ${_formatDate(animeInfo.endDate)}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // --- 5. GENRES ---
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: animeInfo.genres
                                    .where((g) => g != Genres.None)
                                    .map(
                                      (g) => Chip(
                                        label: Text(g.toReadableString()),
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                        labelStyle: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        side: BorderSide.none,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),

                              const SizedBox(height: 24),

                              // --- 6. SYNOPSIS ---
                              _buildSectionTitle(context, "Synopsis"),
                              const SizedBox(height: 12),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: vm.translatedSynopsis != "error"
                                    ? Text(
                                        vm.translatedSynopsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              height: 1.6,
                                              fontSize: 16,
                                              color: Colors.grey[800],
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
                              // Espace pour le scroll
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS UTILITAIRES ---

  Widget _buildCoverImage() {
    if (_hasCoverError) {
      return Container(
        color: Colors.grey[900],
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.white24, size: 50),
        ),
      );
    }
    if (_animeCover != null) {
      return Hero(
        tag: "anime_cover_${widget.anime.id}",
        child: FittedBox(fit: BoxFit.cover, child: _animeCover!),
      );
    }
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white10),
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(color: Colors.grey[600], fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return Container(height: 30, width: 1, color: Colors.grey[300]);
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  // Logique UI pour le statut
  IconData _getStatusIcon(MediaStatus status) {
    switch (status) {
      case MediaStatus.airing:
        return Icons.play_circle_fill;
      case MediaStatus.complete:
        return Icons.check_circle;
      case MediaStatus.upcoming:
        return Icons.schedule;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(MediaStatus status) {
    switch (status) {
      case MediaStatus.airing:
        return Colors.green;
      case MediaStatus.complete:
        return Colors.blueGrey;
      case MediaStatus.upcoming:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
