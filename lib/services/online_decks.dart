import 'dart:convert';

import 'package:http/http.dart' as http;

/// An error with a message that is safe to show the user.
class OnlineDeckException implements Exception {
  final String message;
  const OnlineDeckException(this.message);
  @override
  String toString() => message;
}

/// One shared deck from the AnkiWeb search results.
class OnlineDeck {
  final int id;
  final String title;
  final int notes;
  final int thumbsUp;
  const OnlineDeck({
    required this.id,
    required this.title,
    required this.notes,
    required this.thumbsUp,
  });
}

/// Details for one shared deck, including its one-time download key.
class OnlineDeckInfo {
  final String title;
  final String description;
  final int sizeBytes;
  final String downloadKey;
  const OnlineDeckInfo({
    required this.title,
    required this.description,
    required this.sizeBytes,
    required this.downloadKey,
  });
}

const Map<String, String> _headers = <String, String>{
  'User-Agent': 'Mozilla/5.0 (Android) Oncard/1.0',
  'Accept': 'application/json',
};

Never _fail(int status) {
  if (status == 429) {
    throw const OnlineDeckException(
        'AnkiWeb is rate limiting. Wait a minute and try again.');
  }
  throw const OnlineDeckException(
      'AnkiWeb is unavailable right now. Try again later.');
}

dynamic _getJson(http.Response response) {
  if (response.statusCode == 429 || response.statusCode >= 500) {
    _fail(response.statusCode);
  }
  if (response.statusCode != 200) {
    throw const OnlineDeckException(
        'AnkiWeb is unavailable right now. Try again later.');
  }
  try {
    return jsonDecode(utf8.decode(response.bodyBytes));
  } catch (_) {
    throw const OnlineDeckException('AnkiWeb returned an unreadable reply.');
  }
}

/// Searches AnkiWeb shared decks by term.
Future<List<OnlineDeck>> searchOnlineDecks(String term) async {
  final query = term.trim();
  if (query.isEmpty) return const <OnlineDeck>[];
  final http.Response response;
  try {
    response = await http
        .get(
            Uri.parse('https://ankiweb.net/svc/shared/list-decks?search=' +
                Uri.encodeQueryComponent(query)),
            headers: _headers)
        .timeout(const Duration(seconds: 20));
  } catch (_) {
    throw const OnlineDeckException(
        'Could not reach AnkiWeb. Check your connection.');
  }
  final body = _getJson(response);
  if (body is! Map) return const <OnlineDeck>[];
  final rows = body['rows'];
  if (rows is! List) return const <OnlineDeck>[];
  final decks = <OnlineDeck>[];
  for (final row in rows) {
    if (row is! Map) continue;
    final id = row['id'];
    final title = row['title'];
    if (id is! int || title is! String || title.isEmpty) continue;
    decks.add(OnlineDeck(
      id: id,
      title: title,
      notes: row['notes'] is int ? row['notes'] as int : 0,
      thumbsUp: row['thumbs_up'] is int ? row['thumbs_up'] as int : 0,
    ));
  }
  return decks;
}

/// Fetches title, description and the one-time download key.
Future<OnlineDeckInfo> fetchOnlineDeckInfo(int id) async {
  final http.Response response;
  try {
    response = await http
        .get(
            Uri.parse('https://ankiweb.net/svc/shared/item-info?sharedId=' +
                id.toString()),
            headers: _headers)
        .timeout(const Duration(seconds: 20));
  } catch (_) {
    throw const OnlineDeckException(
        'Could not reach AnkiWeb. Check your connection.');
  }
  final body = _getJson(response);
  if (body is! Map) {
    throw const OnlineDeckException('This deck is no longer available.');
  }
  final missing = body['missing'] == true || body['access_denied'] == true;
  final available = body['available'];
  if (missing || available is! Map) {
    throw const OnlineDeckException('This deck is no longer available.');
  }
  final downloadKey = _findDownloadKey(available);
  if (downloadKey == null) {
    throw const OnlineDeckException('This deck cannot be downloaded.');
  }
  return OnlineDeckInfo(
    title: available['title'] is String ? available['title'] as String : '',
    description:
        available['description'] is String ? available['description'] as String : '',
    sizeBytes: available['size'] is int ? available['size'] as int : 0,
    downloadKey: downloadKey,
  );
}

String? _findDownloadKey(dynamic node) {
  if (node is Map) {
    final direct = node['download_key'];
    if (direct is String && direct.isNotEmpty) return direct;
    for (final value in node.values) {
      final found = _findDownloadKey(value);
      if (found != null) return found;
    }
  } else if (node is List) {
    for (final value in node) {
      final found = _findDownloadKey(value);
      if (found != null) return found;
    }
  }
  return null;
}

/// Downloads the deck's .apkg bytes using its one-time key.
Future<List<int>> downloadOnlineDeck(int id, String downloadKey) async {
  final http.Response response;
  try {
    response = await http
        .get(
            Uri.parse('https://ankiweb.net/svc/shared/download-deck/' +
                id.toString() +
                '?t=' +
                Uri.encodeQueryComponent(downloadKey)),
            headers: _headers)
        .timeout(const Duration(seconds: 120));
  } catch (_) {
    throw const OnlineDeckException(
        'The download was interrupted. Check your connection.');
  }
  if (response.statusCode != 200) _fail(response.statusCode);
  final bytes = response.bodyBytes;
  if (bytes.length < 4) {
    throw const OnlineDeckException('The downloaded file was empty.');
  }
  return bytes;
}
