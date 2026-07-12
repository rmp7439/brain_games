import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'models/puzzle.dart';
import 'providers/code_deducer_provider.dart';

class CodeDeducerPage extends ConsumerStatefulWidget {
  const CodeDeducerPage({super.key});

  @override
  ConsumerState<CodeDeducerPage> createState() => _CodeDeducerPageState();
}

class _CodeDeducerPageState extends ConsumerState<CodeDeducerPage> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onGameChanged(Difficulty diff, int length) {
    _textController.clear();
    ref.read(codeDeducerProvider.notifier).startNewGame(diff, length);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(codeDeducerProvider);
    final notifier = ref.read(codeDeducerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Deducer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stable Header Area: Code Length Selection
            const Text(
              'CODE LENGTH',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _AnimatedSelectionButton<int>(
                  value: 3,
                  groupValue: state.selectedCodeLength,
                  label: '3 Digits',
                  onChanged: (val) => _onGameChanged(state.selectedDifficulty, val),
                ),
                _AnimatedSelectionButton<int>(
                  value: 4,
                  groupValue: state.selectedCodeLength,
                  label: '4 Digits',
                  onChanged: (val) => _onGameChanged(state.selectedDifficulty, val),
                ),
                _AnimatedSelectionButton<int>(
                  value: 5,
                  groupValue: state.selectedCodeLength,
                  label: '5 Digits',
                  onChanged: (val) => _onGameChanged(state.selectedDifficulty, val),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stable Header Area: Difficulty Selection
            const Text(
              'DIFFICULTY',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            Row(
              children: Difficulty.values.map((d) {
                return _AnimatedSelectionButton<Difficulty>(
                  value: d,
                  groupValue: state.selectedDifficulty,
                  label: d.name.toUpperCase(),
                  onChanged: (val) => _onGameChanged(val, state.selectedCodeLength),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(),

            // Animated Game Board Area
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                // Key forces the switcher to animate when the puzzle changes
                child: state.puzzle == null
                    ? const Center(
                        key: ValueKey('loading'),
                        child: CircularProgressIndicator(),
                      )
                    : _buildGameBoard(state, notifier),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameBoard(CodeDeducerState state, CodeDeducerNotifier notifier) {
    return Column(
      key: ValueKey(state.puzzle!.secretCode), // Unique key per puzzle
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: state.puzzle!.clues.length,
            itemBuilder: (context, index) {
              final clue = state.puzzle!.clues[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  leading: Text(
                    clue.guess,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  title: Text(clue.type.description),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            state.feedback,
            key: ValueKey(state.feedback),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: state.status == GameStatus.won ? Colors.green : Colors.red,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _textController,
          keyboardType: TextInputType.number,
          maxLength: state.puzzle!.codeLength,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            labelText: 'Enter ${state.puzzle!.codeLength}-digit code',
            filled: true,
          ),
          enabled: state.status == GameStatus.playing,
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state.status == GameStatus.playing
              ? ElevatedButton(
                  key: const ValueKey('submit'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => notifier.submitGuess(_textController.text),
                  child: const Text('Submit Guess', style: TextStyle(fontSize: 16)),
                )
              : ElevatedButton(
                  key: const ValueKey('play_again'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _onGameChanged(state.selectedDifficulty, state.selectedCodeLength),
                  child: const Text('Play Again', style: TextStyle(fontSize: 16)),
                ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// A custom button that animates its background, text style, scale, and shadow when selected.
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
          tween: Tween(begin: 1.0, end: isSelected ? 1.03 : 1.0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
                onTap: () => onChanged(value),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
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