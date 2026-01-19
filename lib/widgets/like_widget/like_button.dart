import 'package:flutter/material.dart';
/// Change de couleur selon qu'il est activé ou non et déclenche une action au clic
class LikeButton extends StatelessWidget {
  final bool isLiked;
  final VoidCallback onTap;
  final double iconSize;

  const LikeButton({
    super.key,
    required this.isLiked,
    required this.onTap,
    this.iconSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: iconSize,
      icon: Icon(Icons.favorite, color: isLiked ? Colors.red : Colors.grey),
      onPressed: onTap,
    );
  }
}
