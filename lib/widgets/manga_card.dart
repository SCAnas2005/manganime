import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/like_storage.dart';
import 'package:flutter_application_1/widgets/like_widget/like_animation.dart';

/// Clipper personnalisé pour créer des coins légèrement irréguliers
class IrregularBorderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final random = math.Random(42); // Seed fixe pour cohérence
    
    // Coin supérieur gauche - légèrement irrégulier
    final topLeftVariation = random.nextDouble() * 3 - 1.5;
    path.moveTo(2 + topLeftVariation, 0);
    
    // Coin supérieur droit - légèrement irrégulier
    final topRightVariation = random.nextDouble() * 3 - 1.5;
    path.lineTo(size.width - 2 - topRightVariation, 0);
    
    // Coin inférieur droit - légèrement irrégulier
    final bottomRightVariation = random.nextDouble() * 3 - 1.5;
    path.lineTo(size.width, size.height - 2 - bottomRightVariation);
    
    // Coin inférieur gauche - légèrement irrégulier
    final bottomLeftVariation = random.nextDouble() * 3 - 1.5;
    path.lineTo(2 + bottomLeftVariation, size.height);
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
    path.lineTo(size.width - radius - tailWidth * 1.5, size.height - tailHeight);
    
    path.lineTo(radius, size.height - tailHeight);
    path.quadraticBezierTo(0, size.height - tailHeight, 0, size.height - radius - tailHeight);
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
class ScreentoneOverlay extends StatelessWidget {
  const ScreentoneOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ScreentonePainter(),
      child: Container(),
    );
  }
}

/// Painter pour dessiner la trame sur les bords
class ScreentonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    // Créer un gradient radial pour la trame (plus dense sur les bords)
    final gradient = RadialGradient(
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(0.15),
      ],
      stops: const [0.7, 1.0],
    );

    // Dessiner la trame sur les bords avec un motif de points
    final dotSize = 2.0;
    final spacing = 4.0;
    
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        // Calculer la distance au bord le plus proche
        final distToLeft = x;
        final distToRight = size.width - x;
        final distToTop = y;
        final distToBottom = size.height - y;
        final minDist = math.min(
          math.min(distToLeft, distToRight),
          math.min(distToTop, distToBottom),
        );
        
        // Dessiner uniquement près des bords (dans les 20 premiers pixels)
        if (minDist < 20) {
          final opacity = (1 - minDist / 20) * 0.15;
          canvas.drawCircle(
            Offset(x, y),
            dotSize,
            Paint()..color = Colors.black.withOpacity(opacity),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MangaCard extends StatefulWidget {
  final Manga manga;
  final Function(Manga manga)? onTap;

  const MangaCard({super.key, required this.manga, this.onTap});

  @override
  State<MangaCard> createState() => _MangaCardState();
}

class _MangaCardState extends State<MangaCard>
    with SingleTickerProviderStateMixin {
  bool showHeart = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 180), // Durée augmentée pour effet plus visible
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
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
    final genre = widget.manga.genre ?? 'Manga';

    return GestureDetector(
      onTap: () => widget.onTap?.call(widget.manga),
      onDoubleTap: () {
        _triggerLikeAnimation();
        LikeStorage.toggleMangaLike(widget.manga.id);
      },
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          // Calcul de l'angle de rotation pour l'effet flip page (augmenté pour effet plus marquant)
          final rotationAngle = (_flipAnimation.value - 0.5) * 0.25; // ~14° en radians (plus marquant)
          
          // Légère échelle pour renforcer l'effet de profondeur
          final scale = 1.0 + (_flipAnimation.value - 0.5).abs() * 0.03;
          
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002) // Perspective augmentée pour effet plus prononcé
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
                    color: Colors.black.withOpacity(0.3),
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
                      child: Image.network(
                        widget.manga.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(color: Colors.grey[800]);
                        },
                      ),
                    ),
                    
                    // Overlay de trame sur les bords
                    Positioned.fill(
                      child: ScreentoneOverlay(),
                    ),
                    
                    // Animation du cœur
                    if (showHeart)
                      Positioned.fill(
                        child: LikeAnimation(show: showHeart, size: 90),
                      ),
                    
                    // Badge de genre vertical (en haut à gauche)
                    if (widget.manga.genre != null)
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
                          quarterTurns: 1, // Rotation 90° pour texte vertical de haut en bas
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              widget.manga.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: 'serif', // Police serif pour effet imprimé
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
