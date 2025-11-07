import 'package:flutter/material.dart';
import 'package:flutter_application_1/anime.dart';
import 'package:flutter_application_1/animeDetail.dart';
import 'package:flutter_application_1/services/JikanService.dart';
import 'package:flutter_application_1/services/translator.dart';

class AnimeInfoView extends StatefulWidget {
  final Anime anime;
  const AnimeInfoView(this.anime, {super.key});
  @override
  State<AnimeInfoView> createState() => AnimeInfoViewState();
}

class AnimeInfoViewState extends State<AnimeInfoView> {
  final JikanService _service = JikanService();

  late Future<AnimeDetail> _animeDetailFuture;
  late Future<String> _translatedSynopsisFuture;
  @override
  void initState() {
    super.initState();

    _animeDetailFuture = _service.getFullDetailAnime(widget.anime.id);
    _translatedSynopsisFuture = _animeDetailFuture.then((detail) {
      return Translator.translateToFrench(detail.synopsis);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.anime.title)),
      body: FutureBuilder<AnimeDetail>(
        future: _animeDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("Aucune donnée"));
          }

          final detail = snapshot.data!;

          // tu affiches les infos détaillées ici
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(detail.imageUrl),
                const SizedBox(height: 16),
                Text(
                  detail.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text("Score : ${detail.score}"),
                const SizedBox(height: 8),
                Text("Status : ${detail.status}"),
                const SizedBox(height: 8),
                FutureBuilder<String>(
                  future: _translatedSynopsisFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) return Text("Erreur traduction");
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
