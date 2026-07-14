import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/../shared/widgets/primary_button.dart';
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
      backgroundColor: Colors.transparent, // Inherits the theme barrierColor from showGeneralDialog
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
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
              
              // Secret Code Box
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
              
              // Attempts & XP Row
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      label: 'ATTEMPTS',
                      value: '${state.attemptsUsed}',
                      valueStyle: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatBox(
                      label: 'XP EARNED',
                      value: '+${state.earnedXp}',
                      valueStyle: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              PrimaryButton(
                text: 'PLAY AGAIN',
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pop(); // Return to game setup
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