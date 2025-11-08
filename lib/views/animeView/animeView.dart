import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/animeView/animeViewModel.dart';
import 'package:flutter_application_1/widgets/animeCard.dart';
import 'package:provider/provider.dart';

class AnimeView extends StatefulWidget {
  const AnimeView({super.key});

  @override
  State<AnimeView> createState() => _AnimeViewState();
}

class _AnimeViewState extends State<AnimeView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final vm = context.read<AnimeViewModel>();
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        vm.fetchAnimes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnimeViewModel(),
      child: Consumer<AnimeViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Rechercher un anime...',
                  ),
                  onSubmitted: (value) {
                    // TODO : recherche à implémenter
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    controller: _scrollController,
                    itemCount: viewModel.animes.length + 1,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                    itemBuilder: (context, index) {
                      if (index == viewModel.animes.length) {
                        return viewModel.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : const SizedBox();
                      }

                      final anime = viewModel.animes[index];
                      return AnimeCard(anime: anime);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
