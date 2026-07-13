import '../models/puzzle.dart';

class CodeDeducerConstants {
  static const int maxAttempts = 5;

  static int getBaseXp(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 100;
      case Difficulty.medium:
        return 150;
      case Difficulty.hard:
        return 225;
    }
  }

  static double getAttemptBonusMultiplier(int attemptsUsed) {
    switch (attemptsUsed) {
      case 1:
        return 1.00; // +100%
      case 2:
        return 0.75; // +75%
      case 3:
        return 0.50; // +50%
      case 4:
        return 0.25; // +25%
      case 5:
        return 0.00; // +0%
      default:
        return 0.00;
    }
  }

  static int calculateXp(Difficulty difficulty, int attemptsUsed) {
    if (attemptsUsed < 1 || attemptsUsed > maxAttempts) return 0;
    
    final int base = getBaseXp(difficulty);
    final double bonus = base * getAttemptBonusMultiplier(attemptsUsed);
    
    return (base + bonus).round();
  }
}