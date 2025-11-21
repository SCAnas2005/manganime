import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/bottom_nav/bottom_nav_view.dart';
import 'package:flutter_application_1/viewmodels/anime_view_model.dart';
import 'package:flutter_application_1/viewmodels/manga_view_model.dart';
import 'package:flutter_application_1/views/anime_view.dart';
import 'package:flutter_application_1/views/manga_view.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => HomePageState();
}

// class HomePageState extends State<HomePage> {
//   JikanService service = JikanService();
//   // AniListService service = AniListService();
//   List<Anime> animes = [];
//   int currentPage = 1;
//   bool isLoading = false;
//   bool hasMore = true;

//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     fetchAnimes(); // première page

//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels >=
//           _scrollController.position.maxScrollExtent - 300) {
//         // proche du bas → charger la page suivante
//         fetchAnimes();
//       }
//     });
//   }

//   Future<void> fetchAnimes() async {
//     if (isLoading || !hasMore) return;

//     isLoading = true;
//     try {
//       final newAnimes = await service.getTopAnime(page: currentPage);

//       if (newAnimes.isEmpty) {
//         hasMore = false;
//       } else {
//         animes.addAll(newAnimes);
//         currentPage++;
//       }
//     } catch (e) {
//       print('Erreur: $e');
//     }

//     isLoading = false;
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       bottomNavigationBar: BottomNavView(currentIndex: 1),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 hintText: 'Rechercher un anime...',
//               ),
//               onSubmitted: (value) => {},
//             ),
//           ),
//           Expanded(
//             // <-- ajoute ceci
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: GridView.builder(
//                 controller: _scrollController,
//                 itemCount: animes.length + 1,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                   childAspectRatio: 0.7,
//                 ),
//                 itemBuilder: (context, index) {
//                   if (index == animes.length) {
//                     return isLoading
//                         ? const Center(child: CircularProgressIndicator())
//                         : const SizedBox();
//                   }

//                   final anime = animes[index];
//                   return AnimeCard(anime: anime);
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
// }
class HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    ChangeNotifierProvider(
      create: (_) => AnimeViewModel(),
      child: const AnimeView(),
    ),
    ChangeNotifierProvider(
      create: (_) => MangaViewModel(),
      child: const MangaView(),
    ),
    const _PlaceholderPage(
      title: "Favoris",
      description: "La section favoris arrive bientôt.",
    ),
    const _PlaceholderPage(
      title: "Statistiques",
      description: "Les statistiques seront disponibles plus tard.",
    ),
    const _PlaceholderPage(
      title: "Paramètres",
      description: "Personnalisez l'app prochainement.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavView(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  final String description;

  const _PlaceholderPage({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
