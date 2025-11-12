// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/models/anime.dart';
// import 'package:flutter_application_1/views/AnimeInfo.dart';

// class AnimeCard extends StatelessWidget {
//   final Anime anime;

//   const AnimeCard({super.key, required this.anime});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(16),
//       onTap: () {
//         // Navigue vers la page de détails
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => AnimeInfoView(anime)),
//         );
//       },
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         clipBehavior: Clip.hardEdge,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Expanded(
//               child: anime.imageUrl.isNotEmpty
//                   ? Image.network(anime.imageUrl, fit: BoxFit.cover)
//                   : Container(color: Colors.grey[300]),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 anime.title,
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';

class AnimeCard extends StatelessWidget {
  final Anime anime;
  final bool showEpisode;
  final Function(Anime anime)? onTap;

  const AnimeCard({
    super.key,
    required this.anime,
    this.showEpisode = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {onTap?.call(anime)},
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(anime.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 14),
                    Text(
                      anime.score.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            if (showEpisode)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC7F141),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "EP 12",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                anime.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
