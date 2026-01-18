import 'package:flutter/material.dart';

class TabSwitcher extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
  final List<bool>? isEnabled;

  const TabSwitcher({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onChanged,
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
          onTap: enabled ? () => onChanged?.call(index) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: isSelected ? 20 : 18,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: enabled
                        ? (isSelected ? Colors.white : Colors.white70)
                        : Colors.white30,
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    height: 3,
                    width: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC7F141), Color(0xFF51D95F)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
