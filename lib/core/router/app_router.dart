import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/achievements/achievements_page.dart';
import '../../features/home/home_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/statistics/statistics_page.dart';
import '../../shared/widgets/scaffold_with_nav_bar.dart';

import '../../features/code_deducer/code_deducer_page.dart';
import '../../features/code_deducer/code_deducer_play_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/home', builder: (context, state) => const HomePage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/statistics',
                builder: (context, state) => const StatisticsPage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/achievements',
                builder: (context, state) => const AchievementsPage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage())
          ]),
        ],
      ),
      // Code Deducer Game Flow
      GoRoute(
        path: '/code_deducer',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CodeDeducerSetupPage(),
        routes: [
          GoRoute(
            path: 'play',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const CodeDeducerPlayPage(),
          ),
        ],
      ),
    ],
  );
});