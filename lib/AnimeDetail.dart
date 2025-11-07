class AnimeDetail {
  final int id;
  final String title;
  final String synopsis;
  final String imageUrl;
  final double score;
  final String type;
  final String status;
  final List<String> genres;

  AnimeDetail({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.imageUrl,
    required this.score,
    required this.type,
    required this.status,
    required this.genres,
  });
}
