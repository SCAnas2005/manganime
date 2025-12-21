// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

enum AnimeType { tv, movie, ova, special, ona, music, cm, pv, tv_special }

enum MangaType { manga, novel, lightnovel, oneshot, doujin, manhwa, manhua }

enum MediaStatus {
  airing, // anime
  publishing, // manga
  complete,
  upcoming,
  hiatus,
  discontinued,
}

extension MediaStatusX on MediaStatus {
  String get key => toString().split(".").last;
  static MediaStatus fromString(String raw) {
    return MediaStatus.values.firstWhere(
      (s) => s.name == raw,
      orElse: () => MediaStatus.complete,
    );
  }

  static MediaStatus fromJikan(String raw) {
    final value = raw.toLowerCase();
    debugPrint("from jikan value : $value");

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
