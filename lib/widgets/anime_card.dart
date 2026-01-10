import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/providers/anime_repository_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/widgets/like_widget/like_animation.dart';

class AnimeCard extends StatefulWidget {
  final Anime anime;
  final bool showEpisode;
  final bool isLiked;
  // Fonction appelée quand on appuie sur l'anime
  final Function(Anime anime)? onTap;
  // Fonction appelé quand on double appuie sur l'anime
  final Function(Anime anime)? onLikeDoubleTap;

  const AnimeCard({
    super.key,
    required this.anime,
    this.showEpisode = false,
    this.isLiked = false,
    this.onTap,
    this.onLikeDoubleTap,
  });

  @override
  State<AnimeCard> createState() => _AnimeCardState();
}

class _AnimeCardState extends State<AnimeCard> {
  bool showHeart = false;

  ImageProvider<Object>? _imageProvider;

  @override
  void initState() {
    super.initState();
    _loadProvider();
  }

  @override
  void didUpdateWidget(covariant AnimeCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si l'anime a changé (l'ID est différent)
    if (oldWidget.anime.id != widget.anime.id) {
      // 1. On remet l'image à zéro (pour afficher le loader ou l'ancienne)
      setState(() {
        _imageProvider = null;
      });

      // 2. On relance le chargement pour le nouvel anime
      _loadProvider();
    }
  }

  Future<void> _loadProvider() async {
    try {
      final provider = await AnimeRepository(
        api: JikanService(),
      ).getAnimeImageProvider(widget.anime);
      if (mounted) {
        setState(() {
          _imageProvider = provider;
        });
      }
    } catch (e) {
      debugPrint("[AnimeCard] _loadProvider() : $e");
    }
  }

  void triggerLikeAnimation() {
    setState(() => showHeart = true);

    // Après 600ms, on cache l'animation
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => showHeart = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onTap?.call(widget.anime),
      onDoubleTap: () {
        triggerLikeAnimation();
        widget.onLikeDoubleTap?.call(widget.anime);
        setState(() {});
      },
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          image: _imageProvider != null
              ? DecorationImage(
                  image: _imageProvider!,
                  fit: BoxFit.cover, // Gère le redimensionnement proprement
                )
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animation du coeur
            LikeAnimation(show: showHeart, size: 90),

            // La note
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 14),
                    Text(
                      widget.anime.score.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            widget.isLiked
                ? Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.favorite, color: Colors.red, size: 20),
                    ),
                  )
                : SizedBox(),

            if (widget.showEpisode)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC7F141),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "EP 12",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                widget.anime.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
