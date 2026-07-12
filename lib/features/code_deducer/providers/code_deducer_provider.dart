import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/generator.dart';
import '../models/puzzle.dart';

enum GameStatus { playing, won, lost }

class CodeDeducerState {
  final Puzzle? puzzle;
  final GameStatus status;
  final String feedback;
  final Difficulty selectedDifficulty;
  final int selectedCodeLength; // Added independent length state

  const CodeDeducerState({
    this.puzzle,
    this.status = GameStatus.playing,
    this.feedback = '',
    this.selectedDifficulty = Difficulty.easy,
    this.selectedCodeLength = 3,
  });

  CodeDeducerState copyWith({
    Puzzle? puzzle,
    GameStatus? status,
    String? feedback,
    Difficulty? selectedDifficulty,
    int? selectedCodeLength,
  }) {
    return CodeDeducerState(
      puzzle: puzzle ?? this.puzzle,
      status: status ?? this.status,
      feedback: feedback ?? this.feedback,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      selectedCodeLength: selectedCodeLength ?? this.selectedCodeLength,
    );
  }
}

class CodeDeducerNotifier extends StateNotifier<CodeDeducerState> {
  CodeDeducerNotifier() : super(const CodeDeducerState()) {
    startNewGame(Difficulty.easy, 3);
  }

  void startNewGame(Difficulty difficulty, int codeLength) {
    state = CodeDeducerState(
      puzzle: null,
      selectedDifficulty: difficulty,
      selectedCodeLength: codeLength,
      feedback: 'Generating puzzle...',
    );

    // Defaulting allowDuplicates to false per classic deduction rules
    final puzzle = CodeDeducerGenerator.generate(difficulty, codeLength, allowDuplicates: false);
    
    state = state.copyWith(
      puzzle: puzzle,
      status: GameStatus.playing,
      feedback: 'Crack the $codeLength-digit code!',
    );
  }

  void submitGuess(String guess) {
    if (state.status != GameStatus.playing || state.puzzle == null) return;
    
    final puzzle = state.puzzle!;
    
    if (guess.length != puzzle.codeLength) {
      state = state.copyWith(feedback: 'Code must be ${puzzle.codeLength} digits.');
      return;
    }

    if (guess == puzzle.secretCode) {
      state = state.copyWith(
        status: GameStatus.won,
        feedback: 'Correct! The code was $guess.',
      );
    } else {
      state = state.copyWith(
        feedback: 'Incorrect. Try again!',
      );
    }
  }
}

final codeDeducerProvider = StateNotifierProvider<CodeDeducerNotifier, CodeDeducerState>((ref) {
  return CodeDeducerNotifier();
});