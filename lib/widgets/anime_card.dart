import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
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
          image: DecorationImage(
            image: NetworkImage(widget.anime.imageUrl),
            fit: BoxFit.cover,
          ),
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
