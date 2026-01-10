import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/global_manga_favorites_provider.dart';
import 'package:flutter_application_1/viewmodels/manga_view_model.dart';
import 'package:flutter_application_1/widgets/manga_card.dart';
import 'package:flutter_application_1/widgets/ui/tab_section.dart';
import 'package:flutter_application_1/widgets/ui/tab_switcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/widgets/search_widget/search_button.dart';

class MangaView extends StatefulWidget {
  const MangaView({super.key});

  @override
  State<MangaView> createState() => _MangaViewState();
}

class _MangaViewState extends State<MangaView> {
  int selectedTab = 0;

  late ScrollController _popularController;
  late ScrollController _publishingController;
  late ScrollController _mostLikedController;

  late ScrollController _forYouController;

  @override
  void initState() {
    super.initState();

    _popularController = ScrollController();
    _publishingController = ScrollController();
    _mostLikedController = ScrollController();

    _forYouController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<MangaViewModel>();

      await vm.fetchForYou(context.read<GlobalMangaFavoritesProvider>());

      _forYouController.addListener(() {
        if (_forYouController.position.pixels >=
            _forYouController.position.maxScrollExtent - 200) {
          vm.fetchForYou(context.read<GlobalMangaFavoritesProvider>());
        }
      });

      _popularController.addListener(() {
        if (_popularController.position.pixels >=
            _popularController.position.maxScrollExtent - 200) {
          vm.fetchPopular();
        }
      });

      _publishingController.addListener(() {
        if (_publishingController.position.pixels >=
            _publishingController.position.maxScrollExtent - 200) {
          vm.fetchPublishing();
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
    _publishingController.dispose();
    _mostLikedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MangaViewModel>();

    return SafeArea(
      // --- CHANGEMENT 1 : SingleChildScrollView RETIRÉ ---
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

  // Onglet 1 : Pour toi
  Widget _buildForYou(MangaViewModel vm) {
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
        final manga = vm.forYou[index];
        return MangaCard(
          manga: manga,
          onTap: (a) => vm.openMangaPage(context, a),
          onLikeDoubleTap: (a) {
            context.read<GlobalMangaFavoritesProvider>().toggleFavorite(manga);
          },
          // isLiked: context.watch<GlobalAnimeFavoritesProvider>().isAnimeLiked(
          //   manga.id,
          // ),
        );
      },
      itemCount: vm.forYou.length,
    );
  }

  // Onglet 2 : Tendences
  Widget _buildTendences(MangaViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabSection<Manga>(
          title: "Les plus populaires",
          items: vm.popular,
          controller: _popularController,
          onTap: (manga) => vm.openMangaPage(context, manga),
          itemBuilder: (manga) => MangaCard(
            manga: manga,
            onTap: (m) => vm.openMangaPage(context, m),
            onLikeDoubleTap: (manga) {
              context.read<GlobalMangaFavoritesProvider>().toggleFavorite(
                manga,
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        TabSection<Manga>(
          title: "En publication",
          items: vm.publishing,
          controller: _publishingController,
          onTap: (manga) => vm.openMangaPage(context, manga),
          itemBuilder: (manga) => MangaCard(
            manga: manga,
            onTap: (m) => vm.openMangaPage(context, m),
            onLikeDoubleTap: (manga) {
              context.read<GlobalMangaFavoritesProvider>().toggleFavorite(
                manga,
              );
            },
          ),
        ),
        TabSection<Manga>(
          title: "Les plus aimés",
          items: vm.mostLiked,
          controller: _mostLikedController,
          onTap: (manga) => vm.openMangaPage(context, manga),
          itemBuilder: (manga) => MangaCard(
            manga: manga,
            onTap: (m) => vm.openMangaPage(context, m),
            onLikeDoubleTap: (manga) {
              context.read<GlobalMangaFavoritesProvider>().toggleFavorite(
                manga,
              );
            },
          ),
        ),
      ],
    );
  }
}
