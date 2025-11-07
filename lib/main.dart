import 'package:flutter/material.dart';
import 'package:flutter_application_1/anime.dart';
import 'package:flutter_application_1/services/JikanService.dart';
import 'package:flutter_application_1/views/AnimeInfo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  JikanService service = JikanService();
  // AniListService service = AniListService();
  List<Anime> animes = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchAnimes(); // première page

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        // proche du bas → charger la page suivante
        fetchAnimes();
      }
    });
  }

  Future<void> fetchAnimes() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    try {
      final newAnimes = await service.getTopAnime(page: currentPage);

      if (newAnimes.isEmpty) {
        hasMore = false;
      } else {
        animes.addAll(newAnimes);
        currentPage++;
      }
    } catch (e) {
      print('Erreur: $e');
    }

    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Rechercher un anime...',
              ),
              onSubmitted: (value) => {},
            ),
          ),
          Expanded(
            // <-- ajoute ceci
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                controller: _scrollController,
                itemCount: animes.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  if (index == animes.length) {
                    return isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox();
                  }

                  final anime = animes[index];
                  return AnimeCard(anime: anime);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class AnimeCard extends StatelessWidget {
  final Anime anime;

  const AnimeCard({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // Navigue vers la page de détails
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AnimeInfoView(anime)),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: anime.imageUrl.isNotEmpty
                  ? Image.network(anime.imageUrl, fit: BoxFit.cover)
                  : Container(color: Colors.grey[300]),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                anime.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
