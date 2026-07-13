import '../models/clue.dart';

class ConstraintEngine {
  static bool evaluateClue(String candidate, Clue clue) {
    if (candidate.length != clue.guess.length) return false;

    int actualExact = 0;
    // Fixed-length primitive arrays eliminate costly Map allocations in the hot loop
    final List<int> candidateCounts = List.filled(10, 0);
    final List<int> guessCounts = List.filled(10, 0);

    for (int i = 0; i < candidate.length; i++) {
      // Using codeUnitAt is exponentially faster than string indexing in Dart
      final int cUnit = candidate.codeUnitAt(i) - 48; // '0' is ASCII 48
      final int gUnit = clue.guess.codeUnitAt(i) - 48;

      if (cUnit == gUnit) {
        actualExact++;
      } else {
        candidateCounts[cUnit]++;
        guessCounts[gUnit]++;
      }
    }

    if (actualExact != clue.correctPlaced) return false;

    int actualPartial = 0;
    for (int i = 0; i < 10; i++) {
      final int cCount = candidateCounts[i];
      final int gCount = guessCounts[i];
      // Faster than math.min
      actualPartial += (cCount < gCount) ? cCount : gCount;
    }

    return actualPartial == clue.correctWrongPlaced;
  }
}