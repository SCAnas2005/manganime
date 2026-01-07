enum AnimeSections { popular, airing, mostLiked }

enum MangaSections { popular, airing, mostLiked }

extension AnimeSectionExtension on AnimeSections {
  String get key => toString().split(".").last;
}

extension MangaSectionExtension on MangaSections {
  String get key => toString().split(".").last;
}
