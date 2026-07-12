import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/daily_challenge.dart';
import '../../../shared/models/game_card_data.dart';
import '../../../shared/providers/repository_providers.dart';

import '../../../shared/models/game_stats.dart';
import '../../../shared/models/game_progress.dart';

class HomeDailyChallenge {
  final String gameName;
  final String gameId;
  final DailyChallenge challenge;

  const HomeDailyChallenge({
    required this.gameName,
    required this.gameId,
    required this.challenge,
  });
}

class HomeState {
  final String greeting;
  final int overallXP;
  final int overallLevel;
  final int totalGamesPlayed;
  final HomeDailyChallenge? dailyChallenge;
  final GameCardData? continuePlaying;
  final List<GameCardData> recentGames;
  final List<GameCardData> allGames;

  const HomeState({
    this.greeting = '',
    this.overallXP = 0,
    this.overallLevel = 1,
    this.totalGamesPlayed = 0,
    this.dailyChallenge,
    this.continuePlaying,
    this.recentGames = const [],
    this.allGames = const [],
  });
}

class HomeNotifier extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final repository = ref.watch(gameRepositoryProvider);
    final allGameInfos = await repository.getAllGames();

    int totalGamesPlayed = 0;
    int overallXP = 0;
    
    final List<GameCardData> allGames = [];
    final List<GameCardData> recentGames = [];
    
    GameCardData? continuePlaying;
    HomeDailyChallenge? activeDailyChallenge;

    for (final info in allGameInfos) {
      final stats = await repository.getGameStats(info.id);
      final progress = await repository.getGameProgress(info.id);
      final challenge = await repository.getDailyChallenge(info.id);

      final hasDailyBadge = challenge != null && challenge.available && !challenge.completed;
      final safeStats = stats ?? const GameStats(gamesPlayed: 0, wins: 0, losses: 0, winRate: 0, bestScore: 0, currentRating: 0, highestRating: 0, totalPlayTime: Duration.zero);
      final safeProgress = progress ?? const GameProgress(unlocked: false, completedTutorial: false, currentLevel: 1, xpEarned: 0, streak: 0);

      totalGamesPlayed += safeStats.gamesPlayed;
      overallXP += safeProgress.xpEarned;

      final cardData = GameCardData(
        id: info.id,
        name: info.name,
        icon: info.icon,
        rating: safeStats.currentRating,
        gamesPlayed: safeStats.gamesPlayed,
        bestScore: safeStats.bestScore,
        hasDailyBadge: hasDailyBadge,
        xp: safeProgress.xpEarned,
        isUnlocked: safeProgress.unlocked,
      );

      allGames.add(cardData);

      if (safeStats.gamesPlayed > 0) {
        recentGames.add(cardData);
        continuePlaying ??= cardData; 
      }

      if (hasDailyBadge && activeDailyChallenge == null) {
        activeDailyChallenge = HomeDailyChallenge(
          gameName: info.name,
          gameId: info.id,
          challenge: challenge,
        );
      }
    }

    // Default 'Continue Playing' if no games played yet
    continuePlaying ??= allGames.isNotEmpty ? allGames.first : null;

    return HomeState(
      greeting: _generateGreeting(),
      overallXP: overallXP,
      overallLevel: (overallXP / 1000).floor() + 1,
      totalGamesPlayed: totalGamesPlayed,
      dailyChallenge: activeDailyChallenge,
      continuePlaying: continuePlaying,
      recentGames: recentGames,
      allGames: allGames,
    );
  }

  String _generateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }
}

final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});