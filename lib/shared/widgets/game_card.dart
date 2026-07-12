import 'package:flutter/material.dart';
import '../models/game_card_data.dart';

class GameCard extends StatelessWidget {
  final GameCardData data;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.data,
    required this.onTap,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'lightbulb_outline':
        return Icons.lightbulb_outline;
      case 'password':
        return Icons.password;
      case 'extension':
        return Icons.extension;
      default:
        return Icons.videogame_asset;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLocked = !data.isUnlocked;

    return Card(
      elevation: isLocked ? 0 : 2,
      color: isLocked ? colorScheme.surfaceContainerHighest.withValues(alpha : 0.5) : colorScheme.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLocked ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isLocked ? colorScheme.surfaceContainerHighest : colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconData(data.icon),
                      color: isLocked ? colorScheme.onSurface.withValues(alpha : 0.5) : colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                data.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isLocked ? colorScheme.onSurface.withValues(alpha : 0.5) : colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (data.hasDailyBadge) ...[
                              const SizedBox(width: 8.0),
                              const Icon(Icons.local_fire_department, color: Colors.orange, size: 20.0),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Rating: ${data.rating}  •  XP: ${data.xp}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isLocked ? colorScheme.onSurfaceVariant.withValues(alpha : 0.5) : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isLocked ? Icons.lock : Icons.chevron_right,
                    color: isLocked ? colorScheme.onSurface.withValues(alpha : 0.3) : colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Games Played: ${data.gamesPlayed}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isLocked ? colorScheme.onSurfaceVariant.withValues(alpha : 0.5) : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Best: ${data.bestScore}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isLocked ? colorScheme.onSurfaceVariant.withValues(alpha : 0.5) : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}