import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../data/app_data.dart';
import '../services/audio.dart';
import '../ui/cloze.dart';
import '../data/models.dart';
import '../ui/occlusion.dart';
import '../ui/rich_text.dart';
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
  final _questionFocus = FocusNode();
  late final TextEditingController _question =
      TextEditingController(text: widget.card?.question ?? '');
  late final TextEditingController _answer =
      TextEditingController(text: widget.card?.answer ?? '');
  late final TextEditingController _note =
      TextEditingController(text: widget.card?.note ?? '');
  late final TextEditingController _tags =
      TextEditingController(text: widget.card?.tags.join(', ') ?? '');
  String? _imagePath;
  late List<double> _occlusions =
      List<double>.from(widget.card?.occlusions ?? const <double>[]);
  String? _audioPath;

  bool get _isEditing => widget.card != null;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.card?.imagePath;
    _audioPath = widget.card?.audioPath;
  }

  @override
  void dispose() {
    _question.dispose();
    _answer.dispose();
    _questionFocus.dispose();
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

  Future<void> _attachMenu() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_photo_alternate_rounded),
              title: const Text('Image'),
              subtitle: const Text('Pick a picture from the gallery'),
              onTap: () => Navigator.pop(sheetContext, 'image'),
            ),
            ListTile(
              leading: const Icon(Icons.graphic_eq_rounded),
              title: const Text('Audio'),
              subtitle: const Text('Pick an audio file (mp3, m4a, wav)'),
              onTap: () => Navigator.pop(sheetContext, 'audio'),
            ),
          ],
        ),
      ),
    );
    if (choice == 'image') await _pickImage();
    if (choice == 'audio') await _pickAudio();
  }

  Future<void> _pickAudio() async {
    try {
      final picked =
          await FilePicker.platform.pickFiles(type: FileType.audio);
      final path = picked?.files.single.path;
      if (path == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory(dir.path + '/card-audio')
        ..createSync(recursive: true);
      final name = 'aud_' +
          DateTime.now().millisecondsSinceEpoch.toString() +
          '_' +
          path.split('/').last;
      final saved = await File(path).copy(audioDir.path + '/' + name);
      setState(() => _audioPath = saved.path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Could not load that audio file.')));
      }
    }
  }

  Future<void> _editOcclusions() async {
    final result = await Navigator.push<List<double>>(
      context,
      MaterialPageRoute<List<double>>(
        builder: (_) => OcclusionEditor(
          imagePath: _imagePath!,
          initial: _occlusions,
        ),
      ),
    );
    if (result != null) setState(() => _occlusions = result);
  }

  /// Toggles a line prefix (bullet or numbered) on the answer's line.
  void _toggleLinePrefix(String prefix) {
    _lineEdit((line) {
      if (line.startsWith(prefix)) {
        return line.substring(prefix.length);
      }
      final stripped = line.replaceFirst(RegExp(r'^(- |\d+\. |>*)'), '');
      return prefix + stripped;
    });
  }

  /// Indents (delta 1) or outdents (delta -1) the answer's line.
  void _indentLine(int delta) {
    _lineEdit((line) {
      if (delta > 0) return '>' + line;
      if (line.startsWith('>')) return line.substring(1);
      return line;
    });
  }

  /// Applies [transform] to the line holding the caret in the answer.
  void _lineEdit(String Function(String) transform) {
    final controller = _answer;
    final sel = controller.selection;
    final text = controller.text;
    final s = sel.start < 0 ? text.length : sel.start;
    var lineStart = 0;
    if (s > 0) {
      lineStart = text.lastIndexOf('\n', s - 1) + 1;
    }
    var lineEnd = text.indexOf('\n', lineStart);
    if (lineEnd == -1) lineEnd = text.length;
    final line = text.substring(lineStart, lineEnd);
    final next = transform(line);
    final caret = s + (next.length - line.length);
    controller.value = TextEditingValue(
      text: text.replaceRange(lineStart, lineEnd, next),
      selection: TextSelection.collapsed(offset: caret),
    );
    setState(() {});
    FocusScope.of(context).requestFocus(_answerFocus);
  }

  List<String> _parseTags(String raw) => raw
      .split(',')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final question = _question.text.trim();
    final answer = _answer.text.trim();
    final note = _note.text.trim();
    final tags = _parseTags(_tags.text);
    if (_isEditing) {
      context.read<AppData>().updateCard(
            widget.deckId,
            widget.card!.id,
            question: question,
            answer: answer.isEmpty && Cloze.hasCloze(question)
                ? Cloze.answerFor(question, widget.card!.clozeIndex)
                : answer,
            note: note,
            imagePath: _imagePath,
                audioPath: _audioPath,
                occlusions: _occlusions,
            tags: tags,
          );
    } else {
      final groups = Cloze.groups(question);
      if (groups.length > 1) {
        // Anki-style cloze: one card per deletion group.
        for (final group in groups) {
          context.read<AppData>().addCard(
                widget.deckId,
                Flashcard(
                  id: uuid.v4(),
                  question: question,
                  answer: answer.isNotEmpty
                      ? answer
                      : Cloze.answerFor(question, group),
                  note: note,
                  tags: tags,
                  imagePath: _imagePath,
                audioPath: _audioPath,
                  occlusions: _occlusions,
                  clozeIndex: group,
                ),
              );
        }
      } else {
        context.read<AppData>().addCard(
              widget.deckId,
              Flashcard(
                id: uuid.v4(),
                question: question,
                answer: answer.isNotEmpty
                    ? answer
                    : Cloze.answerFor(question, 1),
                note: note,
                tags: tags,
                imagePath: _imagePath,
                audioPath: _audioPath,
                occlusions: _occlusions,
              ),
            );
      }
    }
    Navigator.pop(context);
  }

  /// Wraps the question's current selection in the next cloze marker.
  void _wrapCloze() {
    final controller = _question;
    final selection = controller.value.selection;
    if (!selection.isValid || selection.isCollapsed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Select some text in the question first.')));
      return;
    }
    final text = controller.text;
    final hidden = text.substring(selection.start, selection.end);
    final wrapped = '{{c${Cloze.nextGroup(text)}::$hidden}}';
    final next =
        TextSelection.collapsed(offset: selection.start + wrapped.length);
    controller.value = controller.value.copyWith(
        text: text.replaceRange(selection.start, selection.end, wrapped),
        selection: next,
        composing: TextRange.empty);
    setState(() {});
    FocusScope.of(context).requestFocus(_questionFocus);
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

  /// Full preview of the card as it will look when studied: the
  /// question with any cloze blanked, the image, playable audio and
  /// the formatted answer.
  void _preview() {
    if (_question.text.trim().isEmpty && _answer.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Type a question or answer to preview.')));
      return;
    }
    final group = widget.card?.clozeIndex ?? 1;
    final hasCloze = Cloze.hasCloze(_question.text);
    final answer = _answer.text.isEmpty && hasCloze
        ? Cloze.answerFor(_question.text, group)
        : _answer.text;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Preview'),
        scrollable: true,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(hasCloze ? Cloze.blanked(_question.text, group) : _question.text,
                style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (_imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(_imagePath!),
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink()),
              ),
            if (_audioPath != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: OutlinedButton.icon(
                  onPressed: () => CardAudio.play(_audioPath!),
                  icon: const Icon(Icons.volume_up_rounded),
                  label: const Text('Play audio'),
                ),
              ),
            const Divider(height: 24),
            RichAnswer(
              text: answer,
              style:
                  Theme.of(ctx).textTheme.bodyLarge ?? const TextStyle(),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close')),
        ],
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
              focusNode: _questionFocus,
              decoration: const InputDecoration(
                  labelText: 'Question (front)',
                  border: OutlineInputBorder(),
                  hintText: 'Question'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Question is required' : null,
            ),
            const SizedBox(height: 16),
            // Formatting toolbar: styles the answer's current selection.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Cloze: blank the selected text',
                    icon: const Icon(Icons.visibility_off_rounded),
                    visualDensity: VisualDensity.compact,
                    onPressed: _wrapCloze,
                  ),
                  _formatButton(Icons.format_bold_rounded, 'Bold',
                      () => RichMarkup.toggleWrap(_answer, '**', '**')),
                  _formatButton(Icons.format_italic_rounded, 'Italic',
                      () => RichMarkup.toggleWrap(_answer, '*', '*')),
                  _formatButton(Icons.format_underline_rounded, 'Underline',
                      () => RichMarkup.toggleWrap(_answer, '__', '__')),
                  _formatButton(Icons.format_list_bulleted_rounded, 'Bullet list',
                      () => _toggleLinePrefix('- ')),
                  _formatButton(Icons.format_list_numbered_rounded, 'Numbered list',
                      () => _toggleLinePrefix('1. ')),
                  _formatButton(Icons.format_indent_decrease_rounded,
                      'Indent backward', () => _indentLine(-1)),
                  _formatButton(Icons.format_indent_increase_rounded,
                      'Indent forward', () => _indentLine(1)),
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
            ),
            TextFormField(
              controller: _answer,
              focusNode: _answerFocus,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Answer (back)',
                  border: OutlineInputBorder(),
                  hintText: 'Answer'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) &&
                          !Cloze.hasCloze(_question.text)
                      ? 'Answer is required, or add a cloze blank'
                      : null,
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
                  onPressed: _attachMenu,
                  icon: const Icon(Icons.attach_file_rounded),
                  label: const Text('Add attachment'),
                ),
              ),
            if (_imagePath != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _editOcclusions,
                  icon: const Icon(Icons.crop_free_rounded, size: 18),
                  label: Text(_occlusions.isEmpty
                      ? 'Hide parts of image'
                      : '${_occlusions.length ~/ 4} region(s) hidden'),
                ),
              ),
            if (_imagePath != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _attachMenu,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add another attachment'),
                ),
              ),
            if (_audioPath != null) ...[
              Row(
                children: [
                  const Icon(Icons.graphic_eq_rounded, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Audio attached'),
                  ),
                  IconButton(
                    tooltip: 'Play',
                    icon: const Icon(Icons.play_arrow_rounded),
                    onPressed: () => CardAudio.play(_audioPath!),
                  ),
                  IconButton(
                    tooltip: 'Remove audio',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => setState(() => _audioPath = null),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _preview,
                    icon: const Icon(Icons.visibility_rounded),
                    label: const Text('Preview'),
                  ),
                ),
                if (data.ttsEnabled) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Tts.speak(
                          '${Cloze.stripped(_question.text)} ... ${RichMarkup.stripMarkup(_answer.text)}'),
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
