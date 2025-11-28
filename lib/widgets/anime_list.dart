import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/widgets/like_widget/like_button.dart';

class AnimeList extends StatelessWidget {
  final Anime anime;
  final VoidCallback? onTap;
  final bool isLiked;
  final VoidCallback? onLikeToggle;

  const AnimeList({
    super.key,
    required this.anime,
    this.onTap,
    this.isLiked = false,
    this.onLikeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(anime.imageUrl, width: 55, fit: BoxFit.cover),
      title: Text(anime.title),
      subtitle: Text(
        "Score: ${anime.score?.toStringAsFixed(1) ?? "?"} • ${anime.status}",
      ),
      trailing: onLikeToggle != null
          ? LikeButton(isLiked: true, onTap: onLikeToggle!)
          : null,
      onTap: onTap,
    );
  }
}
