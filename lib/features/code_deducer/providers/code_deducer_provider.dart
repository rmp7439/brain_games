import 'dart:isolate';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/game_progress.dart';
import '../../../shared/models/game_stats.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/repositories/game_repository.dart';
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

  Duration? get completionTime => (startTime != null && endTime != null)
      ? endTime!.difference(startTime!)
      : null;
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
  final GameRepository repository;
  int _currentGenerationId = 0;

  CodeDeducerNotifier({required this.repository})
      : super(const CodeDeducerState());

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
          guessHistory: const [],
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

    if (state.status != GameStatus.playing ||
        state.puzzle == null ||
        state.isGenerating) {
      return;
    }
    
    final puzzle = state.puzzle!;
    if (cleanGuess.length != puzzle.codeLength) return;

    final currentAttempt = state.attemptsUsed + 1;
    final newGuessHistory = List<String>.from(state.guessHistory)
      ..add(cleanGuess);

    if (cleanGuess == puzzle.secretCode) {
      final xp =
          CodeDeducerConstants.calculateXp(puzzle.difficulty, currentAttempt);
      final endTime = DateTime.now();

      state = state.copyWith(
        status: GameStatus.won,
        feedback: 'Correct! The code was $cleanGuess.',
        guessCount: state.guessCount + 1,
        attemptsUsed: currentAttempt,
        endTime: endTime,
        earnedXp: xp,
        guessHistory: newGuessHistory,
      );

      _updatePersistence(true, currentAttempt, state.completionTime, xp);
    } else {
      final remaining = state.attemptsRemaining - 1;

      if (remaining <= 0) {
        final endTime = DateTime.now();
        state = state.copyWith(
          status: GameStatus.lost,
          feedback: 'Game Over! The code was ${puzzle.secretCode}.',
          guessCount: state.guessCount + 1,
          attemptsRemaining: 0,
          attemptsUsed: currentAttempt,
          endTime: endTime,
          earnedXp: 0,
          guessHistory: newGuessHistory,
        );

        _updatePersistence(false, currentAttempt, state.completionTime, 0);
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

  Future<void> _updatePersistence(
      bool isWin, int attempts, Duration? timeTaken, int xpEarned) async {
    try {
      const gameId = 'code_deducer';
      final stats = await repository.getGameStats(gameId);
      final progress = await repository.getGameProgress(gameId);

      final currentStats = stats ??
          const GameStats(
            gamesPlayed: 0,
            wins: 0,
            losses: 0,
            winRate: 0.0,
            bestScore: 0,
            currentRating: 0,
            highestRating: 0,
            totalPlayTime: Duration.zero,
            averageAttempts: 0.0,
            fastestSolve: null,
          );

      final currentProgress = progress ??
          const GameProgress(
            unlocked: true,
            completedTutorial: false,
            currentLevel: 1,
            xpEarned: 0,
            streak: 0,
            longestStreak: 0,
          );

      final gamesPlayed = currentStats.gamesPlayed + 1;
      final wins = currentStats.wins + (isWin ? 1 : 0);
      final losses = currentStats.losses + (isWin ? 0 : 1);
      final winRate = gamesPlayed > 0 ? wins / gamesPlayed : 0.0;

      final double newAvgAttempts =
          ((currentStats.averageAttempts * currentStats.gamesPlayed) +
                  attempts) /
              gamesPlayed;

      Duration? newFastestSolve = currentStats.fastestSolve;
      if (isWin && timeTaken != null) {
        if (newFastestSolve == null || timeTaken < newFastestSolve) {
          newFastestSolve = timeTaken;
        }
      }

      final totalPlayTime =
          currentStats.totalPlayTime + (timeTaken ?? Duration.zero);

      final newStats = currentStats.copyWith(
        gamesPlayed: gamesPlayed,
        wins: wins,
        losses: losses,
        winRate: winRate,
        averageAttempts: newAvgAttempts,
        fastestSolve: newFastestSolve,
        totalPlayTime: totalPlayTime,
      );

      final currentStreak = isWin ? currentProgress.streak + 1 : 0;
      final longestStreak = currentStreak > currentProgress.longestStreak
          ? currentStreak
          : currentProgress.longestStreak;
      final newXp = currentProgress.xpEarned + xpEarned;

      final newProgress = currentProgress.copyWith(
        streak: currentStreak,
        longestStreak: longestStreak,
        xpEarned: newXp,
      );

      await repository.updateGameStats(gameId, newStats);
      await repository.updateGameProgress(gameId, newProgress);
    } catch (e) {
      // Intentionally ignoring persistent layer exceptions to protect active UI experience
    }
  }
}

final codeDeducerProvider =
    StateNotifierProvider<CodeDeducerNotifier, CodeDeducerState>((ref) {
  final repository = ref.watch(gameRepositoryProvider);
  return CodeDeducerNotifier(repository: repository);
});
