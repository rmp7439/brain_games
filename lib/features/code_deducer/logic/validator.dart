import '../models/clue.dart';
import 'solver.dart';

/// The Validator proves whether a puzzle is mathematically sound.
class CodeDeducerValidator {
  /// Returns true if and only if the provided clues result in EXACTLY ONE valid solution.
  static bool hasUniqueSolution({
    required int codeLength,
    required List<Clue> clues,
    required bool allowDuplicates,
  }) {
    final solutions = CodeDeducerSolver.solve(
      codeLength: codeLength,
      clues: clues,
      allowDuplicates: allowDuplicates,
    );
    
    return solutions.length == 1;
  }
}