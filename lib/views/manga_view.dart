import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/viewmodels/manga_view_model.dart';
import 'package:flutter_application_1/widgets/manga_card.dart';
import 'package:flutter_application_1/widgets/ui/tab_switcher.dart';
import 'package:provider/provider.dart';

/// Vue principale pour l'affichage des Mangas.
/// Cette vue gère deux onglets : "Pour toi" (recommandations) et "Tendances" (catégories classiques).
class MangaView extends StatefulWidget {
<<<<<<< Updated upstream
  const MangaView({super.key});
=======
  final Manga? mangaToOpen;
  const MangaView({this.mangaToOpen, super.key});
>>>>>>> Stashed changes

  @override
  State<MangaView> createState() => _MangaViewState();
}

class _MangaViewState extends State<MangaView> {
<<<<<<< Updated upstream
  int selectedTab = 1; // Par défaut sur "Tendances" car algo pas encore fait
=======
  // Index de l'onglet sélectionné (0: Pour toi, 1: Tendances)
  int selectedTab = 0;
>>>>>>> Stashed changes

  // Controllers pour les listes horizontales dans l'onglet Tendances
  late ScrollController _popularController;
  late ScrollController _publishingController;
  late ScrollController _mostLikedController;

<<<<<<< Updated upstream
=======
  // Controller pour la grille verticale infinie dans l'onglet Pour toi
  late ScrollController _forYouController;

>>>>>>> Stashed changes
  @override
  void initState() {
    super.initState();

    // Initialisation des controllers
    _popularController = ScrollController();
    _publishingController = ScrollController();
    _mostLikedController = ScrollController();
<<<<<<< Updated upstream

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<MangaViewModel>();

=======
    _forYouController = ScrollController();

    // Chargement initial des données après le premier build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<MangaViewModel>();

      // Si un manga a été passé en paramètre (ex: via notification), on l'ouvre directement
      if (widget.mangaToOpen != null) {
        autoOpenManga(widget.mangaToOpen as Manga);
      }

      // Ajout des listeners pour la pagination infinie
      // "Pour toi" (Vertical)
      _forYouController.addListener(() {
        if (_forYouController.position.pixels >=
            _forYouController.position.maxScrollExtent - 200) {
          vm.fetchForYou(context.read<GlobalMangaFavoritesProvider>());
        }
      });

      // "Populaires" (Horizontal)
>>>>>>> Stashed changes
      _popularController.addListener(() {
        if (_popularController.position.pixels >=
            _popularController.position.maxScrollExtent - 200) {
          vm.fetchPopular();
        }
      });

      // "En publication" (Horizontal)
      _publishingController.addListener(() {
        if (_publishingController.position.pixels >=
            _publishingController.position.maxScrollExtent - 200) {
          vm.fetchPublishing();
        }
      });

      // "Les plus aimés" (Horizontal)
      _mostLikedController.addListener(() {
        if (_mostLikedController.position.pixels >=
            _mostLikedController.position.maxScrollExtent - 200) {
          vm.fetchMostLiked();
        }
      });
    });
  }

<<<<<<< Updated upstream
=======
  /// Ouvre la page de détail d'un manga spécifique.
  void autoOpenManga(Manga manga) {
    final vm = context.read<MangaViewModel>();
    vm.openMangaPage(context, manga);
  }

>>>>>>> Stashed changes
  @override
  void dispose() {
    // Nettoyage des controllers pour éviter les fuites de mémoire
    _popularController.dispose();
    _publishingController.dispose();
    _mostLikedController.dispose();
    _forYouController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MangaViewModel>();

    return SafeArea(
<<<<<<< Updated upstream
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Onglets "Pour toi" et "Tendances"
              TabSwitcher(
                tabs: ["Pour toi", "Tendances"],
                selectedIndex: selectedTab,
                onChanged: (index) {
                  setState(() {
                    selectedTab = index;
                  });
                },
                isEnabled: [false, true], // "Pour toi" désactivé car algo pas encore fait
              ),
              const SizedBox(height: 20),

              // Contenu selon l'onglet sélectionné
              if (selectedTab == 0)
                _buildForYou(vm)
              else
                _buildTendances(vm),
            ],
          ),
=======
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // En-tête avec Logo et Barre de Recherche
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
                  miniSearchBarManga(context),
                ],
              ),
            ),
            
            // Sélecteur d'onglets (Pour toi / Tendances)
            TabSwitcher(
              tabs: const ["Pour toi", "Tendances"],
              selectedIndex: selectedTab,
              onChanged: (index) {
                setState(() {
                  if (selectedTab != index) selectedTab = index;
                });
              },
              isEnabled: const [true, true],
            ),
            const SizedBox(height: 20),

            // Contenu de l'onglet sélectionné
            Expanded(
              child: selectedTab == 0
                  // L'onglet 0 gère son propre scroll (GridView)
                  ? _buildForYou(vm)
                  // L'onglet 1 nécessite un SingleChildScrollView car composé de plusieurs sections
                  : SingleChildScrollView(child: _buildTendances(vm)),
            ),
          ],
