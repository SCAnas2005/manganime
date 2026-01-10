import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/manga_repository_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/widgets/like_widget/like_animation.dart';

class MangaCard extends StatefulWidget {
  final Manga manga;
  final Function(Manga manga)? onTap;

  final Function(Manga manga)? onLikeDoubleTap;

  const MangaCard({
    super.key,
    required this.manga,
    this.onTap,
    this.onLikeDoubleTap,
  });

  @override
  State<MangaCard> createState() => _MangaCardState();
}

class _MangaCardState extends State<MangaCard> {
  bool showHeart = false;
  late MangaRepository _repository;

  void _triggerLikeAnimation() {
    setState(() => showHeart = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => showHeart = false);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _repository = MangaRepository(api: JikanService());
  }

  @override
  Widget build(BuildContext context) {
    final scoreLabel = widget.manga.score != null
        ? widget.manga.score!.toStringAsFixed(1)
        : '--';

    // Vérifie si le manga est "en publication"
    final isPublishing = widget.manga.status == MediaStatus.publishing;

    final firstGenre = widget.manga.genres.isNotEmpty
        ? widget.manga.genres.first.name
        : "None";

    return InkWell(
      onTap: () => widget.onTap?.call(widget.manga),
      onDoubleTap: () {
        _triggerLikeAnimation();
        widget.onLikeDoubleTap?.call(widget.manga);
      },
      child: Container(
        width: 130,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Stack(
          children: [
            FutureBuilder<Image>(
              future: _repository.getMangaImage(widget.manga),

              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!;
                }

                if (snapshot.hasError) {
                  return Container(color: Colors.grey[800]);
                }

                return Container(color: Colors.grey[800]);
              },
            ),
            // Gradient en bas pour améliorer la lisibilité du titre
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),

            // Animation du coeur
            if (showHeart)
              Center(child: LikeAnimation(show: showHeart, size: 90)),

            // Badge de genre (en haut à gauche)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  firstGenre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Indicateur "En publication" (point vert)
            if (isPublishing)
              Positioned(
                top: 8,
                left: firstGenre == "none" ? null : 8,
                right: firstGenre == "none" ? 40 : null,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),

            // Badge de score (en haut à droite)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      scoreLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Titre en bas (sur le gradient)
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
                  fontSize: 12,
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
