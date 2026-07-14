import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'constants/game_constants.dart';
import 'models/clue.dart';
import 'providers/code_deducer_provider.dart';

class CodeDeducerPlayPage extends ConsumerStatefulWidget {
  const CodeDeducerPlayPage({super.key});

  @override
  ConsumerState<CodeDeducerPlayPage> createState() => _CodeDeducerPlayPageState();
}

class _CodeDeducerPlayPageState extends ConsumerState<CodeDeducerPlayPage> {
  late TextEditingController _textController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
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
      barrierColor: Colors.black.withValues(alpha: 0.6),
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
                    context.pop(); 
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
          onPressed: () => context.pop(), 
        ),
      ),
      body: AnimatedSwitcher(
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
                pageController: _pageController,
              ),
      ),
    );
  }
}

class _GameBoardContent extends ConsumerWidget {
  final CodeDeducerState state;
  final TextEditingController textController;
  final PageController pageController;

  const _GameBoardContent({
    super.key,
    required this.state,
    required this.textController,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: pageController,
            physics: const BouncingScrollPhysics(),
            children: [
              _CluesPage(state: state),
              _GuessPage(state: state, textController: textController),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0, top: 12.0),
          child: _PageIndicator(pageController: pageController),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// CLUES PAGE (Preserved from Phase 2)
// -----------------------------------------------------------------------------

class _CluesPage extends StatelessWidget {
  final CodeDeducerState state;

  const _CluesPage({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Chip(
                label: Text(state.selectedDifficulty.name.toUpperCase()),
                backgroundColor: theme.colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
                side: BorderSide.none,
              ),
              const SizedBox(width: 12),
              Chip(
                label: Text('${state.selectedCodeLength} DIGITS'),
                backgroundColor: theme.colorScheme.secondaryContainer,
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
                side: BorderSide.none,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Every clue is true.\nUse logic to uncover the secret code.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 48),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.puzzle!.clues.length,
            itemBuilder: (context, index) {
              final clue = state.puzzle!.clues[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _StaggeredClueCard(clue: clue, index: index),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StaggeredClueCard extends StatelessWidget {
  final Clue clue;
  final int index;

  const _StaggeredClueCard({required this.clue, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.02),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                clue.guess,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4.0,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                clue.type.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// GUESS PAGE (Redesigned for Phase 3)
// -----------------------------------------------------------------------------

class _GuessPage extends ConsumerWidget {
  final CodeDeducerState state;
  final TextEditingController textController;

  const _GuessPage({required this.state, required this.textController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FeedbackBanner(state: state),
          const SizedBox(height: 32),
          
          TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            maxLength: state.puzzle!.codeLength,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 8.0,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'ENTER ${state.puzzle!.codeLength} DIGITS',
              labelStyle: const TextStyle(letterSpacing: 2.0),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              counterText: '', 
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary, 
                  width: 2,
                ),
              ),
            ),
            enabled: state.status == GameStatus.playing,
          ),
          const SizedBox(height: 24),
          
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: textController,
            builder: (context, value, child) {
              final isValidLength = value.text.length == state.puzzle!.codeLength;
              final isPlaying = state.status == GameStatus.playing;
              final canSubmit = isValidLength && isPlaying;

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(64),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: canSubmit ? 4 : 0,
                ),
                onPressed: canSubmit ? () {
                  HapticFeedback.mediumImpact();
                  final guess = textController.text.trim();
                  ref.read(codeDeducerProvider.notifier).submitGuess(guess);
                  textController.clear();
                  FocusScope.of(context).unfocus();
                } : null,
                child: const Text('SUBMIT GUESS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              );
            },
          ),
          const SizedBox(height: 48),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'ATTEMPTS',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              _HeartsDisplay(
                attemptsRemaining: state.attemptsRemaining, 
                maxAttempts: CodeDeducerConstants.maxAttempts
              ),
            ],
          ),
          const Divider(height: 32),

          if (state.guessHistory.isEmpty)
            const _EmptyHistoryState()
          else
            _GuessHistoryList(history: state.guessHistory),
            
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  final CodeDeducerState state;
  const _FeedbackBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlaying = state.status == GameStatus.playing;
    final isWon = state.status == GameStatus.won;
    
    Color bgColor = theme.colorScheme.surfaceContainerHighest;
    Color fgColor = theme.colorScheme.onSurfaceVariant;
    
    if (!isPlaying) {
      bgColor = isWon ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1);
      fgColor = isWon ? Colors.green.shade700 : Colors.red.shade700;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            state.feedback.isEmpty ? 'Ready for your first guess.' : state.feedback,
            key: ValueKey('${state.feedback}_${state.guessCount}'),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: fgColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Column(
        children: [
          Icon(
            Icons.history, 
            size: 48, 
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No guesses yet.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your history will appear here.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuessHistoryList extends StatelessWidget {
  final List<String> history;
  const _GuessHistoryList({required this.history});

  @override
  Widget build(BuildContext context) {
    // Reverse history to show latest guess at the top of the list
    final reversedHistory = history.reversed.toList();
    final theme = Theme.of(context);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reversedHistory.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final guess = reversedHistory[index];
        final attemptNumber = history.length - index;
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ]
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                foregroundColor: theme.colorScheme.onSurfaceVariant,
                child: Text(
                  '$attemptNumber', 
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  guess,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4.0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxAttempts, (index) {
        final isFull = index < attemptsRemaining;
        return Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Icon(
              isFull ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isFull),
              color: isFull ? Colors.red : Colors.grey.shade400,
              size: 24, // Sized down to cleanly fit the new Attempts header
            ),
          ),
        );
      }),
    );
  }
}

// -----------------------------------------------------------------------------
// SHARED WIDGETS
// -----------------------------------------------------------------------------

class _PageIndicator extends StatelessWidget {
  final PageController pageController;

  const _PageIndicator({required this.pageController});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: pageController,
      builder: (context, child) {
        final page = pageController.hasClients ? (pageController.page ?? 0.0) : 0.0;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDot(context, page, 0),
            const SizedBox(width: 8),
            _buildDot(context, page, 1),
          ],
        );
      },
    );
  }

  Widget _buildDot(BuildContext context, double currentPage, int index) {
    final isActive = (currentPage.round() == index);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
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