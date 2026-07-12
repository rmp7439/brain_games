import 'package:flutter/material.dart';

class GameModel {
  final String id;
  final String name;
  final IconData icon;
  final int currentRating;
  final int bestRating;
  final int gamesPlayed;
  final bool hasDailyChallenge;
  final bool isUnlocked;
  final String routePath;

  const GameModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.currentRating,
    required this.bestRating,
    required this.gamesPlayed,
    required this.hasDailyChallenge,
    required this.isUnlocked,
    required this.routePath,
  });
}