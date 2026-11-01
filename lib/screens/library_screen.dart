import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_data.dart';
import '../models.dart';
import '../widgets.dart';
import 'create_screen.dart';
import 'deck_screen.dart';

enum _SortBy { name, recent, progress }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _query = '';
  bool _favoritesOnly = false;
  bool _grid = false;
  _SortBy _sort = _SortBy.recent;

  List<Deck> _visible(AppData data) {
    var decks = <Deck>[...data.decks];
    if (_favoritesOnly) {
      decks = decks.where((d) => d.favorite).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      decks = decks.where((d) => d.name.toLowerCase().contains(q)).toList();
    }
    switch (_sort) {
      case _SortBy.name:
        decks.sort((a, b) => a.name.compareTo(b.name));
        break;
      case _SortBy.recent:
        decks.sort((a, b) => b.lastStudied.compareTo(a.lastStudied));
        break;
      case _SortBy.progress:
        decks.sort((a, b) => b.progress.compareTo(a.progress));
        break;
    }
    return decks;
  }

  void _openDeck(BuildContext context, String id) {
    Navigator.push(
        context,
        MaterialPageRoute<void>(
            builder: (_) => DeckScreen(deckId: id)));
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final decks = _visible(data);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            tooltip: _grid ? 'List view' : 'Grid view',
            icon: Icon(_grid ? Icons.view_list_rounded : Icons.grid_view_rounded),
            onPressed: () => setState(() => _grid = !_grid),
          ),
          IconButton(
            tooltip: 'New deck',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => showNewDeckSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search decks',
                prefixIcon: const Icon(Icons.search_rounded),
                isDense: true,
                filled: true,
                fillColor: cs.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Favorites'),
                  selected: _favoritesOnly,
                  onSelected: (v) => setState(() => _favoritesOnly = v),
                ),
                const Spacer(),
                PopupMenuButton<_SortBy>(
                  tooltip: 'Sort',
                  icon: const Icon(Icons.sort_rounded),
                  initialValue: _sort,
                  onSelected: (v) => setState(() => _sort = v),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                        value: _SortBy.name, child: Text('Name')),
                    PopupMenuItem(
                        value: _SortBy.recent, child: Text('Recently studied')),
                    PopupMenuItem(
                        value: _SortBy.progress, child: Text('Progress')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: decks.isEmpty
                ? const EmptyState(
                    icon: Icons.search_rounded,
                    title: 'No decks found',
                    subtitle:
                        'Try a different search, or create a new deck with the + button.')
                : _grid
                    ? GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 220,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.95),
                        itemCount: decks.length,
                        itemBuilder: (context, i) =>
                            _deckTile(context, data, decks[i], true),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: decks.length,
                        itemBuilder: (context, i) =>
                            _deckTile(context, data, decks[i], false),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _deckTile(
      BuildContext context, AppData data, Deck deck, bool grid) {
    final cs = Theme.of(context).colorScheme;
    final inner = InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openDeck(context, deck.id),
      child: Padding(
        padding: EdgeInsets.all(grid ? 14 : 12),
        child: grid
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DeckAvatar(icon: deck.icon, colorIndex: deck.colorIndex, size: 48),
                  const SizedBox(height: 10),
                  Text(deck.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Text(
                      '${(deck.progress * 100).round()}% mastered',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: deck.progress),
                  ),
                  const SizedBox(height: 8),
                  _badges(deck),
                ],
              )
            : Row(
                children: [
                  DeckAvatar(icon: deck.icon, colorIndex: deck.colorIndex),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(deck.name,
                            style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child:
                                    LinearProgressIndicator(value: deck.progress),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('${(deck.progress * 100).round()}%',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _badges(deck),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: deck.favorite
                        ? 'Remove from favorites'
                        : 'Add to favorites',
                    icon: Icon(
                      deck.favorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: deck.favorite
                          ? const Color(0xFFD99A42)
                          : cs.onSurfaceVariant,
                    ),
                    onPressed: () => data.toggleFavorite(deck.id),
                  ),
                ],
              ),
      ),
    );
    return Card(
      margin: grid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
      child: inner,
    );
  }

  Widget _badges(Deck deck) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        if (deck.dueCount > 0)
          CountBadge(
              label: '${deck.dueCount} due',
              color: const Color(0xFF9C4146)),
        if (deck.newCount > 0)
          CountBadge(
              label: '${deck.newCount} new',
              color: const Color(0xFF1565C0)),
      ],
    );
  }
}
