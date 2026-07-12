import 'dart:math';

import '../models/clue.dart';
import '../models/puzzle.dart';
import 'solver.dart';

class CodeDeducerGenerator {
  static final Random _random = Random();

  /// Generates a puzzle with exactly [Difficulty.clueCount] clues and a single unique solution.
  static Puzzle generate(Difficulty difficulty, int codeLength, {bool allowDuplicates = false}) {
    while (true) {
      final secretCode = _generateCode(codeLength, allowDuplicates);
      final List<Clue> clues = [];
      int loopSafeguard = 0;

      // 1. Gather exactly the required number of strictly valid clues
      while (clues.length < difficulty.clueCount && loopSafeguard < 1000) {
        loopSafeguard++;
        final guess = _generateCode(codeLength, allowDuplicates);
        
        if (guess == secretCode) continue;
        if (clues.any((c) => c.guess == guess)) continue; // Prevent duplicates

        final clue = _createClue(guess, secretCode);
        
        // Discard any clue that doesn't fall into the 5 allowed natural language types
        if (clue == null) continue;

        clues.add(clue);
      }

      // If we couldn't find enough valid clues, restart puzzle generation
      if (clues.length < difficulty.clueCount) continue;

      // 2. Run the solver to verify uniqueness
      final solutions = CodeDeducerSolver.solve(
        codeLength: codeLength,
        clues: clues,
        allowDuplicates: allowDuplicates,
      );

      // 3. Publish only if mathematically perfect
      if (solutions.length == 1 && solutions.first == secretCode) {
        return Puzzle(
          secretCode: secretCode,
          clues: clues,
          difficulty: difficulty,
          codeLength: codeLength,
        );
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

  static Clue? _createClue(String guess, String secretCode) {
    int exact = 0;
    List<String> unmatchedGuess = [];
    List<String> unmatchedSecret = [];

    for (int i = 0; i < guess.length; i++) {
      if (guess[i] == secretCode[i]) {
        exact++;
      } else {
        unmatchedGuess.add(guess[i]);
        unmatchedSecret.add(secretCode[i]);
      }
    }

    int partial = 0;
    for (final char in unmatchedGuess) {
      if (unmatchedSecret.contains(char)) {
        partial++;
        unmatchedSecret.remove(char); // Prevent double counting
      }
    }

    // Map internal counters to the allowed public clue types
    final type = ClueType.fromMatches(exact, partial);
    
    // Reject invalid combinations entirely
    if (type == null) return null;

    return Clue(
      guess: guess, 
      correctPlaced: exact, 
      correctWrongPlaced: partial,
      type: type, // Attach semantic type for UI
    );
  }
}