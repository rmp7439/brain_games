import 'dart:math';

import '../models/clue.dart';
import 'constraint_engine.dart';

/// The Solver performs an exhaustive mathematical search to find every possible 
/// code that satisfies a given set of clues.
class CodeDeducerSolver {
  
  /// Evaluates all possible combinations for a given [codeLength] and 
  /// returns a list of every code that perfectly matches all [clues].
  /// 
  /// If [allowDuplicates] is false, candidates containing repeating digits 
  /// (e.g., "112") will be filtered out before evaluation.
  static List<String> solve({
    required int codeLength,
    required List<Clue> clues,
    bool allowDuplicates = true,
  }) {
    if (codeLength < 3 || codeLength > 5) {
      throw ArgumentError('Code length must be between 3 and 5.');
    }

    final List<String> validSolutions = [];
    final int maxCombinations = pow(10, codeLength).toInt();

    for (int i = 0; i < maxCombinations; i++) {
      // Pad the integer to ensure leading zeros are preserved.
      final String candidate = i.toString().padLeft(codeLength, '0');

      // Filter out repeating digits if the rules forbid them.
      if (!allowDuplicates && _hasDuplicates(candidate)) {
        continue;
      }

      bool satisfiesAllClues = true;

      // Evaluate against the constraint engine.
      for (final clue in clues) {
        if (!ConstraintEngine.evaluateClue(candidate, clue)) {
          satisfiesAllClues = false;
          break; // Short-circuit: clue failed, skip remaining clues
        }
      }

      if (satisfiesAllClues) {
        validSolutions.add(candidate);
      }
    }

    return validSolutions;
  }

  /// Highly optimized bitmask check to determine if a string contains duplicate digits.
  /// Avoids unnecessary object allocations (like Sets) during the hot loop.
  static bool _hasDuplicates(String s) {
    int seen = 0;
    for (int i = 0; i < s.length; i++) {
      // 48 is the ASCII offset for '0'
      final int bit = 1 << (s.codeUnitAt(i) - 48);
      if ((seen & bit) != 0) {
        return true; 
      }
      seen |= bit;
    }
    return false;
  }
}