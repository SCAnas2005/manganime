import 'package:flutter/material.dart';

class AnimatedCounter extends StatelessWidget {
  final String value;
  final TextStyle? style;

  const AnimatedCounter({
    Key? key,
    required this.value,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final inAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(animation);
        
        final outAnimation = Tween<Offset>(
          begin: const Offset(0.0, -1.0),
          end: Offset.zero,
        ).animate(animation);

        if (child.key == ValueKey(value)) {
          return SlideTransition(
            position: inAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        } else {
           return SlideTransition(
            position: outAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        }
      },
      child: Text(
        value,
        key: ValueKey<String>(value),
        style: style,
      ),
    );
  }
}
