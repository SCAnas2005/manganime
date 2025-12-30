import 'package:flutter/material.dart';

class TabSection<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final Function(T) onTap;
  final ScrollController controller;
  final Widget Function(T item) itemBuilder;

  const TabSection({
    super.key,
    required this.title,
    required this.items,
    required this.onTap,
    required this.controller,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: ListView.builder(
            controller: controller,
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            cacheExtent: 300, // Pré-rendre 300px d'éléments hors écran pour un scroll fluide
            addAutomaticKeepAlives: false, // Éviter de garder les widgets en mémoire inutilement
            addRepaintBoundaries: true, // Isoler les repaints pour de meilleures performances
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: itemBuilder(item),
              );
            },
          ),
        ),
      ],
    );
  }
}
