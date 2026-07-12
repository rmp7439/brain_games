import '../models/daily_challenge.dart';
import '../models/game_info.dart';
import '../models/game_progress.dart';
import '../models/game_stats.dart';
import 'game_repository.dart';

class MockGameRepository implements GameRepository {
  final Map<String, GameInfo> _games = {
    'code_deducer': const GameInfo(
      id: 'code_deducer',
      name: 'Code Deducer',
      description: 'Crack the hidden numeric code using pure logic.',
      icon: 'psychology',
      difficulty: 'Varies',
      category: 'Logic',
      enabled: true,
    ),
  };

  final Map<String, GameStats> _stats = {};

  final Map<String, GameProgress> _progress = {
    'code_deducer': const GameProgress(
      unlocked: true,
      completedTutorial: false,
      currentLevel: 1,
      xpEarned: 0,
      streak: 0,
    ),
  };

  final Map<String, DailyChallenge> _challenges = {
    'code_deducer': DailyChallenge(
      available: true,
      completed: false,
      rewardXP: 100,
      rewardCoins: 50,
      expiresAt: DateTime.now().add(const Duration(hours: 12)),
    ),
  };

  @override
  Future<List<GameInfo>> getAllGames() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _games.values.toList();
  }

  @override
  Future<GameInfo?> getGame(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _games[id];
  }

  @override
  Future<GameStats?> getGameStats(String gameId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _stats[gameId] ??
        const GameStats(
          gamesPlayed: 0,
          wins: 0,
          losses: 0,
          winRate: 0.0,
          bestScore: 0,
          currentRating: 0,
          highestRating: 0,
          totalPlayTime: Duration.zero,
        );
  }

  @override
  Future<void> updateGameStats(String gameId, GameStats stats) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _stats[gameId] = stats;
  }

  @override
  Future<DailyChallenge?> getDailyChallenge(String gameId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _challenges[gameId];
  }

  @override
  Future<GameProgress?> getGameProgress(String gameId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _progress[gameId] ??
        const GameProgress(
          unlocked: true,
          completedTutorial: false,
          currentLevel: 1,
          xpEarned: 0,
          streak: 0,
        );
  }

  @override
  Future<void> updateGameProgress(String gameId, GameProgress progress) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _progress[gameId] = progress;
  }
}
