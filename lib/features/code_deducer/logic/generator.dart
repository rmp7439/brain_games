import 'dart:math';

import '../models/clue.dart';
import '../models/puzzle.dart';
import 'solver.dart';

/// Generates valid puzzles by randomly generating clues and proving their uniqueness.
class CodeDeducerGenerator {
  static final Random _random = Random();

  /// Generates a puzzle that is guaranteed to have exactly one solution.
  static Puzzle generate(Difficulty difficulty) {
    while (true) {
      final secretCode = _generateCode(difficulty.codeLength, difficulty.allowDuplicates);
      final List<Clue> clues = [];

      // Add clues until the puzzle has a unique solution
      for (int attempt = 0; attempt < 20; attempt++) {
        final guess = _generateCode(difficulty.codeLength, difficulty.allowDuplicates);
        
        // Prevent giving away the exact answer as a clue
        if (guess == secretCode) continue;

        clues.add(_createClue(guess, secretCode));

        final solutions = CodeDeducerSolver.solve(
          codeLength: difficulty.codeLength,
          clues: clues,
          allowDuplicates: difficulty.allowDuplicates,
        );

        if (solutions.length == 1 && solutions.first == secretCode) {
          // Uniqueness proven!
          return Puzzle(
            secretCode: secretCode,
            clues: clues,
            difficulty: difficulty,
          );
        }

        // If something went wrong and we hit 0 solutions, discard this puzzle attempt
        if (solutions.isEmpty) break;
      }
    }
  }

  static String _generateCode(int length, bool allowDuplicates) {
    String code = '';
    while (code.length < length) {
      final digit = _random.nextInt(10).toString();
      if (allowDuplicates || !code.contains(digit)) {
        code += digit;
      }
    }
    return code;
  }

  /// Calculates the exact and partial matches to create a mathematically correct clue.
  static Clue _createClue(String guess, String secretCode) {
    int exact = 0;
    List<String> unmatchedGuess = [];
    List<String> unmatchedSecret = [];

    // Exact matches
    for (int i = 0; i < guess.length; i++) {
      if (guess[i] == secretCode[i]) {
        exact++;
      } else {
        unmatchedGuess.add(guess[i]);
        unmatchedSecret.add(secretCode[i]);
      }
    }

    // Partial matches
    int partial = 0;
    for (final char in unmatchedGuess) {
      if (unmatchedSecret.contains(char)) {
        partial++;
        unmatchedSecret.remove(char); // Prevent double counting
      }
    }

    return Clue(guess: guess, correctPlaced: exact, correctWrongPlaced: partial);
  }
}