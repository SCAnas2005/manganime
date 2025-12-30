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
  rating,
}

enum AnimeSortBy { desc, asc }

enum AnimeGenre {
  Action,
  Adventure,
  AvantGarde,
  AwardWinning,
  BoysLove,
  Comedy,
  Drama,
  Ecchi,
  Fantasy,
  GirlsLove,
  Gourmet,
  Horror,
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
  SliceOfLife,
  Sports,
  Supernatural,
  SuperPower,
  Vampire,
  Harem,
  Psychological,
  Seinen,
  Josei,
  Kids,
  None,
}

extension AnimeGenreX on AnimeGenre {
  /// Convertit un String en AnimeGenre
  static AnimeGenre? fromString(String value) {
    return AnimeGenre.values.firstWhere(
      (g) => g.toReadableString().toLowerCase() == value.toLowerCase(),
      orElse: () => AnimeGenre.None,
    );
  }

  /// Retourne un String lisible
  String toReadableString() {
    switch (this) {
      case AnimeGenre.Action:
        return "Action";
      case AnimeGenre.Adventure:
        return "Adventure";
      case AnimeGenre.AvantGarde:
        return "Avant Garde";
      case AnimeGenre.AwardWinning:
        return "Award Winning";
      case AnimeGenre.BoysLove:
        return "Boys Love";
      case AnimeGenre.Comedy:
        return "Comedy";
      case AnimeGenre.Drama:
        return "Drama";
      case AnimeGenre.Ecchi:
        return "Ecchi";
      case AnimeGenre.Fantasy:
        return "Fantasy";
      case AnimeGenre.GirlsLove:
        return "Girls Love";
      case AnimeGenre.Gourmet:
        return "Gourmet";
      case AnimeGenre.Horror:
        return "Horror";
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
      case AnimeGenre.SliceOfLife:
        return "Slice of Life";
      case AnimeGenre.Sports:
        return "Sports";
      case AnimeGenre.Supernatural:
        return "Supernatural";
      case AnimeGenre.SuperPower:
        return "Super Power";
      case AnimeGenre.Vampire:
        return "Vampire";
      case AnimeGenre.Harem:
        return "Harem";
      case AnimeGenre.Psychological:
        return "Psychological";
      case AnimeGenre.Seinen:
        return "Seinen";
      case AnimeGenre.Josei:
        return "Josei";
      case AnimeGenre.Kids:
        return "Kids";
      case AnimeGenre.None:
        return "";
    }
  }

  /// Retourne le mal_id officiel pour l'API Jikan
  int get id {
    switch (this) {
      case AnimeGenre.Action:
        return 1;
      case AnimeGenre.Adventure:
        return 2;
      case AnimeGenre.AvantGarde:
        return 5;
      case AnimeGenre.AwardWinning:
        return 46;
      case AnimeGenre.BoysLove:
        return 28;
      case AnimeGenre.Comedy:
        return 4;
      case AnimeGenre.Drama:
        return 8;
      case AnimeGenre.Ecchi:
        return 9;
      case AnimeGenre.Fantasy:
        return 10;
      case AnimeGenre.GirlsLove:
        return 26;
      case AnimeGenre.Gourmet:
        return 47;
      case AnimeGenre.Horror:
        return 14;
      case AnimeGenre.MartialArts:
        return 17;
      case AnimeGenre.Mecha:
        return 18;
      case AnimeGenre.Music:
        return 19;
      case AnimeGenre.Parody:
        return 20;
      case AnimeGenre.Samurai:
        return 21;
      case AnimeGenre.Romance:
        return 22;
      case AnimeGenre.School:
        return 23;
      case AnimeGenre.SciFi:
        return 24;
      case AnimeGenre.Shoujo:
        return 25;
      case AnimeGenre.Shounen:
        return 27;
      case AnimeGenre.SliceOfLife:
        return 36;
      case AnimeGenre.Sports:
        return 30;
      case AnimeGenre.Supernatural:
        return 37;
      case AnimeGenre.SuperPower:
        return 31;
      case AnimeGenre.Vampire:
        return 32;
      case AnimeGenre.Harem:
        return 35;
      case AnimeGenre.Psychological:
        return 40;
      case AnimeGenre.Seinen:
        return 42;
      case AnimeGenre.Josei:
        return 43;
      case AnimeGenre.Kids:
        return 15;
      case AnimeGenre.None:
        return -1;
    }
  }
}
