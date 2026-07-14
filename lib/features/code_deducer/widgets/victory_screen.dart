import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/primary_button.dart';
import '../constants/game_constants.dart';
import '../providers/code_deducer_provider.dart';

class VictoryScreen extends StatelessWidget {
  final CodeDeducerState state;

  const VictoryScreen({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.emoji_events, 
                    size: 96, 
                    color: Colors.amber.shade500,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'CONGRATULATIONS!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You cracked the code.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  _StatBox(
                    label: 'SECRET CODE',
                    value: state.puzzle?.secretCode ?? '',
                    valueStyle: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8.0,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _XpBreakdownCard(state: state),
                  const SizedBox(height: 32),
                  
                  _LevelProgressSection(
                    beforeXp: state.totalXpBefore, 
                    afterXp: state.totalXpAfter,
                  ),
                  const SizedBox(height: 48),
                  
                  PrimaryButton(
                    text: 'PLAY AGAIN',
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.pop(); 
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(64),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/home');
                    },
                    child: Text(
                      'BACK TO HOME', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 1.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      )
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _XpBreakdownCard extends StatelessWidget {
  final CodeDeducerState state;

  const _XpBreakdownCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseXP = CodeDeducerConstants.getBaseXp(state.selectedDifficulty);
    final bonusXP = state.earnedXp - baseXP;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'XP BREAKDOWN',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _AnimatedBreakdownRow(label: 'Base XP', value: baseXP),
          const SizedBox(height: 12),
          _AnimatedBreakdownRow(label: 'Attempt Bonus', value: bonusXP),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(),
          ),
          _AnimatedBreakdownRow(
            label: 'Total Earned', 
            value: state.earnedXp, 
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _AnimatedBreakdownRow extends StatelessWidget {
  final String label;
  final int value;
  final bool isTotal;

  const _AnimatedBreakdownRow({
    required this.label, 
    required this.value, 
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = isTotal 
      ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green)
      : theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500);
      
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        TweenAnimationBuilder<int>(
          tween: Tween<int>(begin: 0, end: value),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutCubic,
          builder: (context, val, child) {
            return Text('+$val', style: textStyle);
          },
        ),
      ],
    );
  }
}

class _LevelProgressSection extends StatelessWidget {
  final int? beforeXp;
  final int? afterXp;

  const _LevelProgressSection({required this.beforeXp, required this.afterXp});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (beforeXp == null || afterXp == null) {
      return const SizedBox(
        height: 72, 
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final startLevel = (beforeXp! ~/ 1000) + 1;
    final endLevel = (afterXp! ~/ 1000) + 1;
    final leveledUp = endLevel > startLevel;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: beforeXp!.toDouble(), end: afterXp!.toDouble()),
      duration: const Duration(milliseconds: 2000),
      curve: Curves.easeInOutCubic,
      builder: (context, currentXp, child) {
        final level = (currentXp ~/ 1000) + 1;
        final progress = (currentXp % 1000) / 1000.0;
        final isCurrentlyLevelingUp = leveledUp && level == endLevel;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LEVEL $level', 
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: isCurrentlyLevelingUp ? Colors.amber.shade600 : theme.colorScheme.primary,
                  )
                ),
                if (isCurrentlyLevelingUp)
                  Text(
                    'LEVEL UP!', 
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Colors.amber.shade600,
                    )
                  ),
                Text(
                  '${(currentXp % 1000).toInt()} / 1000 XP', 
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  )
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                isCurrentlyLevelingUp ? Colors.amber.shade500 : theme.colorScheme.primary
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _StatBox({
    required this.label, 
    required this.value, 
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}