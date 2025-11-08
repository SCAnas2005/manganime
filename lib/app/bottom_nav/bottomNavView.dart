import 'package:flutter/material.dart';

class BottomNavView extends StatefulWidget {
  final int currentIndex;
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
        widget.onTap(index); // 🔹 Notifie le parent du nouvel index
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
