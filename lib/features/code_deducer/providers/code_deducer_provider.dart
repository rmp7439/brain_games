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
  
  final int attemptsRemaining;
  final int attemptsUsed;
  final DateTime? startTime;
  final DateTime? endTime;
  final int earnedXp;
  
  // ADDED: Track previous guesses for the new UI flow
  final List<String> guessHistory;

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
    this.guessHistory = const [],
  });

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
    List<String>? guessHistory,
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
      guessHistory: guessHistory ?? this.guessHistory,
    );
  }
}

class CodeDeducerNotifier extends StateNotifier<CodeDeducerState> {
  int _currentGenerationId = 0; 

  CodeDeducerNotifier() : super(const CodeDeducerState());

  void updateSettings(Difficulty difficulty, int codeLength) {
    state = state.copyWith(
      selectedDifficulty: difficulty,
      selectedCodeLength: codeLength,
    );
  }

  Future<void> startNewGame() async {
    final thisGenerationId = ++_currentGenerationId;
    final diff = state.selectedDifficulty;
    final length = state.selectedCodeLength;

    state = state.copyWith(
      isGenerating: true, 
      feedback: 'Generating puzzle...',
      puzzle: null, 
      status: GameStatus.playing,
    );

    try {
      final puzzle = await Isolate.run(
        () => CodeDeducerGenerator.generate(
          diff,
          length,
          allowDuplicates: false, 
        ),
      );

      if (_currentGenerationId == thisGenerationId) {
        state = CodeDeducerState(
          puzzle: puzzle,
          status: GameStatus.playing,
          feedback: 'Crack the $length-digit code!',
          selectedDifficulty: diff,
          selectedCodeLength: length,
          guessCount: 0,
          isGenerating: false,
          attemptsRemaining: CodeDeducerConstants.maxAttempts,
          attemptsUsed: 0,
          startTime: DateTime.now(), 
          guessHistory: const [], // Reset history on new game
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
    if (cleanGuess.length != puzzle.codeLength) return;

    final currentAttempt = state.attemptsUsed + 1;
    final newGuessHistory = List<String>.from(state.guessHistory)..add(cleanGuess);

    if (cleanGuess == puzzle.secretCode) {
      final xp = CodeDeducerConstants.calculateXp(puzzle.difficulty, currentAttempt);
      state = state.copyWith(
        status: GameStatus.won,
        feedback: 'Correct! The code was $cleanGuess.',
        guessCount: state.guessCount + 1,
        attemptsUsed: currentAttempt,
        endTime: DateTime.now(),
        earnedXp: xp,
        guessHistory: newGuessHistory,
      );
    } else {
      final remaining = state.attemptsRemaining - 1;
      
      if (remaining <= 0) {
        state = state.copyWith(
          status: GameStatus.lost,
          feedback: 'Game Over! The code was ${puzzle.secretCode}.',
          guessCount: state.guessCount + 1,
          attemptsRemaining: 0,
          attemptsUsed: currentAttempt,
          endTime: DateTime.now(),
          earnedXp: 0,
          guessHistory: newGuessHistory,
        );
      } else {
        state = state.copyWith(
          feedback: '$cleanGuess is incorrect. Try again!',
          guessCount: state.guessCount + 1,
          attemptsRemaining: remaining,
          attemptsUsed: currentAttempt,
          guessHistory: newGuessHistory,
        );
      }
    }
  }
}

final codeDeducerProvider = StateNotifierProvider<CodeDeducerNotifier, CodeDeducerState>((ref) {
  return CodeDeducerNotifier();
});