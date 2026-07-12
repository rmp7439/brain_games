import 'package:flutter_test/flutter_test.dart';
import 'package:brain_games/features/code_deducer/models/clue.dart';
import 'package:brain_games/features/code_deducer/logic/solver.dart';

void main() {
  group('CodeDeducerSolver', () {
    test('returns exact unique solution for a valid 3-digit puzzle', () {
      final clues = [
        const Clue(guess: '682', correctPlaced: 1, correctWrongPlaced: 0, type: ClueType.oneCorrect),
        const Clue(guess: '614', correctPlaced: 0, correctWrongPlaced: 1, type: ClueType.oneMisplaced),
        const Clue(guess: '206', correctPlaced: 0, correctWrongPlaced: 2, type: ClueType.twoMisplaced),
        const Clue(guess: '738', correctPlaced: 0, correctWrongPlaced: 0, type: ClueType.nothing),
        const Clue(guess: '380', correctPlaced: 0, correctWrongPlaced: 1, type: ClueType.oneMisplaced),
      ];

      final solutions = CodeDeducerSolver.solve(
        codeLength: 3,
        clues: clues,
        allowDuplicates: false,
      );

      expect(solutions, ['042']);
    });

    test('returns multiple solutions if clues are ambiguous', () {
      final clues = [
        const Clue(guess: '123', correctPlaced: 1, correctWrongPlaced: 0, type: ClueType.oneCorrect),
      ];

      final solutions = CodeDeducerSolver.solve(
        codeLength: 3,
        clues: clues,
        allowDuplicates: false,
      );

      expect(solutions.length, greaterThan(1));
      expect(solutions.contains('145'), isTrue);
      expect(solutions.contains('156'), isTrue);
      expect(solutions.contains('123'), isFalse); 
    });

    test('returns empty list for conflicting clues (zero solutions)', () {
      final clues = [
        const Clue(guess: '123', correctPlaced: 1, correctWrongPlaced: 0, type: ClueType.oneCorrect),
        const Clue(guess: '123', correctPlaced: 0, correctWrongPlaced: 0, type: ClueType.nothing),
      ];

      final solutions = CodeDeducerSolver.solve(
        codeLength: 3,
        clues: clues,
      );

      expect(solutions, isEmpty);
    });

    test('handles 4-digit codes with duplicates enabled', () {
      final clues = [
        const Clue(guess: '1122', correctPlaced: 2, correctWrongPlaced: 0, type: ClueType.twoCorrect),
      ];

      final solutions = CodeDeducerSolver.solve(
        codeLength: 4,
        clues: clues,
        allowDuplicates: true,
      );

      expect(solutions.contains('1122'), isTrue);
    });

    test('filters out duplicate solutions if duplicates are disabled', () {
      final solutions = CodeDeducerSolver.solve(
        codeLength: 3,
        clues: [],
        allowDuplicates: false,
      );

      expect(solutions.length, 720);
      expect(solutions.contains('012'), isTrue);
      expect(solutions.contains('112'), isFalse);
    });

    test('throws ArgumentError if code length is unsupported', () {
      expect(
        () => CodeDeducerSolver.solve(codeLength: 2, clues: []),
        throwsArgumentError,
      );
      
      expect(
        () => CodeDeducerSolver.solve(codeLength: 6, clues: []),
        throwsArgumentError,
      );
    });
  });
}