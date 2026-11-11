import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_data.dart';
import '../data/models.dart';
import '../ui/widgets.dart';
import 'card_editor_screen.dart';

/// Filters over all cards shown in the browser.
enum CardFilter { all, due, newCards, lapsed }

/// Search, filter and bulk-manage cards. Open with a [deckId] to browse
/// one deck, or without one to search every deck at once.
class BrowserScreen extends StatefulWidget {
  final String? deckId;
  const BrowserScreen({super.key, this.deckId});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  String _query = '';
  CardFilter _filter = CardFilter.all;
  final Set<String> _selected = <String>{};
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(Flashcard card) {
    switch (_filter) {
      case CardFilter.all:
        return true;
      case CardFilter.due:
        return card.isDue && !card.mastered;
      case CardFilter.newCards:
        return card.isNew;
      case CardFilter.lapsed:
        return card.lapses > 0;
    }
  }

  bool _hits(Flashcard card, String q) {
    if (q.isEmpty) return true;
    final hay = (card.question + ' ' + card.answer + ' ' + card.note + ' ' +
            card.tags.join(' '))
        .toLowerCase();
    return hay.contains(q);
  }

  /// Groups selected card ids by the deck that holds them, so bulk
  /// actions work across decks too.
  Map<String, List<String>> _selectedByDeck(List<(Deck, Flashcard)> rows) {
    final map = <String, List<String>>{};
    for (final row in rows) {
      final card = row.$2;
      if (!_selected.contains(card.id)) continue;
      map.putIfAbsent(row.$1.id, () => <String>[]).add(card.id);
    }
    return map;
  }

  void _clearSelection() => setState(_selected.clear);

  Future<void> _bulkDelete(List<(Deck, Flashcard)> rows) async {
    final count = _selected.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ' + count.toString() + ' card(s)?'),
        content: const Text('This cannot be undone.'),
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
    if (ok != true) return;
    final data = context.read<AppData>();
    _selectedByDeck(rows).forEach(data.deleteCards);
    _clearSelection();
  }

  Future<void> _bulkMove(List<(Deck, Flashcard)> rows) async {
    final data = context.read<AppData>();
    final target = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Move to which deck?',
                  style: Theme.of(sheetContext).textTheme.titleMedium),
            ),
            for (final deck in data.decks)
              ListTile(
                leading: DeckIcon(icon: deck.icon, size: 22),
                title: Text(deck.name),
                onTap: () => Navigator.pop(sheetContext, deck.id),
              ),
          ],
        ),
      ),
    );
    if (target == null) return;
    _selectedByDeck(rows)
        .forEach((deckId, cardIds) => data.moveCards(deckId, cardIds, target));
    _clearSelection();
  }

  Future<void> _bulkTag(List<(Deck, Flashcard)> rows) async {
    final controller = TextEditingController();
    final result = await showDialog<({String tag, bool add})>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit tags'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Tag'),
            ),
            const SizedBox(height: 8),
            const Text('The tag is added to, or removed from, every '
                'selected card.'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(
                  ctx, (tag: controller.text.trim(), add: false)),
              child: const Text('Remove')),
          FilledButton(
              onPressed: () => Navigator.pop(
                  ctx, (tag: controller.text.trim(), add: true)),
              child: const Text('Add')),
        ],
      ),
    );
    if (result == null || result.tag.isEmpty) return;
    final data = context.read<AppData>();
    _selectedByDeck(rows).forEach((deckId, cardIds) =>
        data.editTags(deckId, cardIds, add: result.add, tag: result.tag));
    _clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final cs = Theme.of(context).colorScheme;
    final decks = widget.deckId == null
        ? data.decks
        : <Deck>[if (data.deckById(widget.deckId!) != null) data.deckById(widget.deckId!)!];
    final query = _query.toLowerCase().trim();

    final rows = <(Deck, Flashcard)>[];
    for (final deck in decks) {
      for (final card in deck.cards) {
        if (_matches(card) && _hits(card, query)) rows.add((deck, card));
      }
    }

    final selecting = _selected.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(selecting
            ? _selected.length.toString() + ' selected'
            : (widget.deckId == null ? 'All cards' : 'Browse cards')),
        actions: [
          if (selecting)
            IconButton(
              tooltip: 'Clear selection',
              icon: const Icon(Icons.close_rounded),
              onPressed: _clearSelection,
            )
          else
            IconButton(
              tooltip: 'Select all shown',
              icon: const Icon(Icons.select_all_rounded),
              onPressed: rows.isEmpty
                  ? null
                  : () => setState(() =>
                      _selected.addAll(rows.map((r) => r.$2.id))),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search question, answer, note, tags',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                      ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                for (final f in CardFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(switch (f) {
                        CardFilter.all => 'All',
                        CardFilter.due => 'Due',
                        CardFilter.newCards => 'New',
                        CardFilter.lapsed => 'Lapsed',
                      }),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: rows.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Nothing found',
                    subtitle:
                        'No cards match this search and filter combination.')
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: rows.length,
                    itemBuilder: (context, i) {
                      final deck = rows[i].$1;
                      final card = rows[i].$2;
                      final checked = _selected.contains(card.id);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: checked ? cs.primaryContainer : null,
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 14),
                          onTap: () {
                            if (selecting) {
                              setState(() => checked
                                  ? _selected.remove(card.id)
                                  : _selected.add(card.id));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                      builder: (_) => CardEditorScreen(
                                          deckId: deck.id, card: card)));
                            }
                          },
                          onLongPress: () =>
                              setState(() => _selected.add(card.id)),
                          leading: selecting
                              ? Icon(checked
                                  ? Icons.check_box_rounded
                                  : Icons.check_box_outline_blank_rounded)
                              : MasteryDots(mastery: card.masteryDots),
                          title: Text(card.question,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                if (widget.deckId == null) ...[
                                  Text(deck.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: cs.onSurfaceVariant)),
                                  const SizedBox(width: 8),
                                ],
                                if (card.isDue && !card.mastered)
                                  _Badge('Due', cs.errorContainer,
                                      cs.onErrorContainer),
                                if (card.isNew) ...[
                                  const SizedBox(width: 6),
                                  _Badge('New', cs.secondaryContainer,
                                      cs.onSecondaryContainer),
                                ],
                                if (card.lapses > 0) ...[
                                  const SizedBox(width: 6),
                                  _Badge('Lapsed', cs.surfaceContainerHighest,
                                      cs.onSurfaceVariant),
                                ],
                                if (card.tags.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(card.tags.join(', '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: cs.onSurfaceVariant)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: selecting
          ? SafeArea(
              child: NavigationBar(
                height: 64,
                destinations: [
                  IconButton(
                    tooltip: 'Move to deck',
                    icon: const Icon(Icons.drive_file_move_rounded),
                    onPressed: () => _bulkMove(rows),
                  ),
                  IconButton(
                    tooltip: 'Add or remove tag',
                    icon: const Icon(Icons.label_rounded),
                    onPressed: () => _bulkTag(rows),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_rounded),
                    onPressed: () => _bulkDelete(rows),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;
  const _Badge(this.text, this.background, this.foreground);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: background,
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: foreground)),
    );
  }
}
