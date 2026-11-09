import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_data.dart';
import '../emoji_picker.dart';
import '../import_export.dart';
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

  Future<void> _renameDeck(AppData data, Deck deck) async {
    final controller = TextEditingController(text: deck.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename deck'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Deck name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      data.updateDeck(deck.id,
          name: name, icon: deck.icon, colorIndex: deck.colorIndex);
    }
  }

  Future<void> _confirmDelete(AppData data, Deck deck) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete deck?'),
        content: Text(
            'Delete "${deck.name}" and all its cards? This cannot be undone.'),
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
    if (ok == true) data.deleteDeck(deck.id);
  }

  /// Long-press menu for one deck, matching the reference design:
  /// rename, share as CSV, edit icon, delete.
  Future<void> _deckMenu(AppData data, Deck deck) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final sheetCs = Theme.of(ctx).colorScheme;
        Widget row(String value, IconData icon, String label,
            {Color? color}) {
          return ListTile(
            leading: Icon(icon, color: color ?? sheetCs.onSurfaceVariant),
            title: Text(label,
                style: TextStyle(
                    color: color ?? sheetCs.onSurface,
                    fontWeight: FontWeight.w600)),
            onTap: () => Navigator.pop(ctx, value),
          );
        }
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: Row(
                  children: [
                    DeckAvatar(
                        icon: deck.icon,
                        colorIndex: deck.colorIndex,
                        size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(deck.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(ctx).textTheme.titleMedium),
                    ),
                  ],
                ),
              ),
              row('rename', Icons.drive_file_rename_outline_rounded, 'Rename'),
              row('share', Icons.ios_share_rounded, 'Share as CSV'),
              row('icon', Icons.emoji_objects_outlined, 'Edit icon'),
              row('delete', Icons.delete_rounded, 'Delete',
                  color: sheetCs.error),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (action == null) return;
    if (!mounted) return;
    switch (action) {
      case 'rename':
        await _renameDeck(data, deck);
        break;
      case 'share':
        final ok = await shareDeckCsv(deck);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(ok
                  ? 'Shared ${deck.name} as CSV'
                  : 'Sharing is available on Android only.')));
        }
        break;
      case 'icon':
        final icon = await showEmojiPickerSheet(context, current: deck.icon);
        if (icon != null) {
          data.updateDeck(deck.id,
              name: deck.name, icon: icon, colorIndex: deck.colorIndex);
        }
        break;
      case 'delete':
        await _confirmDelete(data, deck);
        break;
    }
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
            icon: Icon(
                _grid ? Icons.view_list_rounded : Icons.grid_view_rounded),
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
      onLongPress: () => _deckMenu(data, deck),
      child: Padding(
        padding: grid
            ? const EdgeInsets.all(14)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      '${deck.cards.length} cards',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
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
                        Text('${deck.cards.length} cards',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
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
      margin: grid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 10),
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
              color: const Color(0xFF6750A4)),
        if (deck.newCount > 0)
          CountBadge(
              label: '${deck.newCount} new',
              color: const Color(0xFF39845B)),
      ],
    );
  }
}
