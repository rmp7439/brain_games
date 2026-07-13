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
  final int guessCount; 

  const CodeDeducerState({
    this.puzzle,
    this.status = GameStatus.playing,
    this.feedback = '',
    this.selectedDifficulty = Difficulty.easy,
    this.selectedCodeLength = 3,
    this.guessCount = 0,
  });

  CodeDeducerState copyWith({
    Puzzle? puzzle,
    GameStatus? status,
    String? feedback,
    Difficulty? selectedDifficulty,
    int? selectedCodeLength,
    int? guessCount,
  }) {
    return CodeDeducerState(
      puzzle: puzzle ?? this.puzzle,
      status: status ?? this.status,
      feedback: feedback ?? this.feedback,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      selectedCodeLength: selectedCodeLength ?? this.selectedCodeLength,
      guessCount: guessCount ?? this.guessCount,
    );
  }
}

class CodeDeducerNotifier extends StateNotifier<CodeDeducerState> {
  int _currentGenerationId = 0; 

  CodeDeducerNotifier() : super(const CodeDeducerState()) {
    startNewGame(Difficulty.easy, 3);
  }

  Future<void> startNewGame(Difficulty difficulty, int codeLength) async {
    final thisGenerationId = ++_currentGenerationId;

    state = CodeDeducerState(
      puzzle: null,
      selectedDifficulty: difficulty,
      selectedCodeLength: codeLength,
      feedback: 'Generating puzzle...',
      guessCount: 0,
    );

    try {
      final puzzle = await Isolate.run(
        () => CodeDeducerGenerator.generate(
          difficulty,
          codeLength,
          allowDuplicates: false, 
        ),
      );

      // Only update state if this is still the most recently requested puzzle
      if (_currentGenerationId == thisGenerationId) {
        state = state.copyWith(
          puzzle: puzzle,
          status: GameStatus.playing,
          feedback: 'Crack the $codeLength-digit code!',
        );
      }
    } catch (e) {
      // Graceful fallback for extreme mathematical edge cases or isolate crashes
      if (_currentGenerationId == thisGenerationId) {
        state = state.copyWith(
          feedback: 'Failed to generate puzzle. Please try another difficulty.',
          status: GameStatus.lost, 
        );
      }
    }
  }

  void submitGuess(String guess) {
    final cleanGuess = guess.trim();
    
    if (state.status != GameStatus.playing || state.puzzle == null) return;
    
    final puzzle = state.puzzle!;
    
    if (cleanGuess.length != puzzle.codeLength) {
      state = state.copyWith(
        feedback: 'Code must be ${puzzle.codeLength} digits.',
        guessCount: state.guessCount + 1, 
      );
      return;
    }

    if (cleanGuess == puzzle.secretCode) {
      state = state.copyWith(
        status: GameStatus.won,
        feedback: 'Correct! The code was $cleanGuess.',
        guessCount: state.guessCount + 1,
      );
    } else {
      state = state.copyWith(
        feedback: '$cleanGuess is incorrect. Try again!',
        guessCount: state.guessCount + 1, 
      );
    }
  }
}

final codeDeducerProvider = StateNotifierProvider<CodeDeducerNotifier, CodeDeducerState>((ref) {
  return CodeDeducerNotifier();
});