// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

enum AnimeType { tv, movie, ova, special, ona, music, cm, pv, tv_special, none }

enum MangaType {
  manga,
  novel,
  lightnovel,
  oneshot,
  doujin,
  manhwa,
  manhua,
  oel,
}

enum MediaStatus {
  airing, // anime
  publishing, // manga
  complete,
  upcoming,
  hiatus,
  discontinued,
}

extension MangaTypeX on MangaType {
  String get key => name;

  static MangaType fromString(String? type) {
    if (type == null) return MangaType.manga;

    try {
      return MangaType.values.firstWhere((e) => e.name == type);
    } catch (e) {
      debugPrint("EXT [MangaTypeX] fromString($type) : $e");
      return MangaType.manga;
    }
  }

  static MangaType fromJikan(String? type) {
    if (type == null) return MangaType.manga; // Valeur par défaut
    final normalized = type
        .toLowerCase()
        .replaceAll("-", "")
        .replaceAll(" ", "");

    switch (normalized) {
      case "manga":
        return MangaType.manga;
      case "novel":
        return MangaType.novel;
      case "lightnovel":
        return MangaType.lightnovel;
      case "oneshot":
        return MangaType.oneshot;
      case "doujinshi":
        return MangaType.doujin;
      case "manhwa":
        return MangaType.manhwa;
      case "manhua":
        return MangaType.manhua;
      case "oel":
        return MangaType.oel;
      default:
        return MangaType.manga;
    }
  }

  String get label {
    switch (this) {
      case MangaType.manga:
        return "Manga";
      case MangaType.novel:
        return "Roman";
      case MangaType.lightnovel:
        return "Light Novel";
      case MangaType.oneshot:
        return "One-shot";
      case MangaType.doujin:
        return "Doujin";
      case MangaType.manhwa:
        return "Manhwa";
      case MangaType.manhua:
        return "Manhua";
      case MangaType.oel:
        return "OEL";
    }
  }
}

extension AnimeTypeX on AnimeType {
  String get key => name;

  static AnimeType fromString(String? type) {
    if (type == null || type.isEmpty) AnimeType.none;
    try {
      return AnimeType.values.firstWhere((e) => e.name == type);
    } catch (e) {
      debugPrint("EXT [AnimeTypeX] fromString($type) : $e");
      return AnimeType.none;
    }
  }

  static AnimeType fromJikan(String? type) {
    if (type == null || type.isEmpty) return AnimeType.none;

    final normalized = type
        .toLowerCase()
        .replaceAll(" ", "_")
        .replaceAll("-", "_");

    try {
      return AnimeType.values.firstWhere((e) => e.name == normalized);
    } catch (e) {
      debugPrint("EXT [AnimeTypeX] fromJikan($type) : $e");
      return AnimeType.none;
    }
  }

  String get label {
    switch (this) {
      case AnimeType.tv:
        return "Série TV";
      case AnimeType.movie:
        return "Film";
      case AnimeType.ova:
        return "OVA";
      case AnimeType.ona:
        return "ONA (Web)";
      case AnimeType.special:
        return "Spécial";
      case AnimeType.tv_special:
        return "TV Spécial";
      case AnimeType.music:
        return "Musique";
      case AnimeType.cm:
        return "Pub (CM)";
      case AnimeType.pv:
        return "Promo (PV)";
      case AnimeType.none:
        return "None";
    }
  }
}

extension MediaStatusX on MediaStatus {
  String get key => name;
  static MediaStatus fromString(String raw) {
    return MediaStatus.values.firstWhere(
      (s) => s.name == raw,
      orElse: () => MediaStatus.complete,
    );
  }

  static MediaStatus fromJikan(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('finished') || value.contains('complete')) {
      return MediaStatus.complete;
    }

    if (value.contains('not yet')) {
      return MediaStatus.upcoming;
    }

    if (value.contains('publishing')) {
      return MediaStatus.publishing;
    }

    if (value.contains('hiatus')) {
      return MediaStatus.hiatus;
    }

    if (value.contains('discontinued')) {
      return MediaStatus.discontinued;
    }

    if (value.contains('airing')) {
      return MediaStatus.airing;
    }

    return MediaStatus.complete;
  }
}

enum AnimeRating {
  g, // Tout les ages
  pg, // Pour les enfants
  pg13, // Ado de 13ans ou plus
  r17, // 17+ (violance)
  r, // R+ Nudité
  rx, // Hentai
  none,
}

extension AnimeRatingX on AnimeRating {
  String get key => name;

  static AnimeRating fromString(String? rating) {
    if (rating == null || rating.isEmpty) return AnimeRating.none;

    try {
      return AnimeRating.values.firstWhere((e) => e.name == rating);
    } catch (e) {
      debugPrint("EXT [AnimeRatingX] fromString($rating) : $e");
      return AnimeRating.none;
    }
  }

  static AnimeRating fromJikan(String? rating) {
    if (rating == null || rating.isEmpty) return AnimeRating.none;

    final code = rating.split(" - ").first.trim().toUpperCase();

    switch (code) {
      case "G":
        return AnimeRating.g;
      case "PG":
        return AnimeRating.pg;
      case "PG-13":
        return AnimeRating.pg13;
      case "R":
        return AnimeRating.r17;
      case "R+":
        return AnimeRating.r;
      case "RX":
        return AnimeRating.rx;
    }
    return AnimeRating.none;
  }

