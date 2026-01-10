import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/manga_repository_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/widgets/like_widget/like_button.dart';

class MangaListTile extends StatefulWidget {
  final Manga manga;
  final bool isLiked;
  final Function(Manga manga)? onTap;
  final Function(Manga manga)? onLikeToggle;

  const MangaListTile({
    super.key,
    required this.manga,
    this.onTap,
    this.isLiked = false,
    this.onLikeToggle,
  });

  @override
  State<MangaListTile> createState() => _MangaListTileState();
}

class _MangaListTileState extends State<MangaListTile> {
  // Variable pour stocker l'image une fois chargée
  ImageProvider? _imageProvider;

  @override
  void initState() {
    super.initState();
    // On lance le chargement dès la création du widget
    _loadProvider();
  }

  // Fonction de chargement adaptée pour le Manga
  Future<void> _loadProvider() async {
    try {
      final provider = await MangaRepository(
        api: JikanService(),
      ).getMangaImageProvider(widget.manga);

      if (mounted) {
        setState(() {
          _imageProvider = provider;
        });
      }
    } catch (e) {
      debugPrint("[MangaListTile] _loadProvider() : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // --- GESTION DE L'IMAGE (LEADING) ---
      leading: SizedBox(
        width: 55,
        height: 80, // Hauteur fixe pour éviter les sauts de layout
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4), // Petit arrondi esthétique
          child: _imageProvider != null
              ? Image(
                  image: _imageProvider!,
                  fit: BoxFit.cover,
                  // Gestion d'erreur visuelle
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
                  // Placeholder pendant le chargement
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
        widget.manga.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      subtitle: Text(
        "Score: ${widget.manga.score?.toStringAsFixed(1) ?? "?"} • ${widget.manga.status.key}",
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),

      // --- BOUTON LIKE ---
      trailing: widget.onLikeToggle != null
          ? LikeButton(
              isLiked: widget.isLiked,
              onTap: () => widget.onLikeToggle?.call(widget.manga),
            )
          : null,

      onTap: () => widget.onTap?.call(widget.manga),
    );
  }
}
