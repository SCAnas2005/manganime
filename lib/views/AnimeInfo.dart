import 'package:flutter/material.dart';
import 'package:flutter_application_1/anime.dart';
import 'package:flutter_application_1/animeDetail.dart';
import 'package:flutter_application_1/services/JikanService.dart';
import 'package:flutter_application_1/services/translator.dart';

/// Écran affichant les informations détaillées d’un anime.
///
/// - Récupère les données via [JikanService].
/// - Traduit le synopsis en français via [Translator].
/// - Affiche le tout sous forme de `FutureBuilder` avec un `CircularProgressIndicator`
///   pendant le chargement.
class AnimeInfoView extends StatefulWidget {
  /// Anime de base sélectionné (avec titre, image, etc.)
  final Anime anime;

  const AnimeInfoView(this.anime, {super.key});

  @override
  State<AnimeInfoView> createState() => AnimeInfoViewState();
}

/// État associé à [AnimeInfoView].
///
/// Gère le chargement des détails de l’anime et leur traduction.
class AnimeInfoViewState extends State<AnimeInfoView> {
  /// Instance du service Jikan utilisée pour récupérer les données.
  final JikanService _service = JikanService();

  /// Future contenant les détails complets de l’anime.
  late Future<AnimeDetail> _animeDetailFuture;

  /// Future contenant la traduction française du synopsis.
  late Future<String> _translatedSynopsisFuture;

  /// État du bouton like
  bool isLiked = false;

  /// Initialisation du chargement des données et de la traduction.
  @override
  void initState() {
    super.initState();

    // Récupération des détails complets de l’anime sélectionné
    _animeDetailFuture = _service.getFullDetailAnime(widget.anime.id);

    // Une fois les détails obtenus, on traduit le synopsis
    _translatedSynopsisFuture = _animeDetailFuture.then((detail) {
      return Translator.translateToFrench(detail.synopsis);
    });
  }

  /// Construit l’interface affichant les détails de l’anime.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.anime.title)),

      // Utilisation d’un FutureBuilder pour afficher les infos quand elles sont prêtes
      body: FutureBuilder<AnimeDetail>(
        future: _animeDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // En cours de chargement
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Erreur de requête
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            // Pas de données reçues
            return const Center(child: Text("Aucune donnée"));
          }

          // Détails disponibles
          final detail = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Image.network(detail.imageUrl),
                const SizedBox(height: 16),

                // Titre
                Text(
                  detail.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),

                // Score
                Text("Score : ${detail.score}"),
                const SizedBox(height: 8),

                // Statut
                Text("Status : ${detail.status}"),
                const SizedBox(height: 8),
                // Bouton like
                Transform.translate(
                  offset: const Offset(0, -60),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: isLiked ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isLiked = !isLiked;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(isLiked ? "Vous avez aimé" : "Like"),
                    ],
                  ),
                ),

                // Synopsis traduit
                FutureBuilder<String>(
                  future: _translatedSynopsisFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return const Text("Erreur traduction");
                    }
                    return Text(snapshot.data ?? '');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
