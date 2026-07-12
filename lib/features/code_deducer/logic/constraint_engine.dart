import '../models/clue.dart';

class ConstraintEngine {
  static bool evaluateClue(String candidate, Clue clue) {
    if (candidate.length != clue.guess.length) return false;

    int actualCorrectPlaced = 0;
    final List<String> unmatchedCandidate = [];
    final List<String> unmatchedGuess = [];

    for (int i = 0; i < candidate.length; i++) {
      if (candidate[i] == clue.guess[i]) {
        actualCorrectPlaced++;
      } else {
        unmatchedCandidate.add(candidate[i]);
        unmatchedGuess.add(clue.guess[i]);
      }
    }

    if (actualCorrectPlaced != clue.correctPlaced) return false;

    int actualCorrectWrongPlaced = 0;
    final Map<String, int> candidateCounts = {};
    for (final char in unmatchedCandidate) {
      candidateCounts[char] = (candidateCounts[char] ?? 0) + 1;
    }

    for (final char in unmatchedGuess) {
      final availableCount = candidateCounts[char] ?? 0;
      if (availableCount > 0) {
        actualCorrectWrongPlaced++;
        candidateCounts[char] = availableCount - 1;
      }
    }

    return actualCorrectWrongPlaced == clue.correctWrongPlaced;
  }
}