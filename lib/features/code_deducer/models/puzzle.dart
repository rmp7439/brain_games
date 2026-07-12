import 'package:meta/meta.dart';
import 'clue.dart';

enum Difficulty {
  easy(5),
  medium(4),
  hard(3);

  final int clueCount;

  const Difficulty(this.clueCount);
}

@immutable
class Puzzle {
  final String secretCode;
  final List<Clue> clues;
  final Difficulty difficulty;
  final int codeLength; // Explicitly decoupled from Difficulty

  const Puzzle({
    required this.secretCode,
    required this.clues,
    required this.difficulty,
    required this.codeLength,
  });
}