import 'package:flutter/material.dart';

/// Widget qui affiche une animation de "like" (cœur)
class LikeAnimation extends StatelessWidget {
  final bool show;
  final double size;

  const LikeAnimation({super.key, required this.show, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: show ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Icon(Icons.favorite, color: Colors.red, size: size),
    );
  }
}