>>>>>>> Stashed changes
        ),
      ),
    );
  }

<<<<<<< Updated upstream
  // Onglet "Pour toi" - À implémenter plus tard
  Widget _buildForYou(MangaViewModel vm) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Text(
          "Recommandations à venir...",
          style: TextStyle(color: Colors.white54, fontSize: 16),
=======
  /// Construit l'onglet "Pour toi" (Grille de recommandations personnalisées).
  Widget _buildForYou(MangaViewModel vm) {
    final favoritesProvider = context.watch<GlobalMangaFavoritesProvider>();

    // CAS 1 : Chargement initial des favoris (nécessaire pour l'algo de reco)
    if (favoritesProvider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text("Chargement de vos préférences..."),
          ],
>>>>>>> Stashed changes
        ),
      ),
    );
  }

<<<<<<< Updated upstream
  // Onglet "Tendances"
  Widget _buildTendances(MangaViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SECTION 1 : Les plus populaires
        const Text(
          "Les plus populaires",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
=======
    // CAS 2 : Liste vide (premier appel API pas encore fait)
    // On lance le fetch une fois que l'interface est prête
    if (vm.forYou.isEmpty && !vm.isLoadingForYou && vm.hasMoreForYou) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.fetchForYou(favoritesProvider);
      });
      return const Center(child: CircularProgressIndicator());
    }

    // CAS 3 : Affichage de la grille avec fonction "Tirer pour rafraîchir"
    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      backgroundColor: Colors.white,
      onRefresh: () async {
        await vm.refreshForYou(favoritesProvider);
      },
      child: GridView.builder(
        controller: _forYouController,
        // AlwaysScrollableScrollPhysics permet le pull-to-refresh même si la liste est petite
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 12, bottom: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.62,
>>>>>>> Stashed changes
        ),
        const SizedBox(height: 10),
        _buildHorizontalList(
          vm.popular,
          controller: _popularController,
          onTap: vm.openMangaPage,
        ),

        const SizedBox(height: 20),

        // SECTION 2 : En publication
        const Text(
          "En publication",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        _buildHorizontalList(
          vm.publishing,
          controller: _publishingController,
          onTap: vm.openMangaPage,
        ),

        const SizedBox(height: 20),

        // SECTION 3 : Les plus aimés
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
          onTap: vm.openMangaPage,
        ),
      ],
    );
  }

  Widget _buildHorizontalList(
    List<Manga> mangas, {
    Function(BuildContext context, Manga manga)? onTap,
    ScrollController? controller,
  }) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        itemCount: mangas.length,
        cacheExtent: 300, // Optimisation performance
        itemBuilder: (context, index) {
<<<<<<< Updated upstream
          final manga = mangas[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: MangaCard(
              manga: manga,
              onTap: (item) => onTap?.call(context, item),
            ),
=======
          // Protection contre l'index hors limites
          if (index >= vm.forYou.length) return const SizedBox();

          final manga = vm.forYou[index];
          return MangaCard(
            manga: manga,
            onTap: (m) => vm.openMangaPage(context, m),
            onLikeDoubleTap: (m) {
              favoritesProvider.toggleFavorite(manga);
            },
>>>>>>> Stashed changes
          );
        },
      ),
    );
  }
<<<<<<< Updated upstream
=======

  /// Construit l'onglet "Tendances" (Sections horizontales catégorisées).
  Widget _buildTendances(MangaViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section: Les plus populaires (all time)
        TabSection<Manga>(
          title: "Les plus populaires",
          items: vm.popular,
          controller: _popularController,
          onTap: (manga) => vm.openMangaPage(context, manga),
          itemBuilder: (manga) => MangaCard(
            manga: manga,
            onTap: (m) => vm.openMangaPage(context, m),
            onLikeDoubleTap: (manga) {
              context.read<GlobalMangaFavoritesProvider>().toggleFavorite(manga);
            },
          ),
        ),
        const SizedBox(height: 20),

        // Section: En cours de publication
        TabSection<Manga>(
          title: "En publication",
          items: vm.publishing,
          controller: _publishingController,
          onTap: (manga) => vm.openMangaPage(context, manga),
          itemBuilder: (manga) => MangaCard(
            manga: manga,
            onTap: (m) => vm.openMangaPage(context, m),
            onLikeDoubleTap: (manga) {
              context.read<GlobalMangaFavoritesProvider>().toggleFavorite(manga);
            },
          ),
        ),

        // Section: Les mieux notés/aimés
        TabSection<Manga>(
          title: "Les plus aimés",
          items: vm.mostLiked,
          controller: _mostLikedController,
          onTap: (manga) => vm.openMangaPage(context, manga),
          itemBuilder: (manga) => MangaCard(
            manga: manga,
            onTap: (m) => vm.openMangaPage(context, m),
            onLikeDoubleTap: (manga) {
              context.read<GlobalMangaFavoritesProvider>().toggleFavorite(manga);
            },
          ),
        ),
      ],
    );
  }
>>>>>>> Stashed changes
}
