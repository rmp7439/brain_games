import 'package:flutter/material.dart';

class DailyChallengeCard extends StatelessWidget {
  final String gameName;
  final int rewardXP;
  final int rewardCoins;
  final VoidCallback onTap;

  const DailyChallengeCard({
    super.key,
    required this.gameName,
    required this.rewardXP,
    required this.rewardCoins,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.tertiary, theme.colorScheme.tertiaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Icon(Icons.stars, color: theme.colorScheme.onTertiary, size: 40.0),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Challenge: $gameName',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onTertiary,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Reward: $rewardXP XP • $rewardCoins Coins',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onTertiary.withValues(alpha : 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_circle_fill, color: theme.colorScheme.onTertiary),
          ],
        ),
      ),
    );
  }
}