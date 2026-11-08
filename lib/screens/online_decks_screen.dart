import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../anki_import.dart';
import '../app_data.dart';
import '../online_decks.dart';

/// Searches AnkiWeb shared decks and imports a picked deck in place.
class OnlineDecksScreen extends StatefulWidget {
  const OnlineDecksScreen({super.key});

  @override
  State<OnlineDecksScreen> createState() => _OnlineDecksScreenState();
}

class _OnlineDecksScreenState extends State<OnlineDecksScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _searching = false;
  String? _error;
  List<OnlineDeck> _results = const <OnlineDeck>[];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_controller.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final results = await searchOnlineDecks(_controller.text);
      if (!mounted) return;
      setState(() {
        _results = results;
        _searching = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _error = err is OnlineDeckException
            ? err.message
            : 'Search failed. Check your connection.';
      });
    }
  }

  Future<void> _openDetails(OnlineDeck deck) async {
    setState(() {
      _searching = true;
      _error = null;
    });
    final OnlineDeckInfo info;
    try {
      info = await fetchOnlineDeckInfo(deck.id);
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _error = err is OnlineDeckException
            ? err.message
            : 'Could not load this deck. Try again.';
      });
      return;
    }
    if (!mounted) return;
    setState(() => _searching = false);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(info.title.isEmpty ? deck.title : info.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                  '${deck.notes} cards · ${deck.thumbsUp} likes' +
                      (info.sizeBytes > 0 ? ' · ${_sizeLabel(info.sizeBytes)}' : ''),
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: SingleChildScrollView(
                  child: Text(
                      info.description.trim().isEmpty
                          ? 'No description was provided for this deck.'
                          : _plainText(info.description),
                      style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download deck'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _download(deck, info);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _download(OnlineDeck deck, OnlineDeckInfo info) async {
    final data = context.read<AppData>();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Downloading deck'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Fetching and importing...'),
            ],
          ),
        ),
      ),
    );
    try {
      final bytes = await downloadOnlineDeck(deck.id, info.downloadKey);
      final outcome = await importAnkiPackageBytes(bytes, data);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(outcome.error != null
              ? outcome.error!
              : (outcome.imported > 0
                  ? 'Imported ${outcome.imported} cards'
                  : 'No importable cards found in that deck.'))));
    } catch (err) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err is OnlineDeckException
              ? err.message
              : 'Download failed. Try again.')));
    }
  }

  String _sizeLabel(int bytes) {
    final mb = bytes / (1024 * 1024);
    if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
    return '${(bytes / 1024).round()} KB';
  }

  String _plainText(String raw) {
    var text = raw.replaceAll(RegExp(r'<[^>]*>'), ' ');
    text = text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#39;', "'")
        .replaceAll('&quot;', '"');
    return text.trim();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget body;
    if (_searching) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = _Message(
          icon: Icons.cloud_off_rounded,
          title: 'Could not search',
          subtitle: _error!);
    } else if (_results.isEmpty) {
      body = _Message(
          icon: Icons.travel_explore_rounded,
          title: 'Search shared decks',
          subtitle:
              'Search thousands of free shared Anki decks and import them straight into Oncard.');
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _results.length,
        itemBuilder: (context, i) {
          final deck = _results[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: cs.surfaceContainerLow,
            child: ListTile(
              title: Text(deck.title,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${deck.notes} cards · ${deck.thumbsUp} likes'),
              trailing: const Icon(Icons.download_rounded),
              onTap: () => _openDetails(deck),
            ),
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Search decks online')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Search shared Anki decks',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  tooltip: 'Search',
                  icon: const Icon(Icons.arrow_forward_rounded),
                  onPressed: _search,
                ),
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
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Message({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 44, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
