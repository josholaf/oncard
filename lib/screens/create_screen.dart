import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/anki_import.dart';
import '../data/app_data.dart';
import '../ui/emoji_picker.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'card_editor_screen.dart';
import 'deck_screen.dart';
import 'online_decks_screen.dart';

/// The Create tab: quick actions for decks, cards and imports.
class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  Future<void> _pickDeckForNewCard(BuildContext context) async {
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
              child: Text('Add card to which deck?',
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
    if (deckId != null && context.mounted) {
      Navigator.push(
          context,
          MaterialPageRoute<void>(
              builder: (_) => CardEditorScreen(deckId: deckId)));
    }
  }

  /// Imports an .apkg file from the device into local decks.
  Future<void> _importAnkiFile(BuildContext context) async {
    final data = context.read<AppData>();
    final count = await importAnkiPackage(context, data);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(count > 0
            ? 'Imported ${count} cards from Anki'
            : 'No importable cards found in that file.')));
  }

  /// Opens the AnkiWeb shared deck search; downloaded decks are
  /// saved locally like any other deck.
  Future<void> _searchOnline(BuildContext context) {
    return Navigator.push(
        context,
        MaterialPageRoute<void>(
            builder: (_) => const OnlineDecksScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ActionCard(
            icon: Icons.style_rounded,
            title: 'New deck',
            subtitle: 'A fresh collection of cards',
            onTap: () => showNewDeckSheet(context),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.add_card_rounded,
            title: 'New card',
            subtitle: 'Question, answer, image and tags',
            onTap: () => _pickDeckForNewCard(context),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.upload_file_rounded,
            title: 'Import CSV',
            subtitle: 'Choose a deck, then pick a CSV or TSV file',
            onTap: () => pickDeckAndImportCsv(context),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.file_download_outlined,
            title: 'Import Anki deck',
            subtitle: 'An .apkg file with images and audio',
            onTap: () => _importAnkiFile(context),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.travel_explore_rounded,
            title: 'Search decks online',
            subtitle: 'Download shared Anki decks, saved on your device',
            onTap: () => _searchOnline(context),
          ),
          const SizedBox(height: 24),
          Text(
            'Tip: keep one deck per subject. Short, atomic cards are easier to remember than long ones.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: cs.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet used by both Library and Create to add a deck.
Future<void> showNewDeckSheet(BuildContext context) async {
  final data = context.read<AppData>();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: _NewDeckSheet(
          onCreate: (name, icon, color) => data.addDeck(name, icon, color)),
    ),
  );
}

class _NewDeckSheet extends StatefulWidget {
  final void Function(String name, String icon, int colorIndex) onCreate;
  const _NewDeckSheet({required this.onCreate});

  @override
  State<_NewDeckSheet> createState() => _NewDeckSheetState();
}

class _NewDeckSheetState extends State<_NewDeckSheet> {
  final _name = TextEditingController();
  int _colorIndex = 0;
  String _icon = 'lucide:layers';

  static const List<String> _fallbackIcons = <String>[
    'layers', 'sparkles', 'rocket', 'brain', 'star', 'gem', 'zap', 'compass',
    'flower', 'palette', 'trophy', 'wand-sparkles',
  ];

  static const List<String> _keywords = <String>[
    'bio', 'dna', 'math', 'calculator', 'physic', 'atom', 'chem', 'flask-conical',
    'med', 'stethoscope', 'pharma', 'pill', 'drug', 'pill', 'law', 'scale',
    'music', 'music', 'code', 'code', 'art', 'palette', 'lang', 'languages',
    'hist', 'landmark', 'geo', 'earth', 'space', 'rocket', 'astron', 'telescope',
    'econom', 'banknote', 'money', 'wallet', 'business', 'briefcase',
    'comput', 'cpu', 'phone', 'smartphone', 'robot', 'bot', 'ai', 'bot',
    'psycho', 'brain', 'philoso', 'lightbulb', 'relig', 'church', 'theo', 'church',
    'guitar', 'guitar', 'piano', 'piano', 'cook', 'chef-hat', 'food', 'utensils',
    'sport', 'dumbbell', 'gym', 'dumbbell', 'run', 'footprints', 'foot', 'futbol',
    'soccer', 'futbol', 'basket', 'volleyball', 'car', 'car', 'drive', 'car',
    'engine', 'cog', 'anatom', 'heart-pulse', 'nurse', 'stethoscope',
    'network', 'network', 'sql', 'database', 'data', 'database',
    'stat', 'chart-line', 'graph', 'chart-pie', 'english', 'book-open',
    'french', 'languages', 'german', 'languages', 'japan', 'languages',
    'china', 'languages', 'arab', 'languages', 'swahili', 'languages',
    'kinya', 'languages', 'travel', 'plane', 'plane', 'plane',
  ];

  /// Suggests an icon from the deck name, falling back to a default.
  String _suggestIconName(String name) {
    final n = name.trim().toLowerCase();
    for (var i = 0; i + 1 < _keywords.length; i += 2) {
      if (n.contains(_keywords[i])) return _keywords[i + 1];
    }
    return _fallbackIcons[0];
  }

  bool get _valid => _name.text.trim().isNotEmpty;

  Future<void> _pickIcon() async {
    final chosen = await showEmojiPickerSheet(context, current: _icon);
    if (chosen != null && mounted) {
      setState(() => _icon = chosen);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Keep auto-suggest while the user has not manually picked an icon
    // and is still typing a name that matches a keyword.
    final suggested = _suggestIconName(_name.text);
    final displayIcon = _icon.startsWith('lucide:') ? _icon : 'lucide:$suggested';
    final tint = deckPalette[_colorIndex % deckPalette.length];
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('New deck', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(
                  labelText: 'Deck name',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. Pharmacology'),
              onChanged: (value) {
                // Auto-suggest only until the user opens the picker.
                if (!_icon.contains('@') &&
                    (_icon == 'lucide:layers' ||
                        _icon == 'lucide:' + _suggestIconName(value))) {
                  setState(() => _icon = 'lucide:' + _suggestIconName(value));
                } else {
                  setState(() {});
                }
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  InkWell(
                    onTap: _pickIcon,
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.surfaceContainerLow,
                      ),
                      child: Center(
                        child: DeckIcon(icon: displayIcon, size: 40, color: tint),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap the icon to choose from the full library',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  TextButton.icon(
                    onPressed: _pickIcon,
                    icon: const Icon(Icons.grid_view_rounded, size: 18),
                    label: const Text('Choose icon'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text('Color', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (var i = 0; i < deckPalette.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => setState(() => _colorIndex = i),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: deckPalette[i],
                            border: _colorIndex == i
                                ? Border.all(color: cs.primary, width: 3)
                                : Border.all(color: cs.outlineVariant),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _valid
                    ? () {
                        widget.onCreate(
                            _name.text.trim(), displayIcon, _colorIndex);
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text('Create deck'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
