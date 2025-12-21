enum AnimeSections { popular, airing, mostLiked }

extension AnimeSectionExtension on AnimeSections {
  String get key => toString().split(".").last;
}
