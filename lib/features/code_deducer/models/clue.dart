import 'package:meta/meta.dart';

@immutable
class Clue {
  final String guess;
  final int correctPlaced;
  final int correctWrongPlaced;

  const Clue({
    required this.guess,
    required this.correctPlaced,
    required this.correctWrongPlaced,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Clue &&
        other.guess == guess &&
        other.correctPlaced == correctPlaced &&
        other.correctWrongPlaced == correctWrongPlaced;
  }

  @override
  int get hashCode => Object.hash(guess, correctPlaced, correctWrongPlaced);
}