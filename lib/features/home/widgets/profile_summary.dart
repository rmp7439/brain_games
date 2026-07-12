import 'package:flutter/material.dart';

class ProfileSummary extends StatelessWidget {
  final int level;
  final int xp;
  final int totalGames;

  const ProfileSummary({
    super.key,
    required this.level,
    required this.xp,
    required this.totalGames,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat(context, 'Level', level.toString()),
            _buildStat(context, 'Total XP', xp.toString()),
            _buildStat(context, 'Games', totalGames.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha : 0.8),
          ),
        ),
      ],
    );
  }
}