import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/game_model.dart';

final gamesProvider = Provider<List<GameModel>>((ref) {
  return const [
    GameModel(
      id: 'code_deducer',
      name: 'Code Deducer',
      icon: Icons.psychology,
      currentRating: 0,
      bestRating: 0,
      gamesPlayed: 0,
      hasDailyChallenge: true,
      isUnlocked: true,
      routePath: '/code_deducer',
    ),
  ];
});