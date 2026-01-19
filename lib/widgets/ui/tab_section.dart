import 'package:flutter/material.dart';
/// Widget représentant une section avec un titre et une liste horizontale d'éléments
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
