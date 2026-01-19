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
  Anime? animeToOpen;
  AnimeView({this.animeToOpen, super.key});

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

      //await vm.fetchForYou(context.read<GlobalAnimeFavoritesProvider>());

      if (widget.animeToOpen != null) {
        autoOpenAnime(widget.animeToOpen as Anime);
      }

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

  void autoOpenAnime(Anime anime) {
    final vm = context.read<AnimeViewModel>();
    vm.openAnimePage(context, anime);
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
                      Theme.of(context).brightness == Brightness.light
                          ? 'assets/icons/logo_manganime.png'
                          : 'assets/icons/app_icon.png',
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
    // 1. On écoute le provider de favoris
    final favoritesProvider = context.watch<GlobalAnimeFavoritesProvider>();

    // 🛑 CAS 1 : Le provider est encore en train de charger les likes depuis Hive/API
    if (favoritesProvider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Chargement de vos préférences..."),
          ],
        ),
      );
    }

    // 🚀 CAS 2 : Le provider est PRÊT, mais la liste "For You" est encore vide
    // On doit lancer le fetch maintenant !
    if (vm.forYou.isEmpty && !vm.isLoadingForYou) {
      // On utilise addPostFrameCallback pour ne pas déclencher un fetch pendant le build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.fetchForYou(favoritesProvider);
      });

      // On affiche un loader le temps que fetchForYou fasse son travail
      return const Center(child: CircularProgressIndicator());
    }

    // ✅ CAS 3 : Tout est prêt, on affiche la liste
    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      backgroundColor: Colors.white,

      onRefresh: () async {
        // On appelle la nouvelle version async du VM
        await vm.refreshForYou(favoritesProvider);
      },

      child: GridView.builder(
        controller: _forYouController,
        // ⚠️ INDISPENSABLE : Permet de tirer vers le bas même si la liste est courte
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.only(top: 12, bottom: 16),
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
              favoritesProvider.toggleFavorite(anime);
            },
            isLiked: favoritesProvider.isAnimeLiked(anime.id),
          );
        },
        itemCount: vm.forYou.length,
      ),
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
