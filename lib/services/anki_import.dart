import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../data/app_data.dart';
import '../data/models.dart';

final RegExp _imgRegex = RegExp('<img[^>]+src="([^"]+)"');
final RegExp _sndRegex = RegExp(r'\[sound:([^\]]+)\]');

const List<String> _deckIconChoices = <String>[
  'lucide:layers',
  'lucide:book-open',
  'lucide:brain',
  'lucide:graduation-cap',
];

/// Result of importing an .apkg from raw bytes.
class AnkiImportOutcome {
  final int imported;
  final String? error;
  const AnkiImportOutcome(this.imported, this.error);
}

/// Imports an .apkg from raw bytes and adds its notes as decks.
/// Images and audio referenced by the notes are extracted into the
/// app folders so they survive without Anki.
Future<AnkiImportOutcome> importAnkiPackageBytes(
    List<int> bytes, AppData data) async {
  Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(bytes);
  } catch (_) {
    return const AnkiImportOutcome(
        0, 'That file is not a valid Anki package.');
  }

  // media json: zip entry name -> real file name.
  final mediaMap = <String, String>{};
  for (final f in archive) {
    if (f.name == 'media') {
      try {
        final map =
            jsonDecode(utf8.decode(f.content)) as Map<String, dynamic>;
        map.forEach((k, v) => mediaMap[k] = v.toString());
      } catch (_) {
        // Tolerate a broken media map: cards import without files.
      }
    }
  }

  ArchiveFile? dbFile;
  for (final name in <String>[
    'collection.anki21',
    'collection.anki2',
  ]) {
    for (final f in archive) {
      if (f.name == name) {
        dbFile = f;
        break;
      }
    }
    if (dbFile != null) break;
  }
  if (dbFile == null) {
    return const AnkiImportOutcome(
        0, 'This .apkg uses a newer Anki format. Export it as a legacy deck.');
  }

  final tmp = await getTemporaryDirectory();
  final dbPath = tmp.path + '/anki_import.sqlite';
  final dbFileOut = File(dbPath);
  dbFileOut.writeAsBytesSync(dbFile.content);
  Database db;
  try {
    db = sqlite3.open(dbPath);
  } catch (_) {
    dbFileOut.deleteSync();
    return const AnkiImportOutcome(0, 'Could not read the Anki collection.');
  }

  var imported = 0;
  try {
    // Deck names live as JSON in the col table.
    final decksJson =
        jsonDecode(db.select('select decks from col').first[0] as String)
            as Map<String, dynamic>;
    final deckNames = <String, String>{'1': 'Default'};
    decksJson.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        deckNames[key] = (value['name'] as String?) ?? 'Deck';
      }
    });

    // Which decks each note appears in, via the cards table.
    final noteDecks = <String, List<String>>{};
    for (final row in db.select('select nid, did from cards')) {
      final nid = row[0].toString();
      final did = row[1].toString();
      noteDecks.putIfAbsent(nid, () => <String>[]).add(did);
    }

    // Stage media files on disk so images and audio can be copied.
    final mediaDir = Directory(tmp.path + '/anki_media')
      ..createSync(recursive: true);
    final mediaByName = <String, String>{};
    for (final entry in mediaMap.entries) {
      for (final f in archive) {
        if (f.name == entry.key) {
          final path = mediaDir.path + '/' + _safeName(entry.value);
          File(path).writeAsBytesSync(f.content);
          mediaByName[entry.value] = path;
          break;
        }
      }
    }

    final docs = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(docs.path + '/card-images')
      ..createSync(recursive: true);
    final audioDir = Directory(docs.path + '/card-audio')
      ..createSync(recursive: true);
    final stamp = DateTime.now().millisecondsSinceEpoch;

    for (final row in db.select('select id, flds, tags from notes')) {
      final nid = row[0].toString();
      final fields = row[1].toString().split('\u001f');
      final tags = row[2]
          .toString()
          .trim()
          .split(RegExp(' +'))
          .where((t) => t.isNotEmpty)
          .map((t) => t.toLowerCase())
          .toList();

      final frontRaw = fields.isNotEmpty ? fields[0] : '';
      final backRaw = fields.length > 1 ? fields[1] : '';
      var front = _ankiFieldToText(frontRaw);
      final back = _ankiFieldToText(backRaw);
      if (front.isEmpty && back.isEmpty) continue;

      // Media: first image and first audio anywhere in the note.
      String? imagePath;
      String? audioPath;
      for (final m in _imgRegex.allMatches(frontRaw + backRaw)) {
        final src = mediaByName[m.group(1)];
        if (src == null) continue;
        final saved = await _copyMedia(src, imagesDir,
            'anki_' + stamp.toString() + '_' + _safeName(m.group(1)!));
        imagePath = saved;
        break;
      }
      for (final m in _sndRegex.allMatches(frontRaw + backRaw)) {
        final src = mediaByName[m.group(1)];
        if (src == null) continue;
        final saved = await _copyMedia(src, audioDir,
            'anki_' + stamp.toString() + '_' + _safeName(m.group(1)!));
        audioPath = saved;
        break;
      }

      if (front.isEmpty) front = 'What does this card show?';

      // Deck: first deck this note appears in, by name.
      var deckName = 'Anki Import';
      final dids = noteDecks[nid];
      if (dids != null && dids.isNotEmpty) {
        final raw = deckNames[dids.first] ?? 'Anki Import';
        deckName = raw.split('::').last.trim();
        if (deckName.isEmpty) deckName = 'Anki Import';
      }

      final card = Flashcard(
        id: 'anki-' + nid,
        question: front,
        answer: back,
        tags: tags,
        imagePath: imagePath,
        audioPath: audioPath,
      );

      final deckId = _ensureDeck(data, deckName);
      data.addCards(deckId, <Flashcard>[card]);
      imported++;
    }
  } finally {
    db.dispose();
    try {
      dbFileOut.deleteSync();
    } catch (_) {}
  }
  return AnkiImportOutcome(imported, null);
}

