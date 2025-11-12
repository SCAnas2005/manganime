import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_1/viewmodels/AnimeStatModel.dart';
import 'package:flutter_application_1/widgets/animeStatCard.dart';

class AnimeStatView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AnimeStatViewState();
}

class AnimeStatViewState extends  State<AnimeStatView>{
  final AnimeStatModel _animeStatModel = AnimeStatModel();
  List<Color> _colorsList = [Color(0xFFC7F141), Color(0xFF51D95F), Color(0xFFFFB84D), Color(0xFFFF6B9D), Color(0xFF6B7FFF)];
  int _indexColor = -1;

  @override
  void initState() {
    super.initState();
    _animeStatModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
        child: Column(
          children: [
            // === Grille de statistiques ===
            const Text(
              'Statistiques',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            GridView.count(
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
                  value: _animeStatModel.timeNumber.toString(),
                  color: const Color(0xFFC7F141),
                ),
                StatCard(
                  icon: Icons.emoji_events,
                  label: 'Niveau',
                  value: _animeStatModel.rankNumber.toString(),
                  subtitle: 'Otaku Master',
                  color: const Color(0xFFC7F141),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // === Graphique Pie ===
            BlurCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.trending_up,
                          color: Color(0xFFC7F141), size: 20),
                      SizedBox(width: 8),
                      Text('Genres préférés',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
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

            const SizedBox(height: 20),

            // === Succès récents ===
            BlurCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Succès récents',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
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
          ],
        ),
      ),
    );
  }
}
