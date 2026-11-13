import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_data.dart';
import '../data/models.dart';

/// Lets the user turn text selected in any other app into a flashcard.
/// The selected text lands in the Front field; the user picks a deck,
/// fills the back (optional), and saves.
class QuickAddScreen extends StatefulWidget {
  final String selectedText;
  const QuickAddScreen({super.key, required this.selectedText});

  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  late final TextEditingController _front =
      TextEditingController(text: widget.selectedText);
  final _back = TextEditingController();
  String? _deckId;

  @override
  void dispose() {
    _front.dispose();
    _back.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final deckId = _deckId ?? (data.decks.isEmpty ? null : data.decks.first.id);
    final valid = deckId != null && _front.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Add card from selection')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Text from another app. Edit the front, add an answer, pick a deck.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _front,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Front (question)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _back,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Back (answer)',
                hintText: 'Optional — you can fill this later',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            if (data.decks.isEmpty)
              Text(
                'Create a deck in the Create tab first, then try again.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else
              DropdownButtonFormField<String>(
                value: deckId,
                decoration: const InputDecoration(
                  labelText: 'Deck',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final deck in data.decks)
                    DropdownMenuItem(
                      value: deck.id,
                      child: Text(deck.name),
                    ),
                ],
                onChanged: (id) => setState(() => _deckId = id),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: valid
                    ? () {
                        final answer = _back.text.trim().isEmpty
                            ? '…'
                            : _back.text.trim();
                        data.addCard(
                          deckId!,
                          Flashcard(
                            id: uuid.v4(),
                            question: _front.text.trim(),
                            answer: answer,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Saved to "${data.deckById(deckId)?.name ?? 'deck'}"',
                            ),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    : null,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save card'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