/// Picks an .apkg file and imports its notes as decks.
Future<int> importAnkiPackage(BuildContext context, AppData data) async {
  final picked = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: <String>['apkg'],
    withData: true,
  );
  final bytes = picked?.files.single.bytes;
  if (bytes == null) return 0;
  final outcome = await importAnkiPackageBytes(bytes, data);
  if (outcome.error != null) {
    _snack(context, outcome.error!);
    return 0;
  }
  return outcome.imported;
}

/// Finds or creates a deck by name, ignoring case.
String _ensureDeck(AppData data, String name) {
  for (final deck in data.decks) {
    if (deck.name.toLowerCase() == name.toLowerCase()) return deck.id;
  }
  final hash = name.hashCode.abs();
  data.addDeck(
      name, _deckIconChoices[hash % _deckIconChoices.length], hash % 6);
  return data.decks.last.id;
}

Future<String> _copyMedia(String src, Directory dir, String name) async {
  final target = File(dir.path + '/' + name);
  return File(src).copy(target.path).then((f) => f.path);
}

String _safeName(String name) =>
    name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

/// Strips HTML but keeps line structure.
String _ankiFieldToText(String html) {
  var text = html
      .replaceAll('<br>', '\n')
      .replaceAll('<br/>', '\n')
      .replaceAll('<br />', '\n')
      .replaceAll('</div>', '\n')
      .replaceAll('</p>', '\n')
      .replaceAll(RegExp(r'<[^>]+>'), ' ');
  text = text
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&mdash;', '-')
      .replaceAll('&ndash;', '-');
  return text
      .split('\n')
      .map((l) => l.trim())
      .join('\n')
      .trim();
}

void _snack(BuildContext context, String message) {
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
