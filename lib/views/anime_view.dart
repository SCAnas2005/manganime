import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/providers/global_anime_favorites_provider.dart';
import 'package:flutter_application_1/viewmodels/anime_view_model.dart';
import 'package:flutter_application_1/widgets/anime_card.dart';
import 'package:flutter_application_1/widgets/ui/tab_section.dart';
import 'package:flutter_application_1/widgets/ui/tab_switcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/widgets/search_widget/search_button.dart';

class AnimeView extends StatefulWidget {
  const AnimeView({super.key});

  @override
  State<AnimeView> createState() => _AnimeViewState();
}

class _AnimeViewState extends State<AnimeView> {
  int selectedTab = 1;

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

      vm.fetchForYou(context.read<GlobalAnimeFavoritesProvider>());

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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: miniSearchBar(context),
              ),

              TabSwitcher(
                tabs: ["Pour toi", "Tendances"],
                selectedIndex: selectedTab,
                onChanged: (index) {
                  setState(() {
                    if (selectedTab != index) selectedTab = index;
                  });
                },
                isEnabled: [
                  true,
                  true,
                ], // mettre [true,true] quand la page tendance sera faite
              ),
              const SizedBox(height: 20),
              selectedTab == 0 ? _buildForYou(vm) : _buildTendences(vm),
            ],
          ),
        ),
      ),
    );
  }

  // Onglet 1 : Pour toi
  Widget _buildTendences(AnimeViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabSection<Anime>(
          title: "Les plus populaires",
          items: vm.popular,
          controller: _popularController,
          onTap: (anime) => vm.openAnimePage(context, anime),
          itemBuilder: (anime) => AnimeCard(
            anime: anime,
            onTap: (a) => vm.openAnimePage(context, a),
            onLikeDoubleTap: (a) {
              context.read<GlobalAnimeFavoritesProvider>().toggleFavorite(
                anime,
              );
              setState(() {});
            },
            isLiked: context.watch<GlobalAnimeFavoritesProvider>().isAnimeLiked(
              anime.id,
            ),
          ),
        ),
        const SizedBox(height: 20),
        TabSection<Anime>(
          title: "En diffusion",
          items: vm.airing,
          controller: _airingController,
          onTap: (anime) => vm.openAnimePage(context, anime),
          itemBuilder: (anime) => AnimeCard(
            anime: anime,
            onTap: (a) => vm.openAnimePage(context, a),
            onLikeDoubleTap: (a) {
              context.read<GlobalAnimeFavoritesProvider>().toggleFavorite(
                anime,
              );
            },
            isLiked: context.watch<GlobalAnimeFavoritesProvider>().isAnimeLiked(
              anime.id,
            ),
          ),
        ),
        TabSection<Anime>(
          title: "Les plus aimés",
          items: vm.mostLiked,
          controller: _mostLikedController,
          onTap: (anime) => vm.openAnimePage(context, anime),
          itemBuilder: (anime) => AnimeCard(
            anime: anime,
            onTap: (a) => vm.openAnimePage(context, a),
            onLikeDoubleTap: (a) {
              context.read<GlobalAnimeFavoritesProvider>().toggleFavorite(
                anime,
              );
            },
            isLiked: context.watch<GlobalAnimeFavoritesProvider>().isAnimeLiked(
              anime.id,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForYou(AnimeViewModel vm) {
    return GridView.builder(
      shrinkWrap: true, // prend uniquement la hauteur nécessaire
      physics:
          const NeverScrollableScrollPhysics(), // désactive le scroll interne

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (context, index) {
        final anime = vm.forYou[index];
        return AnimeCard(
          anime: anime,
          onTap: (a) => vm.openAnimePage(context, a),
          onLikeDoubleTap: (a) {
            context.read<GlobalAnimeFavoritesProvider>().toggleFavorite(anime);
          },
          isLiked: context.watch<GlobalAnimeFavoritesProvider>().isAnimeLiked(
            anime.id,
          ),
        );
      },
      itemCount: vm.forYou.length,
    );
  }
}
