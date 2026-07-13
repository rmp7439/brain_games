import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'constants/game_constants.dart';
import 'models/clue.dart';
import 'providers/code_deducer_provider.dart';

/// Screen 2: Puzzle Screen
/// Completely dedicated to the gameplay experience, removing all setup clutter.
class CodeDeducerPlayPage extends ConsumerStatefulWidget {
  const CodeDeducerPlayPage({super.key});

  @override
  ConsumerState<CodeDeducerPlayPage> createState() => _CodeDeducerPlayPageState();
}

class _CodeDeducerPlayPageState extends ConsumerState<CodeDeducerPlayPage> {
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
                  _DialogStatRow(label: 'Difficulty', value: state.selectedDifficulty.name.toUpperCase()),
                  _DialogStatRow(label: 'Code Length', value: '${state.selectedCodeLength} Digits'),
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
                    context.pop(); // Pop back to Setup Screen with preserved state
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
    final state = ref.watch(codeDeducerProvider);

    ref.listen<CodeDeducerState>(codeDeducerProvider, (previous, next) {
      if (previous?.status == GameStatus.playing && next.status == GameStatus.won) {
        _showEndGameDialog(next, true);
      } else if (previous?.status == GameStatus.playing && next.status == GameStatus.lost) {
        _showEndGameDialog(next, false);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Code Deducer', style: TextStyle(fontSize: 18)),
            Text(
              '${state.selectedDifficulty.name.toUpperCase()} • ${state.selectedCodeLength} DIGITS',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(), // Pop safely back to setup
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: (state.puzzle == null || state.isGenerating)
              ? const Center(
                  key: ValueKey('loading'),
                  child: CircularProgressIndicator(),
                )
              : _GameBoardContent(
                  key: ValueKey(state.puzzle),
                  state: state,
                  textController: _textController,
                ),
        ),
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
    return SingleChildScrollView(
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
          const SizedBox(height: 24),
          
          _HeartsDisplay(
            attemptsRemaining: state.attemptsRemaining, 
            maxAttempts: CodeDeducerConstants.maxAttempts
          ),
          const SizedBox(height: 16),
          
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              state.feedback,
              key: ValueKey('${state.feedback}_${state.guessCount}'), 
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
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              labelText: 'Enter ${state.puzzle!.codeLength}-digit code',
              filled: true,
              counterText: '', 
            ),
            enabled: state.status == GameStatus.playing,
          ),
          const SizedBox(height: 16),
          
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: textController,
            builder: (context, value, child) {
              final isValidLength = value.text.length == state.puzzle!.codeLength;
              final isPlaying = state.status == GameStatus.playing;
              final canSubmit = isValidLength && isPlaying;

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: canSubmit ? () {
                  HapticFeedback.mediumImpact();
                  final guess = textController.text.trim();
                  ref.read(codeDeducerProvider.notifier).submitGuess(guess);
                  textController.clear();
                  FocusScope.of(context).unfocus();
                } : null,
                child: const Text('SUBMIT GUESS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
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
              size: 36,
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
              fontSize: 22,
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