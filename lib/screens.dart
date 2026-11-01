import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'app_data.dart';
import 'models.dart';

const deckPalette = <Color>[
  Color(0xFF6750A4),
  Color(0xFF386A20),
  Color(0xFF9C4146),
  Color(0xFF1565C0),
  Color(0xFFE65100),
  Color(0xFF00897B),
];

const deckIcons = <String>[
  '📚', '🧠', '🫀', '🧬', '💻', '🎯',
  '🇫🇷', '🇯🇵', '🌱', '⚗️', '🧪', '📝',
];

class MasteryDots extends StatelessWidget {
  final int mastery;
  const MasteryDots({super.key, required this.mastery});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < mastery;
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? cs.primary : cs.surfaceContainerHighest,
          ),
        );
      }),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeScreen(),
      const LibraryScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.library_books_outlined),
              selectedIcon: Icon(Icons.library_books),
              label: 'Library'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const quotes = <String>[
    'Repetition is the mother of learning.',
    'Small steps every day beat cramming every way.',
    'You remember what you retrieve, not what you reread.',
    'Consistency compounds. Show up again tomorrow.',
    'A card a day keeps forgetting away.',
    'Focus on the card in front of you.',
    'Mastery is built one honest review at a time.',
  ];

  Deck? _pickDue(List<Deck> decks) {
    Deck? best;
    var bestCount = -1;
    for (final d in decks) {
      final count = d.cards.where((c) => !c.mastered).length;
      if (count > bestCount) {
        best = d;
        bestCount = count;
      }
    }
    return best;
  }

  void _openDeck(BuildContext context, String id) {
    Navigator.push(
        context, MaterialPageRoute<void>(builder: (_) => DeckScreen(deckId: id)));
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final due = _pickDue(data.decks);
    final quote = quotes[DateTime.now().weekday % quotes.length];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Oncard',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Study smarter, remember longer.',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.streak.toString() + ' day streak',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      const Text(
                          'Keep it alive. Study at least one card today.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: due == null
              ? null
              : () => Navigator.push(context,
                  MaterialPageRoute<void>(builder: (_) => StudyScreen(deck: due))),
          icon: const Icon(Icons.play_arrow),
          label: Text(due == null ? 'All caught up' : 'Quick start: ' + due.name),
        ),
        const SizedBox(height: 24),
        Text('My Decks', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 96,
          child: data.decks.isEmpty
              ? const Center(child: Text('No decks yet. Create one in Library.'))
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: data.decks.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final deck = data.decks[i];
                    final color = deckPalette[deck.colorIndex % deckPalette.length];
                    return Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _openDeck(context, deck.id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                  backgroundColor: color,
                                  child: Text(deck.icon,
                                      style: const TextStyle(fontSize: 20))),
                              const SizedBox(height: 8),
                              Text(deck.name,
                                  style:
                                      Theme.of(context).textTheme.labelLarge),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.format_quote),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(quote,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontStyle: FontStyle.italic))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  String _label(Deck deck) {
    final mastered = deck.cards.where((c) => c.mastered).length;
    return mastered.toString() +
        ' / ' +
        deck.cards.length.toString() +
        ' mastered';
  }

  void _openDeck(BuildContext context, String id) {
    Navigator.push(
        context, MaterialPageRoute<void>(builder: (_) => DeckScreen(deckId: id)));
  }

  void _showNewDeckSheet(BuildContext context) {
    final data = context.read<AppData>();
    showModalBottomSheet<void>(
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

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            tooltip: 'New deck',
            icon: const Icon(Icons.add),
            onPressed: () => _showNewDeckSheet(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: data.decks.length,
        itemBuilder: (context, i) {
          final deck = data.decks[i];
          final color = deckPalette[deck.colorIndex % deckPalette.length];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color,
                child:
                    Text(deck.icon, style: const TextStyle(fontSize: 20)),
              ),
              title: Text(deck.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: deck.progress),
                  ),
                  const SizedBox(height: 4),
                  Text(_label(deck)),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openDeck(context, deck.id),
            ),
          );
        },
      ),
    );
  }
}

class _NewDeckSheet extends StatefulWidget {
  final void Function(String name, String icon, int colorIndex) onCreate;
  const _NewDeckSheet({required this.onCreate});

  @override
  State<_NewDeckSheet> createState() => _NewDeckSheetState();
}

class _NewDeckSheetState extends State<_NewDeckSheet> {
  final _name = TextEditingController();
  String _icon = deckIcons.first;
  int _color = 0;

