import 'package:meta/meta.dart';

@immutable
class GameCardData {
  final String id;
  final String name;
  final String icon;
  final int rating;
  final int gamesPlayed;
  final int bestScore;
  final bool hasDailyBadge;
  final int xp;
  final bool isUnlocked;

  const GameCardData({
    required this.id,
    required this.name,
    required this.icon,
    required this.rating,
    required this.gamesPlayed,
    required this.bestScore,
    required this.hasDailyBadge,
    required this.xp,
    required this.isUnlocked,
  });
}