import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/viewmodels/animeViewModel.dart';
import 'package:flutter_application_1/widgets/animeCard.dart';
import 'package:provider/provider.dart';

class AnimeView extends StatelessWidget {
  const AnimeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnimeViewModel(),
      child: Consumer<AnimeViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Onglets ou titre principal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Pour toi",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Tendances",
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // SECTION 1 : Les plus populaires
                    const Text(
                      "Les plus populaires de la semaine",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildHorizontalList(
                      vm.animes,
                      onTap: (anime) => {vm.openAnimePage(context, anime)},
                    ),

                    const SizedBox(height: 20),

                    // SECTION 2 : Les sorties
                    const Text(
                      "Les sorties de la semaine",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildHorizontalList(
                      vm.animes,
                      onTap: (anime) => {vm.openAnimePage(context, anime)},
                    ),

                    const SizedBox(height: 20),

                    // SECTION 3 : Les plus vues
                    const Text(
                      "Les plus vues",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildHorizontalList(
                      vm.animes,
                      onTap: (anime) => {vm.openAnimePage(context, anime)},
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalList(
    List<Anime> animes, {
    bool showEpisode = false,
    Function(Anime anime)? onTap,
  }) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: animes.length,
        itemBuilder: (context, index) {
          final anime = animes[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: AnimeCard(
              anime: anime,
              onTap: (anime) => {onTap?.call(anime)},
            ),
          );
        },
      ),
    );
  }
}
