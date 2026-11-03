import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_data.dart';
import '../emoji_picker.dart';
import 'card_editor_screen.dart';
import 'deck_screen.dart';

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
                leading: Text(deck.icon,
                    style: const TextStyle(fontSize: 22)),
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
  String _icon = '👋';

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
            Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  final picked =
                      await showEmojiPickerSheet(context, current: _icon);
                  if (picked != null) setState(() => _icon = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_icon, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 10),
                      Text('Tap to choose icon',
                          style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _valid
                    ? () {
                        widget.onCreate(_name.text.trim(), _icon, 0);
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

