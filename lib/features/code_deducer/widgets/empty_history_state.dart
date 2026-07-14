import 'package:flutter/material.dart';

class EmptyHistoryState extends StatelessWidget {
  const EmptyHistoryState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Column(
        children: [
          Icon(
            Icons.history, 
            size: 48, 
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No guesses yet.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your history will appear here.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}