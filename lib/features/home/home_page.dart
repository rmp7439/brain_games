import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/game_card.dart';
import 'providers/home_provider.dart';
import 'widgets/daily_challenge_card.dart';
import 'widgets/profile_summary.dart';
import 'widgets/section_header.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeStateAsync = ref.watch(homeProvider);

    return Scaffold(
      body: homeStateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (state) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(state.greeting, style: const TextStyle(fontWeight: FontWeight.bold)),
                floating: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    
                    // Profile Summary
                    ProfileSummary(
                      level: state.overallLevel,
                      xp: state.overallXP,
                      totalGames: state.totalGamesPlayed,
                    ),
                    const SizedBox(height: 16.0),

                    // Daily Challenge Section
                    if (state.dailyChallenge != null) ...[
                      const SectionHeader(title: 'Daily Challenge'),
                      DailyChallengeCard(
                        gameName: state.dailyChallenge!.gameName,
                        rewardXP: state.dailyChallenge!.challenge.rewardXP,
                        rewardCoins: state.dailyChallenge!.challenge.rewardCoins,
                        onTap: () => context.go('/${state.dailyChallenge!.gameId}'),
                      ),
                      const SizedBox(height: 16.0),
                    ],

                    // Continue Playing Section
                    if (state.continuePlaying != null) ...[
                      const SectionHeader(title: 'Continue Playing'),
                      GameCard(
                        data: state.continuePlaying!,
                        onTap: () => context.go('/${state.continuePlaying!.id}'),
                      ),
                      const SizedBox(height: 16.0),
                    ],

                    // Recent Activity Section
                    if (state.recentGames.isNotEmpty) ...[
                      const SectionHeader(title: 'Recent Activity'),
                      _buildResponsiveGrid(context, state.recentGames),
                      const SizedBox(height: 16.0),
                    ],

                    // All Games Section
                    const SectionHeader(title: 'All Games'),
                    _buildResponsiveGrid(context, state.allGames),
                    const SizedBox(height: 32.0),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds a responsive grid that works seamlessly on mobile, tablet, and desktop
  Widget _buildResponsiveGrid(BuildContext context, List<GameCardData> games) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate cross axis count based on screen width
        int crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: crossAxisCount == 1 ? 2.5 : 2.0,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            mainAxisExtent: 140, // Fixed height for cards to prevent overflow
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            return GameCard(
              data: games[index],
              onTap: () => context.go('/${games[index].id}'),
            );
          },
        );
      },
    );
  }
}