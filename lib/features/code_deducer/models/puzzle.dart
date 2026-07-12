import 'package:meta/meta.dart';
import 'clue.dart';

enum Difficulty {
  easy(3, false),
  medium(4, false),
  hard(5, true);

  final int codeLength;
  final bool allowDuplicates;

  const Difficulty(this.codeLength, this.allowDuplicates);
}

@immutable
class Puzzle {
  final String secretCode;
  final List<Clue> clues;
  final Difficulty difficulty;

  const Puzzle({
    required this.secretCode,
    required this.clues,
    required this.difficulty,
  });
}