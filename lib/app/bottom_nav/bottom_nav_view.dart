import 'package:flutter/material.dart';

/// Barre de navigation inférieure de l'application.
///
/// Ce widget affiche les différentes sections principales
/// (Anime, Manga, Favoris, Statistiques, Paramètres)
/// et notifie le widget parent lorsque l'onglet sélectionné change.
class BottomNavView extends StatefulWidget {
  /// Index de l'onglet actuellement sélectionné.
  final int currentIndex;

  /// Callback appelé lorsqu'un onglet est sélectionné.
  ///
  /// L'index de l'onglet sélectionné est passé en paramètre.
  final Function(int) onTap;

  const BottomNavView({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<StatefulWidget> createState() => _BottomNavigationBarState();
}

class _BottomNavigationBarState extends State<BottomNavView> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: (index) {
        widget.onTap(index); // Notifie le parent du nouvel index
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.tv), label: "Anime"),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: "Manga"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favoris"),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: "Statistiques",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "Paramètres",
        ),
      ],
    );
  }
}
