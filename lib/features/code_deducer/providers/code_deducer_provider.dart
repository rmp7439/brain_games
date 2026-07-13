import 'dart:isolate';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/game_constants.dart';
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
  
  // Player State Extensions
  final int attemptsRemaining;
  final int attemptsUsed;
  final DateTime? startTime;
  final DateTime? endTime;
  final int earnedXp;

  const CodeDeducerState({
    this.puzzle,
    this.status = GameStatus.playing,
    this.feedback = '',
    this.selectedDifficulty = Difficulty.easy,
    this.selectedCodeLength = 3,
    this.guessCount = 0,
    this.isGenerating = false,
    this.attemptsRemaining = CodeDeducerConstants.maxAttempts,
    this.attemptsUsed = 0,
    this.startTime,
    this.endTime,
    this.earnedXp = 0,
  });

  // Getters for external statistics tracking
  Duration? get completionTime => (startTime != null && endTime != null) ? endTime!.difference(startTime!) : null;
  bool get isGameOver => status == GameStatus.lost;
  bool get isSolved => status == GameStatus.won;

  CodeDeducerState copyWith({
    Puzzle? puzzle,
    GameStatus? status,
    String? feedback,
    Difficulty? selectedDifficulty,
    int? selectedCodeLength,
    int? guessCount,
    bool? isGenerating,
    int? attemptsRemaining,
    int? attemptsUsed,
    DateTime? startTime,
    DateTime? endTime,
    int? earnedXp,
  }) {
    return CodeDeducerState(
      puzzle: puzzle ?? this.puzzle,
      status: status ?? this.status,
      feedback: feedback ?? this.feedback,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      selectedCodeLength: selectedCodeLength ?? this.selectedCodeLength,
      guessCount: guessCount ?? this.guessCount,
      isGenerating: isGenerating ?? this.isGenerating,
      attemptsRemaining: attemptsRemaining ?? this.attemptsRemaining,
      attemptsUsed: attemptsUsed ?? this.attemptsUsed,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      earnedXp: earnedXp ?? this.earnedXp,
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
        state = CodeDeducerState(
          puzzle: puzzle,
          status: GameStatus.playing,
          feedback: 'Crack the $codeLength-digit code!',
          selectedDifficulty: difficulty,
          selectedCodeLength: codeLength,
          guessCount: 0,
          isGenerating: false,
          attemptsRemaining: CodeDeducerConstants.maxAttempts,
          attemptsUsed: 0,
          startTime: DateTime.now(), 
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
    
    // Safety check: input must be strictly valid to count as an attempt
    if (state.status != GameStatus.playing || state.puzzle == null || state.isGenerating) return;
    final puzzle = state.puzzle!;
    if (cleanGuess.length != puzzle.codeLength) return;

    final currentAttempt = state.attemptsUsed + 1;

    if (cleanGuess == puzzle.secretCode) {
      // Victory
      final xp = CodeDeducerConstants.calculateXp(puzzle.difficulty, currentAttempt);
      state = state.copyWith(
        status: GameStatus.won,
        feedback: 'Correct! The code was $cleanGuess.',
        guessCount: state.guessCount + 1,
        attemptsUsed: currentAttempt,
        endTime: DateTime.now(),
        earnedXp: xp,
      );
    } else {
      // Incorrect valid guess
      final remaining = state.attemptsRemaining - 1;
      
      if (remaining <= 0) {
        // Game Over
        state = state.copyWith(
          status: GameStatus.lost,
          feedback: 'Game Over! The code was ${puzzle.secretCode}.',
          guessCount: state.guessCount + 1,
          attemptsRemaining: 0,
          attemptsUsed: currentAttempt,
          endTime: DateTime.now(),
          earnedXp: 0,
        );
      } else {
        // Continue Playing
        state = state.copyWith(
          feedback: '$cleanGuess is incorrect. Try again!',
          guessCount: state.guessCount + 1,
          attemptsRemaining: remaining,
          attemptsUsed: currentAttempt,
        );
      }
    }
  }
}

final codeDeducerProvider = StateNotifierProvider<CodeDeducerNotifier, CodeDeducerState>((ref) {
  return CodeDeducerNotifier();
});