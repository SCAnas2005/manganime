import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_1/viewmodels/anime_stat_model.dart';
import 'package:flutter_application_1/widgets/anime_stat_card.dart';

class AnimeStatView extends StatefulWidget {
  const AnimeStatView({super.key});

  @override
  State<StatefulWidget> createState() => AnimeStatViewState();
}

class AnimeStatViewState extends  State<AnimeStatView>{
  final AnimeStatModel _animeStatModel = AnimeStatModel();
  List<Color> _colorsList = [Color(0xFFC7F141), Color(0xFF51D95F), Color(0xFFFFB84D), Color(0xFFFF6B9D), Color(0xFF6B7FFF)];
  int _indexColor = -1;
  Key _animationKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _animeStatModel.init();
  }

  bool _wasVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isVisible = TickerMode.of(context);
    if (isVisible && !_wasVisible) {
      setState(() {
        _animationKey = UniqueKey();
      });
    }
    _wasVisible = isVisible;
  }

  @override
  void dispose() {
    _animeStatModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _animeStatModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0E0E0E),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // === Grille de statistiques ===
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Statistiques',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: KeyedSubtree(
                    key: _animationKey,
                    child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      StatCard(
                        icon: Icons.favorite,
                        label: 'Likes Total',
                        value: _animeStatModel.likesNumber.toString(),
                        color: const Color(0xFFC7F141),
                      ),
                      StatCard(
                        icon: Icons.visibility,
                        label: 'Vues',
                        value: _animeStatModel.viewNumber.toString(),
                        color: const Color(0xFFC7F141),
                      ),
                      StatCard(
                        icon: Icons.access_time,
                        label: 'Temps total',
                        value: _animeStatModel.timeFormatted,
                        color: const Color(0xFFC7F141),
                      ),
                      StatCard(
                        icon: Icons.emoji_events,
                        label: 'Niveau',
                        value: _animeStatModel.rankNumber.toString(),
                        subtitle: _animeStatModel.currentRankTitle,
                        progress: _animeStatModel.rankProgress,
                        color: _animeStatModel.currentRankColor,
                      ),
                    ],
                  ),
                ),
                ),

                const SizedBox(height: 20),
                // === Graphique Pie ===
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BlurCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.trending_up,
                              color: Color(0xFFC7F141), size: 20),
                          SizedBox(width: 8),
                          Text('Genres préférés',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              for (var i = 0; i < _animeStatModel.categoryPercentage.length; i++)
                                PieChartSectionData(
                                  value: _animeStatModel.categoryPercentage.values.elementAt(i).toDouble(),
                                  color: _colorsList[i % _colorsList.length],
                                  title: '',
                                )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (var entryMap in _animeStatModel.categoryPercentage.entries.toList().asMap().entries)
                      GenreLegend(
                        name: entryMap.value.key,
                        percent: entryMap.value.value,
                        color: _colorsList[entryMap.key % _colorsList.length],
                      ),
                    ],
                  ),
                ),
                ),

                const SizedBox(height: 20),

                // === Succès récents ===
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BlurCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Succès récents',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      Achievement(
                        icon: Icons.emoji_events,
                        title: 'Marathon Master',
                        desc: 'Regarder 10 épisodes en une journée',
                        time: 'Nouveau',
                        color: Color(0xFFC7F141),
                      ),
                      SizedBox(height: 12),
                      Achievement(
                        icon: Icons.favorite,
                        title: 'Super Fan',
                        desc: 'Atteindre 1000 likes',
                        time: 'Il y a 3j',
                        color: Color(0xFF51D95F),
                      ),
                      SizedBox(height: 12),
                      Achievement(
                        icon: Icons.trending_up,
                        title: 'Découvreur',
                        desc: 'Explorer 50 animes différents',
                        time: 'Il y a 1s',
                        color: Color(0xFFFFB84D),
                      ),
                    ],
                  ),
          ),
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }
}
