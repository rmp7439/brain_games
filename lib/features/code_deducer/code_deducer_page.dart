import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'models/puzzle.dart';
import 'models/clue.dart';
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
            _buildSettingsHeader(),
            const SizedBox(height: 16),
            const Divider(),
            Expanded(
              child: _buildAnimatedGameBoard(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the settings header utilizing `.select` to prevent unnecessary 
  /// rebuilds when the puzzle state changes.
  Widget _buildSettingsHeader() {
    // Only watch the specific settings values
    final selectedLength = ref.watch(codeDeducerProvider.select((s) => s.selectedCodeLength));
    final selectedDiff = ref.watch(codeDeducerProvider.select((s) => s.selectedDifficulty));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'CODE LENGTH',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Row(
          children: [3, 4, 5].map((length) {
            return _AnimatedSelectionButton<int>(
              value: length,
              groupValue: selectedLength,
              label: '$length Digits',
              onChanged: (val) => _onGameChanged(selectedDiff, val),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'DIFFICULTY',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Row(
          children: Difficulty.values.map((d) {
            return _AnimatedSelectionButton<Difficulty>(
              value: d,
              groupValue: selectedDiff,
              label: d.name.toUpperCase(),
              onChanged: (val) => _onGameChanged(val, selectedLength),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Builds the game board with a custom Fade + Slide transition.
  Widget _buildAnimatedGameBoard() {
    final state = ref.watch(codeDeducerProvider);
    final notifier = ref.read(codeDeducerProvider.notifier);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.05), // Slight slide up
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: state.puzzle == null
          ? const Center(
              key: ValueKey('loading'),
              child: CircularProgressIndicator(),
            )
          : _GameBoardContent(
              key: ValueKey(state.puzzle!.secretCode), // Unique key to force transition on new puzzle
              state: state,
              notifier: notifier,
              textController: _textController,
              onPlayAgain: () => _onGameChanged(state.selectedDifficulty, state.selectedCodeLength),
            ),
    );
  }
}

/// Extracted game board content to keep the widget tree clean.
class _GameBoardContent extends StatelessWidget {
  final CodeDeducerState state;
  final CodeDeducerNotifier notifier;
  final TextEditingController textController;
  final VoidCallback onPlayAgain;

  const _GameBoardContent({
    super.key,
    required this.state,
    required this.notifier,
    required this.textController,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Wrap the Column in a SingleChildScrollView so it can scroll when the keyboard opens
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 2. Remove the Expanded wrapper from the ListView
          ListView.builder(
            shrinkWrap: true, // 3. Allow the list to size to its children
            physics: const NeverScrollableScrollPhysics(), // Scroll is handled by the parent SingleChildScrollView
            itemCount: state.puzzle!.clues.length,
            itemBuilder: (context, index) {
              final clue = state.puzzle!.clues[index];
              return _StaggeredClueCard(clue: clue, index: index);
            },
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
            controller: textController,
            keyboardType: TextInputType.number,
            maxLength: state.puzzle!.codeLength,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      notifier.submitGuess(textController.text);
                      textController.clear();
                    },
                    child: const Text('Submit Guess', style: TextStyle(fontSize: 16)),
                  )
                : ElevatedButton(
                    key: const ValueKey('play_again'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onPlayAgain();
                    },
                    child: const Text('Play Again', style: TextStyle(fontSize: 16)),
                  ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Beautifully fades and slides in clue cards sequentially based on their index.
class _StaggeredClueCard extends StatelessWidget {
  final Clue clue;
  final int index;

  const _StaggeredClueCard({required this.clue, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(clue.guess),
      tween: Tween(begin: 0.0, end: 1.0),
      // Adding a slight mathematical delay based on index for the staggered effect
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
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
      ),
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