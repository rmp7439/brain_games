import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/game_model.dart';

final gamesProvider = Provider<List<GameModel>>((ref) {
  return const [
    GameModel(
      id: 'quiz',
      name: 'Quiz',
      icon: Icons.lightbulb_outline,
      currentRating: 1200,
      bestRating: 1350,
      gamesPlayed: 42,
      hasDailyChallenge: true,
      isUnlocked: true,
      routePath: '/quiz',
    ),
    GameModel(
      id: 'code_breaker',
      name: 'Code Breaker',
      icon: Icons.password,
      currentRating: 950,
      bestRating: 1050,
      gamesPlayed: 15,
      hasDailyChallenge: false,
      isUnlocked: true,
      routePath: '/code_breaker',
    ),
    GameModel(
      id: 'chess_puzzle',
      name: 'Chess Puzzle',
      icon: Icons.extension,
      currentRating: 0,
      bestRating: 0,
      gamesPlayed: 0,
      hasDailyChallenge: true,
      isUnlocked: false,
      routePath: '/chess_puzzle',
    ),
  ];
});