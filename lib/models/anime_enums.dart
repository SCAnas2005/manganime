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
