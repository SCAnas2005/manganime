import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/global_manga_favorites_provider.dart';
import 'package:flutter_application_1/providers/manga_repository_provider.dart';
import 'package:flutter_application_1/providers/user_stats_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/viewmodels/manga_info_view_model.dart';
import 'package:flutter_application_1/widgets/like_widget/like_animation.dart';
import 'package:flutter_application_1/widgets/like_widget/like_button.dart';
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

  // Helper pour afficher les auteurs joliment
  String _getFormattedAuthors(List<dynamic> authors) {
    if (authors.isEmpty) return "Auteur inconnu";
    // On prend les 2 premiers max pour pas surcharger
    return authors.take(2).map((a) => a.name).join(", ");
  }

  @override
  Widget build(BuildContext context) {
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
          final mangaInfo = vm.manga;

          return Scaffold(
            body: Stack(
              children: [
                // --- 1. ARRIÈRE-PLAN FLOUTÉ ---
                Positioned.fill(
                  bottom: MediaQuery.of(context).size.height * 0.55,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildBlurBackground(),
                      Container(color: Colors.black.withValues(alpha: 0.4)),
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
                      // Navbar
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        leading: const BackButton(color: Colors.white),
                        actions: [
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
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Couverture
                              Hero(
                                tag: "manga_cover_${manga.id}",
                                child: Container(
                                  width: 110, // Légèrement réduit
                                  height: 165,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
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
                                    borderRadius: BorderRadius.circular(6),
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
                                    // Type & Démographie (Ligne 1)
                                    Row(
                                      children: [
                                        _buildTag(mangaInfo.type.label),
                                        if (mangaInfo.demographic != null) ...[
                                          const SizedBox(width: 8),
                                          _buildTag(
                                            mangaInfo.demographic!,
                                            color: Colors.orangeAccent,
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Titre (Ligne 2)
                                    Text(
                                      mangaInfo.title,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Serif',
                                        height: 1.2,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    // Auteurs (Ligne 3) - NOUVEAU
                                    Text(
                                      _getFormattedAuthors(mangaInfo.authors),
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 10),

                                    // Score (Ligne 4)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          mangaInfo.score != null
                                              ? mangaInfo.score!.toString()
                                              : "N/A",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
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
                          // On colle la feuille au header (pas de margin top)
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
                                Center(
                                  child: LikeAnimation(
                                    show: vm.showLikeAnimation,
                                    size: 80,
                                  ),
                                ),

                                // 1. Barre d'Infos Complète (Statut | Vols | Chaps | Dates)
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
                                      // GAUCHE : Statut + Indicateur
                                      _buildStatusIndicator(mangaInfo.status),

                                      // DROITE : Infos Techniques (Vols / Chaps)
                                      Row(
                                        children: [
                                          if (mangaInfo.volumes != null)
                                            _buildTechInfo(
                                              "${mangaInfo.volumes}",
                                              "VOLS",
                                            ),
                                          if (mangaInfo.chapters != null) ...[
                                            const SizedBox(width: 12),
                                            _buildTechInfo(
                                              "${mangaInfo.chapters}",
                                              "CHAPS",
                                            ),
                                          ],

                                          const SizedBox(width: 12),
                                          // Ligne verticale de séparation
                                          Container(
                                            height: 24,
                                            width: 1,
                                            color: Colors.grey.withValues(
                                              alpha: 0.3,
                                            ),
                                          ),
                                          const SizedBox(width: 12),

                                          // Année de début
                                          _buildTechInfo(
                                            mangaInfo.startDate?.year
                                                    .toString() ??
                                                "?",
                                            "ANNÉE",
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Affichage du Magazine (Serialization)
                                if (mangaInfo.serialization != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8.0,
                                      right: 4.0,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "Publié dans : ${mangaInfo.serialization}",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 20),

                                // 2. Genres (Compacts et fins)
                                Wrap(
                                  spacing: 6, // Espace horizontal réduit
                                  runSpacing: 6, // Espace vertical réduit
                                  children: mangaInfo.genres
                                      .where((g) => g != Genres.None)
                                      .map(
                                        (g) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            // Fond léger au lieu de transparent pour mieux définir
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.5),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.withValues(
                                                alpha: 0.3,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            g.toReadableString(),
                                            style: TextStyle(
                                              fontSize:
                                                  11, // Police plus petite
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.color,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),

                                const SizedBox(height: 24),
                                const Divider(),
                                const SizedBox(height: 16),

                                // 3. Synopsis
                                Text(
                                  "Résumé",
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Serif',
                                      ),
                                ),
                                const SizedBox(height: 12),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: vm.translatedSynopsis != "error"
                                      ? Text(
                                          vm.translatedSynopsis,
                                          textAlign: TextAlign.justify,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                height: 1.8,
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

  // Petit tag pour Type et Démographie
  Widget _buildTag(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: (color ?? Colors.white).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color ?? Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Indicateur de statut (rond coloré + texte)
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

  // Widget pour "12 VOLS", "102 CHAPS"
  Widget _buildTechInfo(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(label, style: TextStyle(fontSize: 9, color: Colors.grey[600])),
      ],
    );
  }
}
