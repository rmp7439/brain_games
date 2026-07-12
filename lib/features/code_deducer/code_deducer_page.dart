import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'models/puzzle.dart';
import 'providers/code_deducer_provider.dart';

class CodeDeducerPage extends ConsumerWidget {
  const CodeDeducerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(codeDeducerProvider);
    final notifier = ref.read(codeDeducerProvider.notifier);
    final textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Deducer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: state.puzzle == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Difficulty:', style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<Difficulty>(
                        value: state.selectedDifficulty,
                        items: Difficulty.values.map((d) {
                          return DropdownMenuItem(
                            value: d,
                            child: Text(d.name.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (diff) {
                          if (diff != null) notifier.startNewGame(diff);
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(
                    'Clues',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.puzzle!.clues.length,
                      itemBuilder: (context, index) {
                        final clue = state.puzzle!.clues[index];
                        return Card(
                          child: ListTile(
                            leading: Text(
                              clue.guess,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                            ),
                            title: Text('${clue.correctPlaced} Exact'),
                            subtitle: Text('${clue.correctWrongPlaced} Partial'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.feedback,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: state.status == GameStatus.won ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    keyboardType: TextInputType.number,
                    maxLength: state.puzzle!.difficulty.codeLength,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Enter ${state.puzzle!.difficulty.codeLength}-digit code',
                    ),
                    enabled: state.status == GameStatus.playing,
                  ),
                  const SizedBox(height: 16),
                  if (state.status == GameStatus.playing)
                    ElevatedButton(
                      onPressed: () => notifier.submitGuess(textController.text),
                      child: const Text('Submit Guess'),
                    )
                  else
                    ElevatedButton(
                      onPressed: () => notifier.startNewGame(state.selectedDifficulty),
                      child: const Text('Play Again'),
                    ),
                ],
              ),
            ),
    );
  }
}