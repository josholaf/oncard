import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../data/app_data.dart';
import '../data/models.dart';
import 'share.dart';

void _snack(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));
}

/// CSV/TSV import. Columns: question,answer,note,tags (tags split by ';').
Future<int> importCsvFile(BuildContext context, AppData data, String deckId,
    {bool tsv = false}) async {
  final picked = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: tsv ? <String>['tsv', 'txt'] : <String>['csv'],
    withData: true,
  );
  if (picked == null) return 0;
  final file = picked.files.single;
  final bytes = file.bytes;
  if (bytes == null || bytes.isEmpty) {
    _snack(context, 'Could not read that file. Try a smaller CSV or TSV.');
    return 0;
  }

  List<List<dynamic>> rows;
  try {
    final converter = tsv
        ? const CsvToListConverter(eol: '\n', fieldDelimiter: '\t')
        : const CsvToListConverter(eol: '\n');
    rows = converter.convert(utf8.decode(bytes));
  } catch (_) {
    _snack(context, 'That file is not valid ${tsv ? 'TSV' : 'CSV'}.');
    return 0;
  }

  final cards = <Flashcard>[];
  var first = true;
  var skippedShort = 0;
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
    if (values.length < 2) {
      skippedShort += 1;
      continue;
    }
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
    if (skippedShort > 0) {
      _snack(context,
          'No cards imported. $skippedShort row(s) need at least question and answer columns.');
    } else {
      _snack(context,
          'No cards found. Use columns: question,answer,note,tags');
    }
    return 0;
  }

  data.addCards(deckId, cards);
  final extra = skippedShort > 0
      ? ' ($skippedShort row(s) skipped — need question and answer)'
      : '';
  _snack(context, 'Imported ${cards.length} cards into this deck.$extra');
  return cards.length;
}

/// Export one deck as CSV into the app documents directory.
Future<File> exportDeckCsv(Deck deck) async {
  final dir = await getApplicationDocumentsDirectory();
  final safeName = deck.name.replaceAll(RegExp('[^A-Za-z0-9_-]'), '_');
  final file = File('${dir.path}/oncard_$safeName.csv');
  final rows = <List<String>>[
    <String>['question', 'answer', 'note', 'tags'],
    for (final c in deck.cards)
      <String>[c.question, c.answer, c.note, c.tags.join(';')],
  ];
  await file.writeAsString(const ListToCsvConverter().convert(rows));
  return file;
}

/// Share one deck as a CSV file through the Android share sheet.
Future<bool> shareDeckCsv(Deck deck) async {
  try {
    final file = await exportDeckCsv(deck);
    final content = await file.readAsString();
    final name = file.path.split(Platform.pathSeparator).last;
    return DeckShare.shareFile(name, content);
  } catch (_) {
    return false;
  }
}

/// Write a full JSON backup of every deck plus study history.
Future<File> writeBackupFile(AppData data) async {
  final dir = await getApplicationDocumentsDirectory();
  final stamp = DateTime.now().toIso8601String().split('T').first;
  final file = File('${dir.path}/oncard-backup-$stamp.json');
  await file.writeAsString(data.exportBackup());
  return file;
}

/// Restore a JSON backup picked by the user.
Future<bool> restoreBackupFile(BuildContext context, AppData data) async {
  final picked = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: <String>['json'],
    withData: true,
  );
  if (picked == null) return false;
  final bytes = picked.files.single.bytes;
  if (bytes == null) return false;
  final ok = await data.importBackup(utf8.decode(bytes));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? 'Backup restored.'
            : 'That file is not a valid Oncard backup.')));
  }
  return ok;
}
