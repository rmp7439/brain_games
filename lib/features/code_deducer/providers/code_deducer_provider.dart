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
  final bool isGenerating;

  const CodeDeducerState({
    this.puzzle,
    this.status = GameStatus.playing,
    this.feedback = '',
    this.selectedDifficulty = Difficulty.easy,
    this.selectedCodeLength = 3,
    this.guessCount = 0,
    this.isGenerating = false,
  });

  CodeDeducerState copyWith({
    Puzzle? puzzle,
    GameStatus? status,
    String? feedback,
    Difficulty? selectedDifficulty,
    int? selectedCodeLength,
    int? guessCount,
    bool? isGenerating,
  }) {
    return CodeDeducerState(
      puzzle: puzzle ?? this.puzzle,
      status: status ?? this.status,
      feedback: feedback ?? this.feedback,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      selectedCodeLength: selectedCodeLength ?? this.selectedCodeLength,
      guessCount: guessCount ?? this.guessCount,
      isGenerating: isGenerating ?? this.isGenerating,
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

    // Acknowledge tap immediately without dropping the current puzzle
    state = state.copyWith(
      selectedDifficulty: difficulty,
      selectedCodeLength: codeLength,
      isGenerating: true, 
      feedback: 'Generating puzzle...',
    );

    try {
      final puzzle = await Isolate.run(
        () => CodeDeducerGenerator.generate(
          difficulty,
          codeLength,
          allowDuplicates: false, 
        ),
      );

      if (_currentGenerationId == thisGenerationId) {
        // Build a fresh state to reset the board completely
        state = CodeDeducerState(
          puzzle: puzzle,
          status: GameStatus.playing,
          feedback: 'Crack the $codeLength-digit code!',
          selectedDifficulty: difficulty,
          selectedCodeLength: codeLength,
          guessCount: 0,
          isGenerating: false,
        );
      }
    } catch (e) {
      if (_currentGenerationId == thisGenerationId) {
        state = state.copyWith(
          feedback: 'Failed to generate puzzle. Try again.',
          status: GameStatus.lost,
          isGenerating: false,
        );
      }
    }
  }

  void submitGuess(String guess) {
    final cleanGuess = guess.trim();
    
    if (state.status != GameStatus.playing || state.puzzle == null || state.isGenerating) return;
    
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