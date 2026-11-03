import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../app_data.dart';
import '../models.dart';
import '../rich_text.dart';
import 'study_screen.dart' show Tts;

/// Create or edit a card. Supports an optional image, tags and TTS preview.
class CardEditorScreen extends StatefulWidget {
  final String deckId;
  final Flashcard? card;
  const CardEditorScreen({super.key, required this.deckId, this.card});

  @override
  State<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends State<CardEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _answerFocus = FocusNode();
  late final TextEditingController _question =
      TextEditingController(text: widget.card?.question ?? '');
  late final TextEditingController _answer =
      TextEditingController(text: widget.card?.answer ?? '');
  late final TextEditingController _note =
      TextEditingController(text: widget.card?.note ?? '');
  late final TextEditingController _tags =
      TextEditingController(text: widget.card?.tags.join(', ') ?? '');
  String? _imagePath;

  bool get _isEditing => widget.card != null;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.card?.imagePath;
  }

  @override
  void dispose() {
    _question.dispose();
    _answer.dispose();
    _answerFocus.dispose();
    _note.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 80, maxWidth: 1600);
      if (picked == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${dir.path}/card-images')
        ..createSync(recursive: true);
      final name =
          'img_${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
      final saved =
          await File(picked.path).copy('${imagesDir.path}/$name');
      setState(() => _imagePath = saved.path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Could not load that image.')));
      }
    }
  }

  List<String> _parseTags(String raw) => raw
      .split(',')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_isEditing) {
      context.read<AppData>().updateCard(
            widget.deckId,
            widget.card!.id,
            question: _question.text.trim(),
            answer: _answer.text.trim(),
            note: _note.text.trim(),
            imagePath: _imagePath,
            tags: _parseTags(_tags.text),
          );
    } else {
      context.read<AppData>().addCard(
            widget.deckId,
            Flashcard(
              id: uuid.v4(),
              question: _question.text.trim(),
              answer: _answer.text.trim(),
              note: _note.text.trim(),
              tags: _parseTags(_tags.text),
              imagePath: _imagePath,
            ),
          );
    }
    Navigator.pop(context);
  }

  /// Swatches offered in the highlight menu (amber default + palette).
  static const Map<String, Color> _highlightColors = <String, Color>{
    'amber': RichMarkup.highlight,
    ...RichMarkup.colors,
  };

  Widget _formatButton(
      IconData icon, String tooltip, VoidCallback onPressed) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon),
      visualDensity: VisualDensity.compact,
      onPressed: () {
        onPressed();
        FocusScope.of(context).requestFocus(_answerFocus);
      },
    );
  }

  void _preview() {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_question.text,
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              if (_imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(_imagePath!),
                      height: 140, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                ),
              const Divider(height: 24),
              Text.rich(
                TextSpan(
                  style: Theme.of(ctx).textTheme.bodyLarge,
                  children: RichMarkup.parseSpans(_answer.text,
                      Theme.of(ctx).textTheme.bodyLarge ??
                          const TextStyle()),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close')),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
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
                  labelText: 'Question (front)',
                  border: OutlineInputBorder(),
                  hintText: 'What is the entrypoint of a Flutter app?'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Question is required' : null,
            ),
            const SizedBox(height: 16),
            // Formatting toolbar: styles the answer's current selection.
            Row(
              children: [
                _formatButton(Icons.format_bold_rounded, 'Bold',
                    () => RichMarkup.toggleWrap(_answer, '**', '**')),
                _formatButton(Icons.format_italic_rounded, 'Italic',
                    () => RichMarkup.toggleWrap(_answer, '*', '*')),
                _formatButton(Icons.format_underline_rounded, 'Underline',
                    () => RichMarkup.toggleWrap(_answer, '__', '__')),
                PopupMenuButton<String>(
                  tooltip: 'Highlight color',
                  icon: const Icon(Icons.highlight_rounded),
                  onSelected: (name) {
                    RichMarkup.toggleWrap(
                        _answer, name == 'amber' ? '==' : '==$name:', '==');
                    FocusScope.of(context).requestFocus(_answerFocus);
                  },
                  itemBuilder: (_) => [
                    for (final entry in _highlightColors.entries)
                      PopupMenuItem(
                        value: entry.key,
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: entry.value,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(entry.key),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            TextFormField(
              controller: _answer,
              focusNode: _answerFocus,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Answer (back)',
                  border: OutlineInputBorder(),
                  hintText: 'The main() function, which calls runApp().'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Answer is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _note,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Context, mnemonic, or related topic'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tags,
              decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  border: OutlineInputBorder(),
                  hintText: 'flutter, basics'),
            ),
            const SizedBox(height: 16),

            // Image attachment.
            if (_imagePath != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(File(_imagePath!),
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                              height: 80,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              child: const Center(
                                  child: Text('Image not available')),
                            )),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: IconButton(
                        iconSize: 16,
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () =>
                            setState(() => _imagePath = null),
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_photo_alternate_rounded),
                  label: const Text('Attach image'),
                ),
              ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _question.text.isEmpty || _answer.text.isEmpty
                        ? null
                        : _preview,
                    icon: const Icon(Icons.visibility_rounded),
                    label: const Text('Preview'),
                  ),
                ),
                if (data.ttsEnabled) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Tts.speak(
                          '${_question.text} ... ${RichMarkup.stripMarkup(_answer.text)}'),
                      icon: const Icon(Icons.volume_up_rounded),
                      label: const Text('Listen'),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: Text(_isEditing ? 'Save changes' : 'Save card'),
            ),
          ],
        ),
      ),
    );
  }
}
