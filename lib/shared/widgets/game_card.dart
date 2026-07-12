import 'package:flutter/material.dart';

import '../models/game_model.dart';

class GameCard extends StatelessWidget {
  final GameModel game;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLocked = !game.isUnlocked;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: isLocked ? 0 : 2,
      color: isLocked ? colorScheme.surfaceContainerHighest.withOpacity(0.5) : colorScheme.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLocked ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildIcon(colorScheme, isLocked),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          game.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isLocked ? colorScheme.onSurface.withOpacity(0.5) : colorScheme.onSurface,
                          ),
                        ),
                        if (game.hasDailyChallenge) ...[
                          const SizedBox(width: 8.0),
                          const Icon(Icons.local_fire_department, color: Colors.orange, size: 20.0),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Rating: ${game.currentRating}  •  Best: ${game.bestRating}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isLocked ? colorScheme.onSurfaceVariant.withOpacity(0.5) : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Games Played: ${game.gamesPlayed}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isLocked ? colorScheme.onSurfaceVariant.withOpacity(0.5) : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              Icon(
                isLocked ? Icons.lock : Icons.chevron_right,
                color: isLocked ? colorScheme.onSurface.withOpacity(0.3) : colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ColorScheme colorScheme, bool isLocked) {
    return Container(
      width: 56.0,
      height: 56.0,
      decoration: BoxDecoration(
        color: isLocked ? colorScheme.surfaceContainerHighest : colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        game.icon,
        size: 28.0,
        color: isLocked ? colorScheme.onSurface.withOpacity(0.5) : colorScheme.onPrimaryContainer,
      ),
    );
  }
}