  bool get _valid => _name.text.trim().isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Text('Icon', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6, childAspectRatio: 1),
              itemCount: deckIcons.length,
              itemBuilder: (context, i) {
                final icon = deckIcons[i];
                final selected = icon == _icon;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _icon = icon),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: selected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      border: selected
                          ? null
                          : Border.all(
                              color: Theme.of(context).colorScheme.outline),
                    ),
                    child: Center(
                        child: Text(icon,
                            style: const TextStyle(fontSize: 22))),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Text('Color', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: deckPalette.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final selected = i == _color;
                  return GestureDetector(
                    onTap: () => setState(() => _color = i),
                    child: Container(
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: deckPalette[i],
                        border: Border.all(
                          color: selected
                              ? Theme.of(context).colorScheme.onSurface
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _valid
                    ? () {
                        widget.onCreate(_name.text.trim(), _icon, _color);
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

class DeckScreen extends StatelessWidget {
  final String deckId;
  const DeckScreen({super.key, required this.deckId});

  String _masteredLabel(Deck deck) {
    final mastered = deck.cards.where((c) => c.mastered).length;
    return mastered.toString() +
        ' / ' +
        deck.cards.length.toString() +
        ' cards mastered';
  }

  Future<void> _confirmDelete(BuildContext context, AppData data) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete deck?'),
        content:
            const Text('All cards in this deck will be removed. This cannot be undone.'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(deck.name),
        actions: [
          IconButton(
            tooltip: 'Import CSV',
            icon: const Icon(Icons.upload_file),
            onPressed: () => importCsv(context, data, deckId),
          ),
          IconButton(
            tooltip: 'Export CSV',
            icon: const Icon(Icons.file_download),
            onPressed: () => exportCsv(context, deck),
          ),
          IconButton(
            tooltip: 'Delete deck',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, data),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New card'),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
                builder: (_) => CreateCardScreen(deckId: deckId))),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                    child: LinearProgressIndicator(value: deck.progress)),
                const SizedBox(width: 12),
                Text(_masteredLabel(deck),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: deck.cards.isEmpty
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                            builder: (_) => StudyScreen(deck: deck))),
                icon: const Icon(Icons.school),
                label: const Text('Study deck'),
              ),
            ),
          ),
          Expanded(
            child: deck.cards.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.style, size: 48),
                        const SizedBox(height: 12),
                        const Text('No cards yet'),
                        TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (_) =>
                                      CreateCardScreen(deckId: deckId))),
                          child: const Text('Add your first card'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
                    itemCount: deck.cards.length,
                    itemBuilder: (context, i) {
                      final card = deck.cards[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(card.question,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          subtitle: Text(card.answer,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MasteryDots(card.mastery),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute<void>(
                                            builder: (_) => CreateCardScreen(
                                                deckId: deckId,
                                                card: card)));
                                  } else if (value == 'delete') {
                                    data.deleteCard(deckId, card.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Card deleted')));
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

class CreateCardScreen extends StatefulWidget {
  final String deckId;
  final Flashcard? card;
  const CreateCardScreen({super.key, required this.deckId, this.card});

  @override
  State<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends State<CreateCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _question =
      TextEditingController(text: widget.card?.question ?? '');
  late final TextEditingController _answer =
      TextEditingController(text: widget.card?.answer ?? '');
  late final TextEditingController _note =
      TextEditingController(text: widget.card?.note ?? '');

  bool get _isEditing => widget.card != null;

  @override
  void dispose() {
    _question.dispose();
    _answer.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_isEditing) {
      context.read<AppData>().updateCard(
            widget.deckId,
            widget.card!.id,
            question: _question.text.trim(),
            answer: _answer.text.trim(),
            note: _note.text.trim(),
          );
    } else {
      context.read<AppData>().addCard(
            widget.deckId,
            Flashcard(
              id: uuid.v4(),
              question: _question.text.trim(),
              answer: _answer.text.trim(),
              note: _note.text.trim(),
            ),
          );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit card' : 'New card')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _question,
              decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                  hintText: 'What is the entrypoint of a Flutter app?'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Question is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _answer,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Answer',
                  border: OutlineInputBorder(),
                  hintText: 'The main() function, which calls runApp().'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Answer is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _note,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Context, mnemonic, or related topic'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(_isEditing ? 'Save changes' : 'Save card'),
            ),
          ],
        ),
      ),
    );
  }
}

