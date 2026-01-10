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

  late ScrollController _forYouController;

  @override
  void initState() {
    super.initState();

    _popularController = ScrollController();
    _airingController = ScrollController();
    _mostLikedController = ScrollController();
    _forYouController = ScrollController();

    // On attend que le BuildContext soit disponible
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<AnimeViewModel>();

      await vm.fetchForYou(context.read<GlobalAnimeFavoritesProvider>());

      _forYouController.addListener(() {
        if (_forYouController.position.pixels >=
            _forYouController.position.maxScrollExtent - 200) {
          vm.fetchForYou(context.read<GlobalAnimeFavoritesProvider>());
        }
      });

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
    _forYouController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnimeViewModel>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/icons/app_icon.png',
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ),

                  miniSearchBar(context),
                ],
              ),
            ),

            // FloatingActionButton(
            //   child: Icon(Icons.add),
            //   onPressed: () => {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (builder) => DebugPage()),
            //     ),
            //   },
            // ),
            TabSwitcher(
              tabs: ["Pour toi", "Tendances"],
              selectedIndex: selectedTab,
              onChanged: (index) {
                setState(() {
                  if (selectedTab != index) selectedTab = index;
                });
              },
              isEnabled: [true, true],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: selectedTab == 0
                  // L'onglet 0 scrolle tout seul (GridView)
                  ? _buildForYou(vm)
                  // L'onglet 1 a besoin d'être dans un SingleChildScrollView
                  : SingleChildScrollView(child: _buildTendences(vm)),
            ),
          ],
        ),
      ),
    );
  }

  // Onglet 1 : Pour toi (GridView qui scrolle)
  Widget _buildForYou(AnimeViewModel vm) {
    return GridView.builder(
      controller: _forYouController, // Ajout du controller
      // --- CHANGEMENT 3 : shrinkWrap et physics RETIRÉS ---
      // shrinkWrap: true, (retiré)
      // physics: const NeverScrollableScrollPhysics(), (retiré)
      padding: const EdgeInsets.only(
        top: 12,
        bottom: 16,
      ), // Petit padding utile
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

  // Onglet 2 : Tendances (Le contenu qui sera dans le SingleChildScrollView)
  Widget _buildTendences(AnimeViewModel vm) {
    // Pas de changement ici, cette colonne est maintenant dans un SingleChildScrollView dans le build principal.
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
}
