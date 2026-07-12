import 'dart:isolate';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/generator.dart';
import '../models/puzzle.dart';

enum GameStatus { playing, won, lost }

class CodeDeducerState {
  final Puzzle? puzzle;
  final GameStatus status;
  final String feedback;
  final Difficulty selectedDifficulty;
  final int selectedCodeLength;

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

  /// Starts a new game by immediately updating the UI state, then offloading
  /// the heavy mathematical puzzle generation to a background isolate.
  Future<void> startNewGame(Difficulty difficulty, int codeLength) async {
    // 1. Instantly yield state to the UI.
    // The puzzle becomes null, allowing the AnimatedSwitcher to transition 
    // to a loading state while the setting chips animate instantly.
    state = CodeDeducerState(
      puzzle: null,
      selectedDifficulty: difficulty,
      selectedCodeLength: codeLength,
      feedback: 'Generating puzzle...',
    );

    // 2. Offload the heavy generation to a background thread.
    // This entirely frees the main UI thread, eliminating all perceived lag.
    final puzzle = await Isolate.run(
      () => CodeDeducerGenerator.generate(
        difficulty,
        codeLength,
        allowDuplicates: false, // Defaulting to classic deduction rules
      ),
    );

    // 3. Race-Condition Safeguard.
    // If the user rapidly tapped settings while a puzzle was generating, 
    // discard this result if it no longer matches the currently desired state.
    if (state.selectedDifficulty == difficulty && state.selectedCodeLength == codeLength) {
      state = state.copyWith(
        puzzle: puzzle,
        status: GameStatus.playing,
        feedback: 'Crack the $codeLength-digit code!',
      );
    }
  }

  void submitGuess(String guess) {
    // 1. Sanitize input to prevent invisible spaces from failing the length validation
    final cleanGuess = guess.trim();
    
    if (state.status != GameStatus.playing || state.puzzle == null) return;
    
    final puzzle = state.puzzle!;
    
    if (cleanGuess.length != puzzle.codeLength) {
      state = state.copyWith(feedback: 'Code must be ${puzzle.codeLength} digits.');
      return;
    }

    // 2. Evaluate the win condition
    if (cleanGuess == puzzle.secretCode) {
      state = state.copyWith(
        status: GameStatus.won,
        feedback: 'Correct! The code was $cleanGuess.',
      );
    } else {
      // 3. Guarantee a unique feedback string so AnimatedSwitcher ALWAYS detects a change
      state = state.copyWith(
        feedback: '$cleanGuess is incorrect. Try again!',
      );
    }
  }
}

final codeDeducerProvider = StateNotifierProvider<CodeDeducerNotifier, CodeDeducerState>((ref) {
  return CodeDeducerNotifier();
});