class StudyScreen extends StatefulWidget {
  final Deck deck;
  const StudyScreen({super.key, required this.deck});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flip = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400));
  late final List<Flashcard> _queue;
  int _index = 0;
  bool _showBack = false;
  int _known = 0;
  int _again = 0;

  @override
  void initState() {
    super.initState();
    _queue = <Flashcard>[...widget.deck.cards]
      ..sort((a, b) => a.mastery.compareTo(b.mastery));
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showBack) {
      _flip.reverse();
    } else {
      _flip.forward();
    }
    setState(() => _showBack = !_showBack);
  }

  void _rate(bool knew) {
    final card = _queue[_index];
    context.read<AppData>().recordReview(widget.deck.id, card.id, knew);
    if (knew) {
      _known++;
    } else {
      _again++;
      _queue.add(card);
    }
    _flip.stop();
    _flip.value = 0;
    setState(() {
      _showBack = false;
      _index++;
    });
  }

  Widget _face(bool back) {
    final card = _queue[_index];
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: back ? cs.secondaryContainer : cs.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            back ? card.answer : card.question,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (back && card.note.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(card.note,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
          if (back && card.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final t in card.tags)
                  Chip(
                      label: Text(t),
                      visualDensity: VisualDensity.compact),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_index >= _queue.length) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.deck.name)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration, size: 64),
              const SizedBox(height: 16),
              Text('Session complete',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Known ' +
                  _known.toString() +
                  ' · Again ' +
                  _again.toString()),
              const SizedBox(height: 24),
              FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done')),
            ],
          ),
        ),
      );
    }
    final total = _queue.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deck.name),
        actions: [
          IconButton(
            tooltip: 'End session',
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
                'Card ' +
                    (_index + 1).toString() +
                    ' of ' +
                    total.toString(),
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: _index / total),
            const SizedBox(height: 24),
            Expanded(
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedBuilder(
                  animation: _flip,
                  builder: (context, child) {
                    final showingFront = _flip.value < 0.5;
                    final angle = _flip.value * 3.141592653589793;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(
                            showingFront ? angle : angle - 3.141592653589793),
                      child: showingFront ? _face(false) : _face(true),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showBack ? () => _rate(false) : _flipCard,
                    icon: const Icon(Icons.close),
                    label: const Text('Again'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _showBack ? () => _rate(true) : _flipCard,
                    icon: const Icon(Icons.check),
                    label: const Text('Know'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
                _showBack
                    ? 'Answer shown. Rate it honestly.'
                    : 'Tap the card to reveal the answer.',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

Future<void> importCsv(
    BuildContext context, AppData data, String deckId) async {
  final picked = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: <String>['csv'],
    withData: true,
  );
  if (picked == null) return;
  final bytes = picked.files.single.bytes;
  if (bytes == null) return;
  final rows = const CsvToListConverter(eol: '\n').convert(utf8.decode(bytes));
  final cards = <Flashcard>[];
  var first = true;
  for (final row in rows) {
    final values = row.map((e) => e.toString().trim()).toList();
    if (values.isEmpty || values.first.isEmpty) continue;
    final looksLikeHeader = values.any(
        (v) => v.toLowerCase() == 'question' || v.toLowerCase() == 'answer');
    if (first && looksLikeHeader) {
      first = false;
      continue;
    }
    first = false;
    if (values.length < 2) continue;
    final note = values.length > 2 ? values[2] : '';
    final tags = values.length > 3
        ? values[3]
            .split(';')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList()
        : <String>[];
    cards.add(Flashcard(
        id: uuid.v4(),
        question: values[0],
        answer: values[1],
        note: note,
        tags: tags));
  }
  if (cards.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No cards found in that CSV.')));
    }
    return;
  }
  data.addCards(deckId, cards);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Imported ' +
            cards.length.toString() +
            ' cards into this deck.')));
  }
}

Future<void> exportCsv(BuildContext context, Deck deck) async {
  if (deck.cards.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to export yet.')));
    return;
  }
  final dir = await getApplicationDocumentsDirectory();
  final safeName = deck.name.replaceAll(RegExp('[^A-Za-z0-9_-]'), '_');
  final file = File(dir.path + '/oncard_' + safeName + '.csv');
  final rows = <List<String>>[
    <String>['question', 'answer', 'note', 'tags'],
    for (final c in deck.cards)
      <String>[c.question, c.answer, c.note, c.tags.join(';')],
  ];
  await file.writeAsString(const ListToCsvConverter().convert(rows));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to ' + file.path)));
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
          RadioListTile<ThemeMode>(
            title: const Text('System'),
            subtitle: const Text('Follow the device setting'),
            value: ThemeMode.system,
            groupValue: data.themeMode,
            onChanged: (m) => data.setThemeMode(m!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: data.themeMode,
            onChanged: (m) => data.setThemeMode(m!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: data.themeMode,
            onChanged: (m) => data.setThemeMode(m!),
          ),
          const SizedBox(height: 24),
          Text('About', style: Theme.of(context).textTheme.titleMedium),
          const ListTile(
            title: Text('Oncard'),
            subtitle: Text(
                'Study smarter, remember longer. Offline-first flashcards. v1.0.0'),
          ),
        ],
      ),
    );
  }
}
