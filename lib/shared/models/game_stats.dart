import 'package:meta/meta.dart';

@immutable
class GameStats {
  final int gamesPlayed;
  final int wins;
  final int losses;
  final double winRate;
  final int bestScore;
  final int currentRating;
  final int highestRating;
  final Duration totalPlayTime;

  const GameStats({
    required this.gamesPlayed,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.bestScore,
    required this.currentRating,
    required this.highestRating,
    required this.totalPlayTime,
  });

  GameStats copyWith({
    int? gamesPlayed,
    int? wins,
    int? losses,
    double? winRate,
    int? bestScore,
    int? currentRating,
    int? highestRating,
    Duration? totalPlayTime,
  }) {
    return GameStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      winRate: winRate ?? this.winRate,
      bestScore: bestScore ?? this.bestScore,
      currentRating: currentRating ?? this.currentRating,
      highestRating: highestRating ?? this.highestRating,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameStats &&
        other.gamesPlayed == gamesPlayed &&
        other.wins == wins &&
        other.losses == losses &&
        other.winRate == winRate &&
        other.bestScore == bestScore &&
        other.currentRating == currentRating &&
        other.highestRating == highestRating &&
        other.totalPlayTime == totalPlayTime;
  }

  @override
  int get hashCode {
    return Object.hash(
      gamesPlayed,
      wins,
      losses,
      winRate,
      bestScore,
      currentRating,
      highestRating,
      totalPlayTime,
    );
  }
}