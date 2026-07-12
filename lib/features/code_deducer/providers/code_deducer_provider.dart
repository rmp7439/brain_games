import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/generator.dart';
import '../models/puzzle.dart';

enum GameStatus { playing, won, lost }

class CodeDeducerState {
  final Puzzle? puzzle;
  final GameStatus status;
  final String feedback;
  final Difficulty selectedDifficulty;

  const CodeDeducerState({
    this.puzzle,
    this.status = GameStatus.playing,
    this.feedback = '',
    this.selectedDifficulty = Difficulty.easy,
  });

  CodeDeducerState copyWith({
    Puzzle? puzzle,
    GameStatus? status,
    String? feedback,
    Difficulty? selectedDifficulty,
  }) {
    return CodeDeducerState(
      puzzle: puzzle ?? this.puzzle,
      status: status ?? this.status,
      feedback: feedback ?? this.feedback,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
    );
  }
}

class CodeDeducerNotifier extends StateNotifier<CodeDeducerState> {
  CodeDeducerNotifier() : super(const CodeDeducerState()) {
    startNewGame(Difficulty.easy);
  }

  void startNewGame(Difficulty difficulty) {
    state = CodeDeducerState(
      puzzle: null, // Triggers loading state
      selectedDifficulty: difficulty,
      feedback: 'Generating puzzle...',
    );

    // Generate puzzle synchronously for MVP, but isolated in real-world to prevent UI lock
    final puzzle = CodeDeducerGenerator.generate(difficulty);
    
    state = state.copyWith(
      puzzle: puzzle,
      status: GameStatus.playing,
      feedback: 'Crack the ${difficulty.codeLength}-digit code!',
    );
  }

  void submitGuess(String guess) {
    if (state.status != GameStatus.playing || state.puzzle == null) return;
    
    final puzzle = state.puzzle!;
    
    if (guess.length != puzzle.difficulty.codeLength) {
      state = state.copyWith(feedback: 'Code must be ${puzzle.difficulty.codeLength} digits.');
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