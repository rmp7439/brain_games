import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'constants/game_constants.dart';
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

  String _formatTime(Duration? duration) {
    if (duration == null) return '--:--';
    final m = duration.inMinutes.toString().padLeft(2, '0');
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showEndGameDialog(CodeDeducerState state, bool isWin) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha : 0.6),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(
                    isWin ? Icons.emoji_events : Icons.videogame_asset_off,
                    color: isWin ? Colors.amber : Colors.red,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isWin ? 'Congratulations!' : 'Game Over',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isWin) ...[
                    Text(
                      'The code was: ${state.puzzle?.secretCode}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _DialogStatRow(label: 'Difficulty', value: state.puzzle?.difficulty.name.toUpperCase() ?? ''),
                  _DialogStatRow(label: 'Code Length', value: '${state.puzzle?.codeLength} Digits'),
                  _DialogStatRow(label: 'Attempts Used', value: '${state.attemptsUsed}/${CodeDeducerConstants.maxAttempts}'),
                  if (isWin) _DialogStatRow(label: 'Attempts Remaining', value: '${state.attemptsRemaining}'),
                  _DialogStatRow(label: 'Completion Time', value: _formatTime(state.completionTime)),
                  if (isWin) ...[
                    const Divider(height: 24),
                    _DialogStatRow(
                      label: 'XP Earned',
                      value: '+${state.earnedXp}',
                      valueColor: Colors.green,
                      isBold: true,
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/home');
                  },
                  child: const Text('Back Home'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _textController.clear();
                    ref.read(codeDeducerProvider.notifier).startNewGame(
                      state.selectedDifficulty, 
                      state.selectedCodeLength
                    );
                  },
                  child: const Text('Play Again'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for Game End State changes to trigger subtle dialogs
    ref.listen<CodeDeducerState>(codeDeducerProvider, (previous, next) {
      if (previous?.status == GameStatus.playing && next.status == GameStatus.won) {
        _showEndGameDialog(next, true);
      } else if (previous?.status == GameStatus.playing && next.status == GameStatus.lost) {
        _showEndGameDialog(next, false);
      }
    });

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
            _SettingsHeader(textController: _textController),
            const SizedBox(height: 16),
            const Divider(),
            Expanded(
              child: _AnimatedGameBoard(textController: _textController),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogStatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _DialogStatRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsHeader extends ConsumerWidget {
  final TextEditingController textController;
  const _SettingsHeader({required this.textController});

  void _onGameChanged(WidgetRef ref, Difficulty diff, int length) {
    textController.clear();
    ref.read(codeDeducerProvider.notifier).startNewGame(diff, length);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLength = ref.watch(codeDeducerProvider.select((s) => s.selectedCodeLength));
    final selectedDiff = ref.watch(codeDeducerProvider.select((s) => s.selectedDifficulty));
    final isGenerating = ref.watch(codeDeducerProvider.select((s) => s.isGenerating));

    return IgnorePointer(
      ignoring: isGenerating,
      child: Column(
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
                onChanged: (val) => _onGameChanged(ref, selectedDiff, val),
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
                onChanged: (val) => _onGameChanged(ref, val, selectedLength),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AnimatedGameBoard extends ConsumerWidget {
  final TextEditingController textController;
  const _AnimatedGameBoard({required this.textController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(codeDeducerProvider);

    if (state.puzzle == null && state.isGenerating) {
      return const Center(
        key: ValueKey('initial_loading'),
        child: CircularProgressIndicator(),
      );
    }

    if (state.puzzle == null) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.05),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _GameBoardContent(
        key: ValueKey(state.puzzle), 
        state: state,
        textController: textController,
      ),
    );
  }
}

class _GameBoardContent extends ConsumerWidget {
  final CodeDeducerState state;
  final TextEditingController textController;

  const _GameBoardContent({
    super.key,
    required this.state,
    required this.textController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: state.isGenerating ? 0.4 : 1.0,
      child: IgnorePointer(
        ignoring: state.isGenerating || state.status != GameStatus.playing,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListView.builder(
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(), 
                itemCount: state.puzzle!.clues.length,
                itemBuilder: (context, index) {
                  final clue = state.puzzle!.clues[index];
                  return _StaggeredClueCard(clue: clue, index: index);
                },
              ),
              const SizedBox(height: 16),
              
              // Hearts Display UI
              _HeartsDisplay(
                attemptsRemaining: state.attemptsRemaining, 
                maxAttempts: CodeDeducerConstants.maxAttempts
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                maxLength: state.puzzle!.codeLength,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  labelText: 'Enter ${state.puzzle!.codeLength}-digit code',
                  filled: true,
                  counterText: '', 
                ),
                enabled: state.status == GameStatus.playing && !state.isGenerating,
              ),
              const SizedBox(height: 16),
              
              // Dynamically enable/disable submit button strictly based on length & state
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: textController,
                builder: (context, value, child) {
                  final isValidLength = value.text.length == state.puzzle!.codeLength;
                  final isPlaying = state.status == GameStatus.playing;
                  final canSubmit = isValidLength && isPlaying && !state.isGenerating;

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: canSubmit ? () {
                      HapticFeedback.mediumImpact();
                      final guess = textController.text.trim();
                      ref.read(codeDeducerProvider.notifier).submitGuess(guess);
                      textController.clear();
                      FocusScope.of(context).unfocus();
                    } : null,
                    child: const Text('Submit Guess', style: TextStyle(fontSize: 16)),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeartsDisplay extends StatelessWidget {
  final int attemptsRemaining;
  final int maxAttempts;

  const _HeartsDisplay({required this.attemptsRemaining, required this.maxAttempts});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxAttempts, (index) {
        final isFull = index < attemptsRemaining;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Icon(
              isFull ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isFull),
              color: isFull ? Colors.red : Colors.grey.shade400,
              size: 32,
            ),
          ),
        );
      }),
    );
  }
}

class _StaggeredClueCard extends StatelessWidget {
  final Clue clue;
  final int index;

  const _StaggeredClueCard({required this.clue, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(clue.guess),
      tween: Tween(begin: 0.0, end: 1.0),
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
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
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