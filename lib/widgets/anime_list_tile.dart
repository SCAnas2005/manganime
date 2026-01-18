import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';
import 'package:flutter_application_1/providers/anime_repository_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/widgets/like_widget/like_button.dart';

class AnimeListTile extends StatefulWidget {
  final Anime anime;
  final bool isLiked;
  final Function(Anime anime)? onTap;
  final Function(Anime anime)? onLikeToggle;

  const AnimeListTile({
    super.key,
    required this.anime,
    this.onTap,
    this.isLiked = false,
    this.onLikeToggle,
  });

  @override
  State<AnimeListTile> createState() => _AnimeListTileState();
}

class _AnimeListTileState extends State<AnimeListTile> {
  // Variable pour stocker l'image une fois chargée
  ImageProvider? _imageProvider;

  @override
  void initState() {
    super.initState();
    // On lance le chargement dès la création du widget
    _loadProvider();
  }

  // Ta fonction de chargement (adaptée pour le widget)
  Future<void> _loadProvider() async {
    try {
      final provider = await AnimeRepository(
        api: JikanService(),
      ).getAnimeImageProvider(widget.anime);

      if (mounted) {
        setState(() {
          _imageProvider = provider;
        });
      }
    } catch (e) {
      debugPrint("[AnimeListTile] _loadProvider() : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // --- GESTION DE L'IMAGE (LEADING) ---
      leading: SizedBox(
        width: 55,
        height: 80, // On fixe une hauteur pour éviter que ça bouge
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4), // Un petit arrondi propre
          child: _imageProvider != null
              ? Image(
                  image: _imageProvider!,
                  fit: BoxFit.cover,
                  // Gestion d'erreur visuelle si l'image casse
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.broken_image,
                      size: 20,
                      color: Colors.white54,
                    ),
                  ),
                )
              : Container(
                  // Placeholder pendant le chargement (fond gris)
                  color: Colors.grey[900],
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
        ),
      ),

      title: Text(
        widget.anime.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      subtitle: Text(
        "Score: ${widget.anime.score?.toStringAsFixed(1) ?? "?"} • ${widget.anime.status.key}",
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),

      // --- BOUTON LIKE ---
      trailing: widget.onLikeToggle != null
          ? LikeButton(
              isLiked: widget.isLiked, // Correction: utiliser widget.isLiked
              onTap: () => widget.onLikeToggle?.call(
                widget.anime,
              ), // Correction: encapsuler dans une fonction
            )
          : null,

      onTap: () => widget.onTap?.call(widget.anime),
    );
  }
}
