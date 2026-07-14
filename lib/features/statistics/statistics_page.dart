import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/game_progress.dart';
import '../../shared/models/game_stats.dart';
import '../../shared/providers/repository_providers.dart';

final statisticsProvider = FutureProvider.autoDispose((ref) async {
  final repository = ref.watch(gameRepositoryProvider);
  final stats = await repository.getGameStats('code_deducer');
  final progress = await repository.getGameProgress('code_deducer');
  return {'stats': stats, 'progress': progress};
});

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    final m = duration.inMinutes.toString().padLeft(2, '0');
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (data) {
          // Explictly cast the data to resolve the Object undefined getter analysis errors
          final stats = data['stats'] as GameStats?;
          final progress = data['progress'] as GameProgress?;

          if (stats == null || progress == null) {
            return const Center(
              child: Text(
                'Play a game to see your statistics!',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
            children: [
              _StatRow(label: 'Games Played', value: '${stats.gamesPlayed}'),
              const Divider(height: 24),
              _StatRow(label: 'Wins', value: '${stats.wins}'),
              const Divider(height: 24),
              _StatRow(label: 'Losses', value: '${stats.losses}'),
              const Divider(height: 24),
              _StatRow(label: 'Win Rate', value: '${(stats.winRate * 100).toStringAsFixed(1)}%'),
              const Divider(height: 24),
              _StatRow(label: 'Average Attempts', value: stats.averageAttempts.toStringAsFixed(1)),
              const Divider(height: 24),
              _StatRow(label: 'Fastest Solve', value: _formatDuration(stats.fastestSolve)),
              const Divider(height: 24),
              _StatRow(label: 'Current Streak', value: '${progress.streak}'),
              const Divider(height: 24),
              _StatRow(label: 'Longest Streak', value: '${progress.longestStreak}'),
              const Divider(height: 24),
              _StatRow(label: 'Total XP Earned', value: '${progress.xpEarned}'),
            ],
          );
        },
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value, 
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}