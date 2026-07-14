import 'package:flutter/material.dart';

class HeartIndicator extends StatelessWidget {
  final int attemptsRemaining;
  final int maxAttempts;

  const HeartIndicator({
    super.key,
    required this.attemptsRemaining,
    required this.maxAttempts,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxAttempts, (index) {
        final isFull = index < attemptsRemaining;
        return Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeInBack,
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.0).animate(anim),
              child: FadeTransition(
                opacity: anim,
                child: child,
              ),
            ),
            child: Icon(
              isFull ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isFull),
              color: isFull ? Colors.red : Colors.grey.shade400,
              size: 24, 
            ),
          ),
        );
      }),
    );
  }
}