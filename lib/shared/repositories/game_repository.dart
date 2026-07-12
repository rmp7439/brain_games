import '../models/daily_challenge.dart';
import '../models/game_info.dart';
import '../models/game_progress.dart';
import '../models/game_stats.dart';

abstract class GameRepository {
  /// Retrieves all available games.
  Future<List<GameInfo>> getAllGames();

  /// Retrieves a specific game by its ID.
  Future<GameInfo?> getGame(String id);

  /// Retrieves the player's stats for a specific game.
  Future<GameStats?> getGameStats(String gameId);

  /// Updates the player's stats for a specific game.
  Future<void> updateGameStats(String gameId, GameStats stats);

  /// Retrieves the daily challenge for a specific game.
  Future<DailyChallenge?> getDailyChallenge(String gameId);

  /// Updates the player's progress for a specific game.
  Future<void> updateGameProgress(String gameId, GameProgress progress);
}