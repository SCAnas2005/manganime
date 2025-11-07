class Anime {
  final int id;
  final String title;
  final String imageUrl;
  final double? score;

  Anime({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.score,
  });
}
