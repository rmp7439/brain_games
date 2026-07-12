import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/daily_challenge.dart';
import '../../../shared/models/game_info.dart';
import '../../../shared/providers/repository_providers.dart';

/// A wrapper to easily pair a game with its active challenge in the UI
class HomeDailyChallenge {
  final GameInfo game;
  final DailyChallenge challenge;

  const HomeDailyChallenge({
    required this.game,
    required this.challenge,
  });
}

/// The unified state object that holds everything the Home screen needs
class HomeState {
  final List<GameInfo> featuredGames;
  final GameInfo? continuePlaying;
  final HomeDailyChallenge? dailyChallenge;
  final List<GameInfo> recentGames;
  final int overallXP;
  final int overallLevel;
  final int totalGamesPlayed;

  const HomeState({
    this.featuredGames = const [],
    this.continuePlaying,
    this.dailyChallenge,
    this.recentGames = const [],
    this.overallXP = 0,
    this.overallLevel = 1,
    this.totalGamesPlayed = 0,
  });

  HomeState copyWith({
    List<GameInfo>? featuredGames,
    GameInfo? continuePlaying,
    HomeDailyChallenge? dailyChallenge,
    List<GameInfo>? recentGames,
    int? overallXP,
    int? overallLevel,
    int? totalGamesPlayed,
  }) {
    return HomeState(
      featuredGames: featuredGames ?? this.featuredGames,
      continuePlaying: continuePlaying ?? this.continuePlaying,
      dailyChallenge: dailyChallenge ?? this.dailyChallenge,
      recentGames: recentGames ?? this.recentGames,
      overallXP: overallXP ?? this.overallXP,
      overallLevel: overallLevel ?? this.overallLevel,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
    );
  }
}

/// The AsyncNotifier that builds and exposes the HomeState
class HomeNotifier extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final repository = ref.watch(gameRepositoryProvider);
    final allGames = await repository.getAllGames();

    int totalGamesPlayed = 0;
    int overallXP = 0;
    GameInfo? continuePlaying;
    HomeDailyChallenge? activeDailyChallenge;
    final List<GameInfo> recentGames = [];

    // Aggregate data from all available games
    for (final game in allGames) {
      final stats = await repository.getGameStats(game.id);
      final progress = await repository.getGameProgress(game.id);
      final challenge = await repository.getDailyChallenge(game.id);

      if (stats != null) {
        totalGamesPlayed += stats.gamesPlayed;
        if (stats.gamesPlayed > 0) {
          recentGames.add(game);
          // Set the first played game as the "Continue Playing" target
          continuePlaying ??= game; 
        }
      }

      if (progress != null) {
        overallXP += progress.xpEarned;
      }

      if (challenge != null && challenge.available && !challenge.completed) {
        // Find the first active challenge
        activeDailyChallenge ??= HomeDailyChallenge(game: game, challenge: challenge);
      }
    }

    // Calculate level (e.g., 1000 XP per level)
    final overallLevel = (overallXP / 1000).floor() + 1;

    return HomeState(
      // Mock featured logic: games with Medium or Hard difficulty
      featuredGames: allGames.where((g) => g.difficulty == 'Medium' || g.difficulty == 'Hard').toList(),
      continuePlaying: continuePlaying ?? (allGames.isNotEmpty ? allGames.first : null),
      dailyChallenge: activeDailyChallenge,
      recentGames: recentGames.isEmpty ? allGames : recentGames,
      overallXP: overallXP,
      overallLevel: overallLevel,
      totalGamesPlayed: totalGamesPlayed,
    );
  }
}

/// The provider to be watched by the Home screen UI
final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});