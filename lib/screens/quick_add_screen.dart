import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app_data.dart';
import '../models.dart';

/// Asks Android for text the user selected in another app (the
/// PROCESS_TEXT flow). If any is pending, opens the quick-add screen.
/// Silently does nothing on other platforms or when nothing is pending.
Future<void> maybeOpenQuickAdd(BuildContext context) async {
  String? text;
  try {
    const channel = MethodChannel('oncard/share');
    text = await channel.invokeMethod<String>('getSelectedText');
  } catch (_) {
    return; // Not on Android, or the channel is not wired up.
  }
  if (text == null || text.trim().isEmpty) return;
  if (!context.mounted) return;
  await Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
        builder: (_) => QuickAddScreen(selectedText: text)),
  );
}

/// Lets the user turn text selected in any other app into a flashcard.
/// The selected text lands in the Front field; the user picks a deck,
/// edits, and saves.
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
    final deckId = _deckId ??
        (data.decks.isEmpty ? null : data.decks.first.id);
    final valid = deckId != null &&
        _front.text.trim().isNotEmpty &&
        _back.text.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Add card')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'From selected text',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _front,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Front (question)',
                  border: OutlineInputBorder()),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _back,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Back (answer)',
                  border: OutlineInputBorder()),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: deckId,
              decoration: const InputDecoration(
                  labelText: 'Deck', border: OutlineInputBorder()),
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
              child: FilledButton(
                onPressed: valid
                    ? () {
                        data.addCard(
                          deckId!,
                          Flashcard(
                            id: uuid.v4(),
                            question: _front.text.trim(),
                            answer: _back.text.trim(),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Saved to \"' +
                                    (data.deckById(deckId!)?.name ??
                                        'deck') +
                                '\"'),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text('Save card'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
