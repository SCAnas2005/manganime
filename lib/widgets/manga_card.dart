import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/like_storage.dart';
import 'package:flutter_application_1/widgets/like_widget/like_animation.dart';

class MangaCard extends StatefulWidget {
  final Manga manga;
  final Function(Manga manga)? onTap;

  const MangaCard({super.key, required this.manga, this.onTap});

  @override
  State<MangaCard> createState() => _MangaCardState();
}

class _MangaCardState extends State<MangaCard> {
  bool showHeart = false;

  void _triggerLikeAnimation() {
    setState(() => showHeart = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => showHeart = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scoreLabel = widget.manga.score != null
        ? widget.manga.score.toString()
        : '--';

    return InkWell(
      onTap: () => widget.onTap?.call(widget.manga),
      onDoubleTap: () {
        _triggerLikeAnimation();
        LikeStorage.toggleMangaLike(widget.manga.id);
      },
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(widget.manga.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            LikeAnimation(show: showHeart, size: 90),
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
                      scoreLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                widget.manga.title,
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
