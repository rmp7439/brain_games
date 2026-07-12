import 'package:meta/meta.dart';

@immutable
class DailyChallenge {
  final bool available;
  final bool completed;
  final int rewardXP;
  final int rewardCoins;
  final DateTime expiresAt;

  const DailyChallenge({
    required this.available,
    required this.completed,
    required this.rewardXP,
    required this.rewardCoins,
    required this.expiresAt,
  });

  DailyChallenge copyWith({
    bool? available,
    bool? completed,
    int? rewardXP,
    int? rewardCoins,
    DateTime? expiresAt,
  }) {
    return DailyChallenge(
      available: available ?? this.available,
      completed: completed ?? this.completed,
      rewardXP: rewardXP ?? this.rewardXP,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyChallenge &&
        other.available == available &&
        other.completed == completed &&
        other.rewardXP == rewardXP &&
        other.rewardCoins == rewardCoins &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      available,
      completed,
      rewardXP,
      rewardCoins,
      expiresAt,
    );
  }
}