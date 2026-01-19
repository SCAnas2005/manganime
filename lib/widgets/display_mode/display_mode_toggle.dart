import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/display_mode/display_mode.dart';
/// Widget qui permet de basculer entre les modes d'affichage : grille ou liste
class DisplayModeToggle extends StatelessWidget {
  final DisplayMode mode;
  final ValueChanged<DisplayMode> onChanged;

  const DisplayModeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.grid_view),
          color: mode == DisplayMode.grid
              ? (Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white)
              : Colors.grey,
          onPressed: () => onChanged(DisplayMode.grid),
        ),
        IconButton(
          icon: const Icon(Icons.list),
          color: mode == DisplayMode.list
              ? (Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white)
              : Colors.grey,
          onPressed: () => onChanged(DisplayMode.list),
        ),
      ],
    );
  }
}
