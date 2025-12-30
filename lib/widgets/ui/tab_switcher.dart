import 'package:flutter/material.dart';

/// Widget de sélection d'onglets réutilisable
class TabSwitcher extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onChanged;
  final List<bool>? isEnabled; // Pour désactiver certains onglets

  const TabSwitcher({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(tabs.length, (index) {
        final isSelected = index == selectedIndex;
        final enabled = isEnabled?[index] ?? true;
        
        return GestureDetector(
          onTap: enabled ? () => onChanged(index) : null,
          child: Padding(
            padding: EdgeInsets.only(left: index > 0 ? 20 : 0),
            child: Text(
              tabs[index],
              style: TextStyle(
                fontSize: isSelected ? 20 : 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: !enabled 
                    ? Colors.white38 
                    : isSelected 
                        ? Colors.white 
                        : Colors.white70,
              ),
            ),
          ),
        );
      }),
    );
  }
}
