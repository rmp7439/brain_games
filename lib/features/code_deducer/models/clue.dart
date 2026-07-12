import 'package:meta/meta.dart';

enum ClueType {
  nothing(0, 0, 'No digit is in the code.'),
  oneMisplaced(0, 1, 'One digit is correct but wrongly placed.'),
  twoMisplaced(0, 2, 'Two digits are correct but wrongly placed.'),
  oneCorrect(1, 0, 'One digit is correctly placed.'),
  twoCorrect(2, 0, 'Two digits are correctly placed.');

  final int exact;
  final int partial;
  final String description;

  const ClueType(this.exact, this.partial, this.description);

  /// Returns the corresponding ClueType, or null if the combination is not allowed.
  static ClueType? fromMatches(int exact, int partial) {
    for (final type in values) {
      if (type.exact == exact && type.partial == partial) return type;
    }
    return null;
  }
}

@immutable
class Clue {
  final String guess;
  final int correctPlaced;
  final int correctWrongPlaced;
  final ClueType type; // Added semantic type

  const Clue({
    required this.guess,
    required this.correctPlaced,
    required this.correctWrongPlaced,
    required this.type,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Clue &&
        other.guess == guess &&
        other.correctPlaced == correctPlaced &&
        other.correctWrongPlaced == correctWrongPlaced &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(guess, correctPlaced, correctWrongPlaced, type);
}