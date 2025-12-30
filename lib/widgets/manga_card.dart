import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/manga_repository_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/widgets/like_widget/like_animation.dart';

/// Clipper personnalisé pour créer des coins légèrement irréguliers
/// Les valeurs sont pré-calculées pour éviter de créer un Random à chaque rendu
class IrregularBorderClipper extends CustomClipper<Path> {
  // Valeurs pré-calculées (équivalent à Random(42).nextDouble() * 3 - 1.5 pour chaque coin)
  static const double _topLeftVariation = 0.58;
  static const double _topRightVariation = -0.23;
  static const double _bottomRightVariation = 1.12;
  static const double _bottomLeftVariation = -0.87;

  @override
  Path getClip(Size size) {
    final path = Path();

    // Coin supérieur gauche - légèrement irrégulier
    path.moveTo(2 + _topLeftVariation, 0);

    // Coin supérieur droit - légèrement irrégulier
    path.lineTo(size.width - 2 - _topRightVariation, 0);

    // Coin inférieur droit - légèrement irrégulier
    path.lineTo(size.width, size.height - 2 - _bottomRightVariation);

    // Coin inférieur gauche - légèrement irrégulier
    path.lineTo(2 + _bottomLeftVariation, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Widget pour la bulle de dialogue du score
class SpeechBubbleScore extends StatelessWidget {
  final String score;

  const SpeechBubbleScore({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SpeechBubblePainter(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.yellow, size: 14),
            const SizedBox(width: 4),
            Text(
              score,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter pour dessiner la bulle de dialogue
class SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final path = Path();
    final radius = 8.0;
    final tailWidth = 6.0;
    final tailHeight = 4.0;

    // Corps de la bulle (rectangle arrondi)
    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, size.height - radius - tailHeight);
    path.quadraticBezierTo(
      size.width,
      size.height - tailHeight,
      size.width - radius,
      size.height - tailHeight,
    );

    // Queue de la bulle (triangle pointant vers le bas)
    path.lineTo(size.width - radius - tailWidth, size.height - tailHeight);
    path.lineTo(size.width - radius - tailWidth / 2, size.height);
    path.lineTo(
      size.width - radius - tailWidth * 1.5,
      size.height - tailHeight,
    );

    path.lineTo(radius, size.height - tailHeight);
    path.quadraticBezierTo(
      0,
      size.height - tailHeight,
      0,
      size.height - radius - tailHeight,
    );
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget pour le badge de genre vertical
class VerticalGenreBadge extends StatelessWidget {
  final String genre;

  const VerticalGenreBadge({super.key, required this.genre});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: Center(
        child: RotatedBox(
          quarterTurns: 1, // Rotation 90° pour texte vertical
          child: Text(
            genre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

/// Widget pour l'overlay de trame (screentone) sur les bords
/// Optimisé pour les performances - utilise des gradients au lieu de dessiner des points individuels
class ScreentoneOverlay extends StatelessWidget {
  const ScreentoneOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // Utilise des gradients légers sur les bords pour un effet similaire
    // mais beaucoup plus performant que de dessiner des centaines de cercles
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.08),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.08),
            ],
            stops: const [0.0, 0.1, 0.9, 1.0],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black.withOpacity(0.08),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.08),
              ],
              stops: const [0.0, 0.1, 0.9, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

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

class _MangaCardState extends State<MangaCard>
    with SingleTickerProviderStateMixin {
  bool showHeart = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  late MangaRepository _repository;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(
        milliseconds: 180,
      ), // Durée augmentée pour effet plus visible
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _repository = MangaRepository(api: JikanService());
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _triggerLikeAnimation() {
    setState(() => showHeart = true);

    // Animation de flip page
    _flipController.forward().then((_) {
      _flipController.reverse();
    });

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
    final genre = widget.manga.genres.isNotEmpty
        ? widget.manga.genres.first.toReadableString()
        : 'Manga';

    return GestureDetector(
      onTap: () => widget.onTap?.call(widget.manga),
      onDoubleTap: () {
        _triggerLikeAnimation();
        widget.onLikeDoubleTap?.call(widget.manga);
      },
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          // Calcul de l'angle de rotation pour l'effet flip page (augmenté pour effet plus marquant)
          final rotationAngle =
              (_flipAnimation.value - 0.5) *
              0.25; // ~14° en radians (plus marquant)

          // Légère échelle pour renforcer l'effet de profondeur
          final scale = 1.0 + (_flipAnimation.value - 0.5).abs() * 0.03;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(
                3,
                2,
                0.002,
              ) // Perspective augmentée pour effet plus prononcé
              ..rotateY(rotationAngle)
              ..scale(scale),
            alignment: Alignment.center,
            child: Container(
              width: 130, // Plus étroit que anime (150)
              height: 200, // Plus haut que anime (format livre)
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.black,
                  width: 1.75, // Bordure noire fine (1.5-2px)
                ),
                boxShadow: [
                  // Ombre intérieure pour effet page imprimée
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: ClipPath(
                clipper: IrregularBorderClipper(),
                child: Stack(
                  children: [
                    // Image de fond
                    Positioned.fill(
                      child: FutureBuilder<Image>(
                        // 👇 C'est ici que tu appelles ta fonction
                        future: _repository.getMangaImage(widget.manga),

                        builder: (context, snapshot) {
                          // CAS 1 : Ta fonction a fini et renvoyé l'Image (Fichier ou Network)
                          if (snapshot.hasData) {
                            return snapshot.data!;
                          }

                          // CAS 2 : Erreur (Pas internet ET pas de fichier local)
                          if (snapshot.hasError) {
                            return Container(color: Colors.grey[800]);
                          }

                          // CAS 3 : En attente (la fonction cherche le fichier...)
                          return Container(color: Colors.grey[800]);
                        },
                      ),
                    ),

                    // Overlay de trame sur les bords
                    Positioned.fill(child: ScreentoneOverlay()),

                    // Animation du cœur
                    if (showHeart)
                      Positioned.fill(
                        child: LikeAnimation(show: showHeart, size: 90),
                      ),

                    // Badge de genre vertical (en haut à gauche)
                    if (widget.manga.genres.isNotEmpty)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: VerticalGenreBadge(genre: genre),
                      ),

                    // Badge de score en bulle de dialogue (en haut à droite)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: SpeechBubbleScore(score: scoreLabel),
                    ),

                    // Titre vertical sur le côté gauche
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: RotatedBox(
                          quarterTurns:
                              1, // Rotation 90° pour texte vertical de haut en bas
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              widget.manga.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily:
                                    'serif', // Police serif pour effet imprimé
                                shadows: [
                                  const Shadow(
                                    color: Colors.black,
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(0, 0),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
