import 'package:meta/meta.dart';

@immutable
class GameProgress {
  final bool unlocked;
  final bool completedTutorial;
  final int currentLevel;
  final int xpEarned;
  final int streak;
  final int longestStreak;

  const GameProgress({
    required this.unlocked,
    required this.completedTutorial,
    required this.currentLevel,
    required this.xpEarned,
    required this.streak,
    required this.longestStreak,
  });

  GameProgress copyWith({
    bool? unlocked,
    bool? completedTutorial,
    int? currentLevel,
    int? xpEarned,
    int? streak,
    int? longestStreak,
  }) {
    return GameProgress(
      unlocked: unlocked ?? this.unlocked,
      completedTutorial: completedTutorial ?? this.completedTutorial,
      currentLevel: currentLevel ?? this.currentLevel,
      xpEarned: xpEarned ?? this.xpEarned,
      streak: streak ?? this.streak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameProgress &&
        other.unlocked == unlocked &&
        other.completedTutorial == completedTutorial &&
        other.currentLevel == currentLevel &&
        other.xpEarned == xpEarned &&
        other.streak == streak &&
        other.longestStreak == longestStreak;
  }

  @override
  int get hashCode {
    return Object.hash(
      unlocked,
      completedTutorial,
      currentLevel,
      xpEarned,
      streak,
      longestStreak,
    );
  }
}