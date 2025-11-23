import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/viewmodels/manga_view_model.dart';
import 'package:flutter_application_1/widgets/manga_card.dart';
import 'package:flutter_application_1/widgets/ui/tab_section.dart';
import 'package:flutter_application_1/widgets/ui/tab_switcher.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();

    _popularController = ScrollController();
    _publishingController = ScrollController();
    _mostLikedController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<MangaViewModel>();

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
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabSwitcher(
                tabs: ["Pour toi", "Tendances"],
                selectedIndex: selectedTab,
                onChanged: (index) {
                  setState(() {
                    selectedTab = index;
                  });
                },
                isEnabled: [
                  true,
                  false,
                ], // mettre [true,true] quand la page tendance sera faite
              ),
              const SizedBox(height: 20),

              _buildForYou(vm),
              const SizedBox(height: 20),
              // const Text(
              //   "Les plus populaires",
              //   style: TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.white,
              //   ),
              // ),
              // const SizedBox(height: 10),
              // _buildHorizontalList(
              //   vm.popular,
              //   controller: _popularController,
              //   onTap: vm.openMangaPage,
              // ),
              // const SizedBox(height: 20),
              // const Text(
              //   "En publication",
              //   style: TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.white,
              //   ),
              // ),
              // const SizedBox(height: 10),
              // _buildHorizontalList(
              //   vm.publishing,
              //   controller: _publishingController,
              //   onTap: vm.openMangaPage,
              // ),
              // const SizedBox(height: 20),
              // const Text(
              //   "Les plus aimés",
              //   style: TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.white,
              //   ),
              // ),
              // const SizedBox(height: 10),
              // _buildHorizontalList(
              //   vm.mostLiked,
              //   controller: _mostLikedController,
              //   onTap: vm.openMangaPage,
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildHorizontalList(
  //   List<Manga> mangas, {
  //   Function(BuildContext context, Manga manga)? onTap,
  //   ScrollController? controller,
  // }) {
  //   return SizedBox(
  //     height: 250,
  //     child: ListView.builder(
  //       controller: controller,
  //       scrollDirection: Axis.horizontal,
  //       itemCount: mangas.length,
  //       itemBuilder: (context, index) {
  //         final manga = mangas[index];
  //         return Padding(
  //           padding: const EdgeInsets.only(right: 10),
  //           child: MangaCard(
  //             manga: manga,
  //             onTap: (item) => onTap?.call(context, item),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  // Onglet 1 : Pour toi
  Widget _buildForYou(MangaViewModel vm) {
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
          ),
        ),
      ],
    );
  }
}
