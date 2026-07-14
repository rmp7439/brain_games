import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/primary_button.dart';
import '../providers/code_deducer_provider.dart';

class DefeatScreen extends StatelessWidget {
  final CodeDeducerState state;

  const DefeatScreen({
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
                    Icons.psychology_alt, 
                    size: 96, 
                    color: theme.colorScheme.primary.withValues(alpha: 0.8),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'NICE TRY!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Every attempt makes you sharper.',
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
                      color: theme.colorScheme.error,
                    ),
                  ),
                  
                  const SizedBox(height: 64),
                  PrimaryButton(
                    text: 'TRY AGAIN',
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