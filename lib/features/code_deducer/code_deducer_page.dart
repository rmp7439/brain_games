import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'models/puzzle.dart';
import 'providers/code_deducer_provider.dart';

/// Screen 1: Game Setup
/// A lightweight, instantly responsive screen focused purely on configuration.
class CodeDeducerSetupPage extends ConsumerWidget {
  const CodeDeducerSetupPage({super.key});

  void _onSettingChanged(WidgetRef ref, Difficulty diff, int length) {
    ref.read(codeDeducerProvider.notifier).updateSettings(diff, length);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLength = ref.watch(codeDeducerProvider.select((s) => s.selectedCodeLength));
    final selectedDiff = ref.watch(codeDeducerProvider.select((s) => s.selectedDifficulty));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Deducer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 1),
            const Text(
              'GAME SETUP',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            const Text(
              'CODE LENGTH',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            Row(
              children: [3, 4, 5].map((length) {
                return _AnimatedSelectionButton<int>(
                  value: length,
                  groupValue: selectedLength,
                  label: '$length Digits',
                  onChanged: (val) => _onSettingChanged(ref, selectedDiff, val),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            
            const Text(
              'DIFFICULTY',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            Row(
              children: Difficulty.values.map((d) {
                return _AnimatedSelectionButton<Difficulty>(
                  value: d,
                  groupValue: selectedDiff,
                  label: d.name.toUpperCase(),
                  onChanged: (val) => _onSettingChanged(ref, val, selectedLength),
                );
              }).toList(),
            ),
            const Spacer(flex: 2),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                HapticFeedback.heavyImpact();
                ref.read(codeDeducerProvider.notifier).startNewGame();
                context.go('/code_deducer/play');
              },
              child: const Text('START GAME', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _AnimatedSelectionButton<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final String label;
  final ValueChanged<T> onChanged;

  const _AnimatedSelectionButton({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final theme = Theme.of(context);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: isSelected ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha : 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (!isSelected) {
                    HapticFeedback.selectionClick();
                    onChanged(value);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      child: Text(label),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}