import 'package:meta/meta.dart';

@immutable
class GameProgress {
  final bool unlocked;
  final bool completedTutorial;
  final int currentLevel;
  final int xpEarned;
  final int streak;

  const GameProgress({
    required this.unlocked,
    required this.completedTutorial,
    required this.currentLevel,
    required this.xpEarned,
    required this.streak,
  });

  GameProgress copyWith({
    bool? unlocked,
    bool? completedTutorial,
    int? currentLevel,
    int? xpEarned,
    int? streak,
  }) {
    return GameProgress(
      unlocked: unlocked ?? this.unlocked,
      completedTutorial: completedTutorial ?? this.completedTutorial,
      currentLevel: currentLevel ?? this.currentLevel,
      xpEarned: xpEarned ?? this.xpEarned,
      streak: streak ?? this.streak,
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
        other.streak == streak;
  }

  @override
  int get hashCode {
    return Object.hash(
      unlocked,
      completedTutorial,
      currentLevel,
      xpEarned,
      streak,
    );
  }
}