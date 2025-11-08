// lib/widgets/like_animation_widget.dart
import 'package:flutter/material.dart';

class LikeAnimationWidget extends StatefulWidget {
  final String imageUrl;
  final VoidCallback? onLiked;

  const LikeAnimationWidget({super.key, required this.imageUrl, this.onLiked});

  @override
  State<LikeAnimationWidget> createState() => LikeAnimationWidgetState();
}

class LikeAnimationWidgetState extends State<LikeAnimationWidget> {
  bool showHeart = false;

  void handleDoubleTap() {
    setState(() {
      showHeart = true;
    });

    widget.onLiked?.call();

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          showHeart = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: handleDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(widget.imageUrl),
          AnimatedOpacity(
            opacity: showHeart ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedScale(
              scale: showHeart ? 1.5 : 0.5,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              child: const Icon(Icons.favorite, color: Colors.red, size: 100),
            ),
          ),
        ],
      ),
    );
  }
}
