import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/global_manga_favorites_provider.dart'; // Assure-toi d'avoir ce provider ou équivalent
import 'package:flutter_application_1/providers/manga_repository_provider.dart';
import 'package:flutter_application_1/providers/user_stats_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/viewmodels/manga_info_view_model.dart'; // Assure-toi de créer ce ViewModel similaire à l'Anime
import 'package:flutter_application_1/widgets/like_widget/like_animation.dart';
import 'package:flutter_application_1/widgets/like_widget/like_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MangaInfoView extends StatefulWidget {
  final Manga manga;

  const MangaInfoView(this.manga, {super.key});

  @override
  State<MangaInfoView> createState() => _MangaInfoViewState();
}

class _MangaInfoViewState extends State<MangaInfoView> {
  late Manga manga;
  Image? _mangaCover;
  bool _hasCoverError = false;

  @override
  void initState() {
    super.initState();
    manga = widget.manga;
    // Enregistrement de la vue
    UserStatsProvider.addMangaView(manga.id);
    _loadMangaCover();
  }

  Future<void> _loadMangaCover() async {
    try {
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
      debugPrint("Erreur chargement image manga : $e");
      if (mounted) {
        setState(() {
          _hasCoverError = true;
          _mangaCover = null;
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
    // On suppose que tu as un MangaInfoViewModel similaire à AnimeInfoViewModel
    return ChangeNotifierProvider(
      create: (_) => MangaInfoViewModel(manga: widget.manga)..loadMangaDetail(),
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
                child: Text("Impossible de charger les détails du manga."),
              ),
            );
          }
          final mangaInfo = vm.manga!;

          return Scaffold(
            // Utilisation d'un Stack pour gérer le fond flouté et le contenu
            body: Stack(
              children: [
                // --- 1. ARRIÈRE-PLAN FLOUTÉ (AMBIANCE) ---
                Positioned.fill(
                  bottom: MediaQuery.of(context).size.height * 0.55,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildBlurBackground(),
                      // Filtre sombre
                      Container(color: Colors.black.withValues(alpha: 0.4)),
                      // Effet de flou
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(color: Colors.transparent),
                      ),
                    ],
                  ),
                ),

                // --- 2. CONTENU SCROLLABLE ---
                SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      // Barre de navigation minimaliste
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        leading: const BackButton(color: Colors.white),
                        actions: [
                          // Petit bouton like rapide dans la barre
                          LikeButton(
                            isLiked: vm.isLiked,
                            onTap: () {
                              vm.toggleLike();
                              context
                                  .read<GlobalMangaFavoritesProvider>()
                                  .toggleFavorite(manga);
                            },
                            iconSize: 24,
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),

                      // --- EN-TÊTE STYLE "LIVRE" ---
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Couverture Physique (Ombre portée)
                              Hero(
                                tag: "manga_cover_${manga.id}",
                                child: Container(
                                  width: 120,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 15,
                                        offset: const Offset(5, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _buildCoverImage(BoxFit.cover),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Infos Droite
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),
                                    // Type (Manga / Novel)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        (mangaInfo.type ?? "Manga")
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Titre
                                    Text(
                                      mangaInfo.title,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Serif', // Touche "Livre"
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Score
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          mangaInfo.score != null
                                              ? mangaInfo.score!.toString()
                                              : "N/A",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          " / 10",
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.7,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // --- CORPS DE PAGE (FEUILLE BLANCHE) ---
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Animation Like Double Tap (Invisible sauf action)
                                Center(
                                  child: LikeAnimation(
                                    show: vm.showLikeAnimation,
                                    size: 80,
                                  ),
                                ),

                                // 1. Barre de Statut et Dates
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.withValues(alpha: 0.2),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Statut
                                      _buildStatusIndicator(mangaInfo.status),
                                      // Ligne verticale
                                      Container(
                                        height: 30,
                                        width: 1,
                                        color: Colors.grey.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                      // Dates
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Publication",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 10,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${_formatDate(mangaInfo.startDate)} - ${_formatDate(mangaInfo.endDate)}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // 2. Genres (Style étiquette)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: mangaInfo.genres
                                      .where((g) => g != Genres.None)
                                      .map(
                                        (g) => Chip(
                                          avatar: CircleAvatar(
                                            backgroundColor: Colors.black12,
                                            child: Text(
                                              g.name[0],
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          label: Text(g.toReadableString()),
                                          backgroundColor: Colors.transparent,
                                          shape: const StadiumBorder(
                                            side: BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          labelStyle: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),

                                const SizedBox(height: 24),
                                const Divider(),
                                const SizedBox(height: 16),

                                // 3. Synopsis (Titre Style Chapitre)
                                Text(
                                  "Résumé",
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Serif', // Rappel du livre
                                      ),
                                ),
                                const SizedBox(height: 12),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: vm.translatedSynopsis != "error"
                                      ? Text(
                                          vm.translatedSynopsis,
                                          textAlign: TextAlign
                                              .justify, // Texte justifié comme un livre
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                height:
                                                    1.8, // Interlignage large pour la lecture
                                                fontSize: 15,
                                                color: Colors.grey[800],
                                              ),
                                        )
                                      : const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 20,
                                          ),
                                          child: LinearProgressIndicator(),
                                        ),
                                ),
                                const SizedBox(height: 60),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildBlurBackground() {
    if (_mangaCover != null) {
      return Image(image: _mangaCover!.image, fit: BoxFit.cover);
    }
    return Container(color: Colors.grey[900]);
  }

  Widget _buildCoverImage(BoxFit fit) {
    if (_hasCoverError) {
      return Container(
        color: Colors.grey[800],
        child: const Icon(Icons.book, color: Colors.white24),
      );
    }
    if (_mangaCover != null) {
      return Image(image: _mangaCover!.image, fit: fit);
    }
    return Container(color: Colors.grey[800]);
  }

  Widget _buildStatusIndicator(MediaStatus status) {
    Color color = Colors.grey;
    String text = status.key;

    if (status == MediaStatus.publishing) {
      color = Colors.green;
      text = "En cours";
    } else if (status == MediaStatus.complete) {
      color = Colors.blueGrey;
      text = "Terminé";
    }

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
