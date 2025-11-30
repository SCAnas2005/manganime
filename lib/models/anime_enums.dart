// ignore_for_file: constant_identifier_names

enum AnimeType { tv, movie, ova, special, ona, music, cm, pv, tv_special }

enum AnimeStatus { airing, complete, upcoming }

enum AnimeRating {
  g, // Tout les ages
  pg, // Pour les enfants
  pg13, // Ado de 13ans ou plus
  r17, // 17+ (violance)
  r, // R+ Nudité
  rx, // Hentai
}

enum AnimeOrderBy {
  mal_id,
  title,
  start_date,
  end_date,
  episodes,
  score,
  scored_by,
  rank,
  popularity,
  members,
}

enum AnimeSortBy { desc, asc }

enum AnimeGenre {
  Action,
  Adventure,
  Drama,
  Ecchi,
  Fantasy,
  Game,
  Historical,
  Horror,
  Kids,
  MartialArts,
  Mecha,
  Music,
  Parody,
  Samurai,
  Romance,
  School,
  SciFi,
  Shoujo,
  Shounen,
  GirlsLove,
  BoysLove,
  Space,
  Sports,
  SuperPower,
  Vampire,
  Harem,
  SliceOfLife,
  Supernatural,
  Military,
  Police,
  Psychological,
  Suspense,
  Seinen,
  Josei,
  AwardWinning,
  Gourmet,
  WorkLife,
  Erotica,
  None,
}

extension AnimeGenreX on AnimeGenre {
  // Convertit un String en AnimeGenre
  static AnimeGenre? fromString(String value) {
    return AnimeGenre.values.firstWhere(
      (g) => g.name.toLowerCase() == value.toLowerCase().replaceAll(' ', ''),
      orElse: () => AnimeGenre.None,
    );
  }

  /// Convert enum -> String lisible
  String toReadableString() {
    switch (this) {
      case AnimeGenre.Action:
        return "Action";
      case AnimeGenre.Adventure:
        return "Adventure";
      case AnimeGenre.Drama:
        return "Drama";
      case AnimeGenre.Ecchi:
        return "Ecchi";
      case AnimeGenre.Fantasy:
        return "Fantasy";
      case AnimeGenre.Game:
        return "Game";
      case AnimeGenre.Historical:
        return "Historical";
      case AnimeGenre.Horror:
        return "Horror";
      case AnimeGenre.Kids:
        return "Kids";
      case AnimeGenre.MartialArts:
        return "Martial Arts";
      case AnimeGenre.Mecha:
        return "Mecha";
      case AnimeGenre.Music:
        return "Music";
      case AnimeGenre.Parody:
        return "Parody";
      case AnimeGenre.Samurai:
        return "Samurai";
      case AnimeGenre.Romance:
        return "Romance";
      case AnimeGenre.School:
        return "School";
      case AnimeGenre.SciFi:
        return "Sci-Fi";
      case AnimeGenre.Shoujo:
        return "Shoujo";
      case AnimeGenre.Shounen:
        return "Shounen";
      case AnimeGenre.GirlsLove:
        return "Girls Love";
      case AnimeGenre.BoysLove:
        return "Boys Love";
      case AnimeGenre.Space:
        return "Space";
      case AnimeGenre.Sports:
        return "Sports";
      case AnimeGenre.SuperPower:
        return "Super Power";
      case AnimeGenre.Vampire:
        return "Vampire";
      case AnimeGenre.Harem:
        return "Harem";
      case AnimeGenre.SliceOfLife:
        return "Slice of Life";
      case AnimeGenre.Supernatural:
        return "Supernatural";
      case AnimeGenre.Military:
        return "Military";
      case AnimeGenre.Police:
        return "Police";
      case AnimeGenre.Psychological:
        return "Psychological";
      case AnimeGenre.Suspense:
        return "Suspense";
      case AnimeGenre.Seinen:
        return "Seinen";
      case AnimeGenre.Josei:
        return "Josei";
      case AnimeGenre.AwardWinning:
        return "Award Winning";
      case AnimeGenre.Gourmet:
        return "Gourmet";
      case AnimeGenre.WorkLife:
        return "Work Life";
      case AnimeGenre.Erotica:
        return "Erotica";
      case AnimeGenre.None:
        return "";
    }
  }
}
