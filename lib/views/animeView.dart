import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/viewmodels/animeViewModel.dart';
import 'package:flutter_application_1/widgets/animeCard.dart';
import 'package:provider/provider.dart';

class AnimeView extends StatefulWidget {
  const AnimeView({super.key});

  @override
  State<AnimeView> createState() => _AnimeViewState();
}

class _AnimeViewState extends State<AnimeView> {
  late ScrollController _popularController;
  late ScrollController _airingController;
  late ScrollController _mostLikedController;

  @override
  void initState() {
    super.initState();

    _popularController = ScrollController();
    _airingController = ScrollController();
    _mostLikedController = ScrollController();

    // On attend que le BuildContext soit disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<AnimeViewModel>();

      _popularController.addListener(() {
        if (_popularController.position.pixels >=
            _popularController.position.maxScrollExtent - 200) {
          vm.fetchPopular();
        }
      });

      _airingController.addListener(() {
        if (_airingController.position.pixels >=
            _airingController.position.maxScrollExtent - 200) {
          vm.fetchAiring();
        }
      });

      _mostLikedController.addListener(() {
        if (_mostLikedController.position.pixels >=
            _mostLikedController.position.maxScrollExtent - 200) {
          vm.fetchMostLiked();
        }
      });
    });
  }

  @override
  void dispose() {
    _popularController.dispose();
    _airingController.dispose();
    _mostLikedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnimeViewModel>();

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                "Les plus populaires",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              _buildHorizontalList(
                vm.popular,
                controller: _popularController,
                onTap: (anime) => vm.openAnimePage(context, anime),
              ),

              const SizedBox(height: 20),

              // SECTION 2 : Les sorties
              const Text(
                "En diffusion",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              _buildHorizontalList(
                vm.airing,
                controller: _airingController,
                onTap: (anime) => vm.openAnimePage(context, anime),
              ),

              const SizedBox(height: 20),

              // SECTION 3 : Les plus vues
              const Text(
                "Les plus aimés",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              _buildHorizontalList(
                vm.mostLiked,
                controller: _mostLikedController,
                onTap: (anime) => vm.openAnimePage(context, anime),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalList(
    List<Anime> animes, {
    bool showEpisode = false,
    Function(Anime anime)? onTap,
    ScrollController? controller,
  }) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        itemCount: animes.length,
        itemBuilder: (context, index) {
          final anime = animes[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: AnimeCard(
              anime: anime,
              onTap: (anime) => onTap?.call(anime),
            ),
          );
        },
      ),
    );
  }
}