  String get label {
    switch (this) {
      case AnimeRating.g:
        return "Tout public";
      case AnimeRating.pg:
        return "Enfants";
      case AnimeRating.pg13:
        return "Ados (13+)";
      case AnimeRating.r17:
        return "Violence (17+)";
      case AnimeRating.r:
        return "Nudité (R+)";
      case AnimeRating.rx:
        return "Hentai (Rx)";
      case AnimeRating.none:
        return "None";
    }
  }

  Color get color {
    switch (this) {
      case AnimeRating.g:
        return Colors.green;
      case AnimeRating.pg:
        return Colors.lightGreen;
      case AnimeRating.pg13:
        return Colors.orange;
      case AnimeRating.r17:
        return Colors.redAccent;
      case AnimeRating.r:
        return Colors.pinkAccent;
      case AnimeRating.rx:
        return Colors.black;
      case AnimeRating.none:
        return Colors.black;
    }
  }
}

enum MediaOrderBy {
  mal_id,
  title,
  start_date,
  end_date,
  score,
  scored_by,
  rank,
  popularity,
  members,
}

enum SortOrder { desc, asc }

enum Genres {
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

extension GenreX on Genres {
  /// Convertit un String en AnimeGenre
  static Genres? fromString(String value) {
    return Genres.values.firstWhere(
      (g) => g.toReadableString().toLowerCase() == value.toLowerCase(),
      orElse: () => Genres.None,
    );
  }

  /// Retourne un String lisible
  String toReadableString() {
    switch (this) {
      case Genres.Action:
        return "Action";
      case Genres.Adventure:
        return "Adventure";
      case Genres.AvantGarde:
        return "Avant Garde";
      case Genres.AwardWinning:
        return "Award Winning";
      case Genres.BoysLove:
        return "Boys Love";
      case Genres.Comedy:
        return "Comedy";
      case Genres.Drama:
        return "Drama";
      case Genres.Ecchi:
        return "Ecchi";
      case Genres.Fantasy:
        return "Fantasy";
      case Genres.GirlsLove:
        return "Girls Love";
      case Genres.Gourmet:
        return "Gourmet";
      case Genres.Horror:
        return "Horror";
      case Genres.MartialArts:
        return "Martial Arts";
      case Genres.Mecha:
        return "Mecha";
      case Genres.Music:
        return "Music";
      case Genres.Parody:
        return "Parody";
      case Genres.Samurai:
        return "Samurai";
      case Genres.Romance:
        return "Romance";
      case Genres.School:
        return "School";
      case Genres.SciFi:
        return "Sci-Fi";
      case Genres.Shoujo:
        return "Shoujo";
      case Genres.Shounen:
        return "Shounen";
      case Genres.SliceOfLife:
        return "Slice of Life";
      case Genres.Sports:
        return "Sports";
      case Genres.Supernatural:
        return "Supernatural";
      case Genres.SuperPower:
        return "Super Power";
      case Genres.Vampire:
        return "Vampire";
      case Genres.Harem:
        return "Harem";
      case Genres.Psychological:
        return "Psychological";
      case Genres.Seinen:
        return "Seinen";
      case Genres.Josei:
        return "Josei";
      case Genres.Kids:
        return "Kids";
      case Genres.None:
        return "";
    }
  }

  /// Retourne le mal_id officiel pour l'API Jikan
  int get id {
    switch (this) {
      case Genres.Action:
        return 1;
      case Genres.Adventure:
        return 2;
      case Genres.AvantGarde:
        return 5;
      case Genres.AwardWinning:
        return 46;
      case Genres.BoysLove:
        return 28;
      case Genres.Comedy:
        return 4;
      case Genres.Drama:
        return 8;
      case Genres.Ecchi:
        return 9;
      case Genres.Fantasy:
        return 10;
      case Genres.GirlsLove:
        return 26;
      case Genres.Gourmet:
        return 47;
      case Genres.Horror:
        return 14;
      case Genres.MartialArts:
        return 17;
      case Genres.Mecha:
        return 18;
      case Genres.Music:
        return 19;
      case Genres.Parody:
        return 20;
      case Genres.Samurai:
        return 21;
      case Genres.Romance:
        return 22;
      case Genres.School:
        return 23;
      case Genres.SciFi:
        return 24;
      case Genres.Shoujo:
        return 25;
      case Genres.Shounen:
        return 27;
      case Genres.SliceOfLife:
        return 36;
      case Genres.Sports:
        return 30;
      case Genres.Supernatural:
        return 37;
      case Genres.SuperPower:
        return 31;
      case Genres.Vampire:
        return 32;
      case Genres.Harem:
        return 35;
      case Genres.Psychological:
        return 40;
      case Genres.Seinen:
        return 42;
      case Genres.Josei:
        return 43;
      case Genres.Kids:
        return 15;
      case Genres.None:
        return -1;
    }
  }
}
