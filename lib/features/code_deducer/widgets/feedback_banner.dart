import 'package:flutter/material.dart';
import '../providers/code_deducer_provider.dart';

class FeedbackBanner extends StatelessWidget {
  final GameStatus status;
  final String feedback;
  final int guessCount;

  const FeedbackBanner({
    super.key,
    required this.status,
    required this.feedback,
    required this.guessCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlaying = status == GameStatus.playing;
    final isWon = status == GameStatus.won;
    
    Color bgColor = theme.colorScheme.surfaceContainerHighest;
    Color fgColor = theme.colorScheme.onSurfaceVariant;
    
    if (!isPlaying) {
      bgColor = isWon ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1);
      fgColor = isWon ? Colors.green.shade700 : Colors.red.shade700;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            feedback.isEmpty ? 'Ready for your first guess.' : feedback,
            key: ValueKey('${feedback}_$guessCount'),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: fgColor,
            ),
          ),
        ),
      ),
    );
  }
}