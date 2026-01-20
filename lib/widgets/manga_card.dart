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
        ? widget.manga.score!.toStringAsFixed(1)
        : '--';

    // Vérifie si le manga est "en publication"
    final isPublishing = widget.manga.status?.toLowerCase() == 'publishing';

    return InkWell(
      onTap: () => widget.onTap?.call(widget.manga),
      onDoubleTap: () {
        _triggerLikeAnimation();
        LikeStorage.toggleMangaLike(widget.manga.id);
      },
      child: Container(
        width: 130,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 1.5),
          image: DecorationImage(
            image: NetworkImage(widget.manga.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
<<<<<<< Updated upstream
=======
            // IMAGE : Utilisation de Positioned.fill pour remplir tout l'espace
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6), // -2 pour la bordure
                child: FutureBuilder<Image>(
                  future: _repository.getMangaImage(widget.manga),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Image(
                        image: snapshot.data!.image,
                        fit: BoxFit.cover, // FORCE LE REMPLISSAGE
                      );
                    }
                    return Container(color: Colors.grey[800]);
                  },
                ),
              ),
            ),

>>>>>>> Stashed changes
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
              Center(
                child: LikeAnimation(show: showHeart, size: 90),
              ),

            // Badge de genre (en haut à gauche)
            if (widget.manga.genre != null)
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
                    widget.manga.genre!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

<<<<<<< Updated upstream
            // Indicateur "En publication" (point vert)
            if (isPublishing)
              Positioned(
                top: 8,
                left: widget.manga.genre != null ? null : 8,
                right: widget.manga.genre != null ? 40 : null,
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

=======
>>>>>>> Stashed changes
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

            // Titre avec indicateur de statut (en bas)
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'Roboto', // S'assurer de la police par défaut
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  children: [
                    TextSpan(text: "${widget.manga.title} "),
                    if (isPublishing)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          margin: const EdgeInsets.only(left: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
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
