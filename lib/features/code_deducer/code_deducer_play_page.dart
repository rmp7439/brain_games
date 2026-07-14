import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/heart_indicator.dart';
import '../../shared/widgets/page_indicator.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/status_chip.dart';
import 'constants/game_constants.dart';
import 'providers/code_deducer_provider.dart';
import 'widgets/clue_card.dart';
import 'widgets/defeat_screen.dart';
import 'widgets/empty_history_state.dart';
import 'widgets/feedback_banner.dart';
import 'widgets/guess_history_card.dart';
import 'widgets/victory_screen.dart';

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

  void _showDefeatScreen(CodeDeducerState state) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Theme.of(context).colorScheme.surface,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => DefeatScreen(state: state),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.05),
              end: Offset.zero
            ).animate(curve),
            child: child,
          ),
        );
      },
    );
  }

  void _showVictoryScreen(CodeDeducerState state) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Theme.of(context).colorScheme.surface, 
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => VictoryScreen(state: state),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.05), 
              end: Offset.zero
            ).animate(curve),
            child: child,
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
        _showVictoryScreen(next);
      } else if (previous?.status == GameStatus.playing && next.status == GameStatus.lost) {
        _showDefeatScreen(next);
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
        duration: const Duration(milliseconds: 500),
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
          child: PageIndicator(pageController: pageController),
        ),
      ],
    );
  }
}

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
              StatusChip(
                label: state.selectedDifficulty.name.toUpperCase(),
                backgroundColor: theme.colorScheme.primaryContainer,
                textColor: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 12),
              StatusChip(
                label: '${state.selectedCodeLength} DIGITS',
                backgroundColor: theme.colorScheme.secondaryContainer,
                textColor: theme.colorScheme.onSecondaryContainer,
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
                child: ClueCard(clue: clue, index: index),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

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
          FeedbackBanner(
            status: state.status,
            feedback: state.feedback,
            guessCount: state.guessCount,
          ),
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

              return PrimaryButton(
                text: 'SUBMIT GUESS',
                onPressed: canSubmit 
                  ? () {
                      HapticFeedback.mediumImpact();
                      final guess = textController.text.trim();
                      ref.read(codeDeducerProvider.notifier).submitGuess(guess);
                      textController.clear();
                      FocusScope.of(context).unfocus();
                    } 
                  : null,
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
              HeartIndicator(
                attemptsRemaining: state.attemptsRemaining, 
                maxAttempts: CodeDeducerConstants.maxAttempts
              ),
            ],
          ),
          const Divider(height: 32),

          if (state.guessHistory.isEmpty)
            const EmptyHistoryState()
          else
            _GuessHistoryList(history: state.guessHistory),
            
          const SizedBox(height: 32),
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

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reversedHistory.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final guess = reversedHistory[index];
        final attemptNumber = history.length - index;
        
        return TweenAnimationBuilder<double>(
          key: ValueKey('${guess}_$attemptNumber'), 
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
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
          child: GuessHistoryCard(
            guess: guess, 
            attemptNumber: attemptNumber,
          ),
        );
      },
    );
  }
}