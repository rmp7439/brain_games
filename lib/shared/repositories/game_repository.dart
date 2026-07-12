import '../models/daily_challenge.dart';
import '../models/game_info.dart';
import '../models/game_progress.dart';
import '../models/game_stats.dart';

abstract class GameRepository {
  Future<List<GameInfo>> getAllGames();
  Future<GameInfo?> getGame(String id);
  Future<GameStats?> getGameStats(String gameId);
  Future<void> updateGameStats(String gameId, GameStats stats);
  Future<DailyChallenge?> getDailyChallenge(String gameId);
  
  /// Added to retrieve the progress to calculate overall XP
  Future<GameProgress?> getGameProgress(String gameId); 
  
  Future<void> updateGameProgress(String gameId, GameProgress progress);
}