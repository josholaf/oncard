
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_data.dart';
import '../import_export.dart';
import '../models.dart';
import '../widgets.dart';
import 'card_editor_screen.dart';
import 'study_screen.dart';

class DeckScreen extends StatelessWidget {
  final String deckId;
  const DeckScreen({super.key, required this.deckId});

  Future<void> _confirmDelete(BuildContext context, AppData data) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete deck?'),
        content: const Text(
            'All cards in this deck will be removed. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      data.deleteDeck(deckId);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final deck = data.deckById(deckId);
    if (deck == null) {
      return const Scaffold(body: Center(child: Text('Deck not found')));
    }
    final cs = Theme.of(context).colorScheme;
    final mastered =
        deck.cards.where((c) => c.mastered).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(deck.name),
        actions: [
          IconButton(
            tooltip: deck.favorite ? 'Unfavorite' : 'Favorite',
            icon: Icon(deck.favorite
                ? Icons.star_rounded
                : Icons.star_border_rounded),
            onPressed: () => data.toggleFavorite(deck.id),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'import':
                  await importCsvFile(context, data, deckId);
                  break;
                case 'import-tsv':
                  await importCsvFile(context, data, deckId, tsv: true);
                  break;
                case 'export':
                  final file = await exportDeckCsv(deck);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Exported to ${file.path}')));
                  }
                  break;
                case 'delete':
                  await _confirmDelete(context, data);
                  break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: 'import', child: Text('Import CSV')),
              PopupMenuItem(
                  value: 'import-tsv', child: Text('Import TSV')),
              PopupMenuItem(
                  value: 'export', child: Text('Export as CSV')),
              PopupMenuItem(value: 'delete', child: Text('Delete deck')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('New card'),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
                builder: (_) => CardEditorScreen(deckId: deckId))),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(value: deck.progress),
                  ),
                ),
                const SizedBox(width: 12),
                Text('$mastered / ${deck.cards.length} mastered',
                    style:
                        Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: deck.cards.isEmpty
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                                builder: (_) => StudyScreen(
                                    deck: deck, mode: StudyMode.flip))),
                    icon: const Icon(Icons.style_rounded),
                    label: const Text('Flip'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonal.icon(
                    onPressed: deck.cards.length < 2
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                                builder: (_) => StudyScreen(
                                    deck: deck, mode: StudyMode.quiz))),
                    icon: const Icon(Icons.quiz_rounded),
                    label: const Text('Quiz'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonal.icon(
                    onPressed: deck.cards.isEmpty
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                                builder: (_) => StudyScreen(
                                    deck: deck, mode: StudyMode.typing))),
                    icon: const Icon(Icons.keyboard_rounded),
                    label: const Text('Type'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: deck.cards.isEmpty
                ? const EmptyState(
                    icon: Icons.style_rounded,
                    title: 'No cards yet',
                    subtitle: 'Add your first card with the button below.')
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                    itemCount: deck.cards.length,
                    itemBuilder: (context, i) {
                      final card = deck.cards[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 14),
                          title: Text(card.question,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                if (card.imagePath != null)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(Icons.image_rounded, size: 16),
                                  ),
                                Expanded(
                                  child: Text(card.answer,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MasteryDots(mastery: card.masteryDots),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute<void>(
                                            builder: (_) => CardEditorScreen(
                                                deckId: deckId, card: card)));
                                  } else if (value == 'delete') {
                                    data.deleteCard(deckId, card.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Card deleted')));
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                      value: 'edit', child: Text('Edit')),
                                  PopupMenuItem(
                                      value: 'delete', child: Text('Delete')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Opens a deck picker then imports a CSV/TSV into the chosen deck.
Future<void> pickDeckAndImportCsv(BuildContext context) async {
  final data = context.read<AppData>();
  if (data.decks.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a deck first.')));
    return;
  }
  final deckId = await showModalBottomSheet<String>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Import into which deck?',
                style: Theme.of(sheetContext).textTheme.titleMedium),
          ),
          for (final deck in data.decks)
            ListTile(
              leading: Text(deck.icon, style: const TextStyle(fontSize: 22)),
              title: Text(deck.name),
              onTap: () => Navigator.pop(sheetContext, deck.id),
            ),
        ],
      ),
    ),
  );
  if (deckId != null && context.mounted) {
    await importCsvFile(context, data, deckId);
  }
}
