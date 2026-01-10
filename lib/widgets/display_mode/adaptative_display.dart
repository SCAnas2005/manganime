import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/display_mode/display_mode.dart';

class AdaptativeDisplay<T> extends StatelessWidget {
  final List<T> items;
  final DisplayMode mode;
  final Widget Function(T item) gridBuilder;
  final Widget Function(T item) listbuilder;

  const AdaptativeDisplay({
    super.key,
    required this.items,
    required this.mode,
    required this.gridBuilder,
    required this.listbuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (mode == DisplayMode.grid) {
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => gridBuilder(items[i]),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => listbuilder(items[i]),
    );
  }
}
