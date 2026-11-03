import 'package:flutter/material.dart';

/// Searchable emoji picker for deck icons.
///
/// Emoji are Unicode characters, an open standard free for anyone to use.
/// This file ships its own small curated list so no third-party package is
/// needed. Each entry maps an emoji to search keywords.
const Map<String, String> emojiKeywords = <String, String>{
  '👋': 'wave hello hand greeting',
  '🤝': 'handshake deal agreement',
  '👍': 'thumbs up yes ok approve',
  '👎': 'thumbs down no disapprove',
  '👌': 'ok perfect fine',
  '✌️': 'peace victory',
  '🙌': 'celebrate praise hands',
  '👏': 'clap applause',
  '🙏': 'pray please thanks',
  '💪': 'muscle strong strength',
  '🧠': 'brain mind smart memory',
  '👀': 'eyes look watch',
  '😀': 'smile happy',
  '😃': 'smile happy',
  '😄': 'smile happy',
  '😁': 'grin smile',
  '😅': 'sweat smile',
  '🤣': 'laugh lol',
  '😂': 'laugh tears lol',
  '🙂': 'slight smile',
  '😉': 'wink',
  '😊': 'blush smile shy',
  '😍': 'heart eyes love',
  '🤔': 'think hmm',
  '🤨': 'eyebrow skeptical',
  '😐': 'neutral meh',
  '😴': 'sleep tired bored',
  '🥳': 'party celebrate',
  '😎': 'cool sunglasses',
  '🤓': 'nerd glasses smart',
  '🧐': 'monocle inspect',
  '😕': 'confused',
  '🙁': 'sad frown',
  '😮': 'wow surprise',
  '😱': 'shock scream',
  '🤯': 'mind blown',
  '😤': 'determined',
  '😭': 'cry sad tears',
  '😡': 'angry mad',
  '🤗': 'hug',
  '🤫': 'quiet secret',
  '🤥': 'lie pinocchio',
  '🙈': 'monkey see',
  '❤️': 'heart love red',
  '🧡': 'heart orange',
  '💛': 'heart yellow',
  '💚': 'heart green',
  '💙': 'heart blue',
  '💜': 'heart purple',
  '🖤': 'heart black',
  '🤍': 'heart white',
  '💔': 'broken heart',
  '⭐': 'star favorite',
  '🌟': 'star glow',
  '✨': 'sparkles shine',
  '⚡': 'lightning energy fast',
  '🔥': 'fire hot streak',
  '💧': 'water drop',
  '🌈': 'rainbow colors',
  '☀️': 'sun sunny day',
  '🌙': 'moon night',
  '☁️': 'cloud weather',
  '❄️': 'snow cold winter',
  '🌸': 'flower blossom spring sakura',
  '🌹': 'rose flower',
  '🌻': 'sunflower',
  '🍀': 'clover luck lucky',
  '🌿': 'plant leaf green',
  '🌍': 'earth world globe',
  '🌋': 'volcano',
  '⛰️': 'mountain',
  '🏖️': 'beach',
  '🏝️': 'island',
  '🐱': 'cat kitten',
  '🐶': 'dog puppy',
  '🐭': 'mouse',
  '🐰': 'rabbit bunny',
  '🦊': 'fox',
  '🐻': 'bear',
  '🐼': 'panda',
  '🦁': 'lion',
  '🐯': 'tiger',
  '🐨': 'koala',
  '🐮': 'cow',
  '🐷': 'pig',
  '🐸': 'frog',
  '🐵': 'monkey',
  '🦉': 'owl',
  '🦅': 'eagle',
  '🦄': 'unicorn',
  '🐝': 'bee',
  '🦋': 'butterfly',
  '🐢': 'turtle',
  '🐍': 'snake',
  '🐙': 'octopus',
  '🦀': 'crab',
  '🐬': 'dolphin',
  '🐳': 'whale',
  '🦈': 'shark',
  '🐠': 'fish tropical',
  '🐔': 'chicken',
  '🦖': 'dinosaur trex',
  '🐾': 'paw prints',
  '📚': 'books library study',
  '📖': 'book open reading',
  '📗': 'book green',
  '📘': 'book blue',
  '📙': 'book orange',
  '📕': 'book red',
  '📓': 'notebook',
  '📒': 'ledger journal',
  '📔': 'journal notebook',
  '📝': 'note write memo',
  '✏️': 'pencil write',
  '🖊️': 'pen write',
  '🖍️': 'crayon',
  '📄': 'page document',
  '📋': 'clipboard list',
  '📁': 'folder files',
  '🗂️': 'divider organize',
  '🗞️': 'newspaper news',
  '📰': 'newspaper news',
  '🔖': 'bookmark save',
  '🏷️': 'tag label',
  '🎓': 'graduation cap study university',
  '🏫': 'school building',
  '🔬': 'microscope science',
  '🧪': 'test tube chemistry',
  '🧬': 'dna biology',
  '⚗️': 'alembic chemistry',
  '🔭': 'telescope astronomy',
  '🪐': 'planet space',
  '🧮': 'abacus math',
  '📐': 'triangle ruler geometry math',
  '📏': 'ruler measure',
  '✂️': 'scissors cut',
  '📌': 'pin pushpin',
  '📎': 'paperclip',
  '🔒': 'lock secure',
  '🔑': 'key',
  '💰': 'money bag',
  '💵': 'dollar cash',
  '💎': 'diamond gem',
  '⚖️': 'scales balance law',
  '🩺': 'stethoscope medicine doctor',
  '💊': 'pill medicine',
  '💉': 'syringe vaccine',
  '🦷': 'tooth dental',
  '🚀': 'rocket launch fast space',
  '✈️': 'plane travel flight',
  '🚗': 'car',
  '🚲': 'bike bicycle',
  '⛵': 'sailboat',
  '🗺️': 'map geography',
  '🧭': 'compass navigation',
  '🏠': 'house home',
  '🏢': 'office building',
  '🏰': 'castle',
  '⛪': 'church',
  '🗽': 'statue liberty',
  '🗼': 'tower tokyo',
  '🎡': 'ferris wheel park',
  '🎮': 'game controller play',
  '🎲': 'dice game',
  '♟️': 'chess pawn strategy',
  '🎯': 'dart target goal',
  '🏆': 'trophy win champion',
  '🥇': 'medal gold first',
  '🎉': 'party celebrate tada',
  '🎁': 'gift present',
  '🎈': 'balloon',
  '🎵': 'music note',
  '🎸': 'guitar music',
  '🎹': 'piano keyboard music',
  '🎨': 'art palette paint',
  '🎭': 'theater masks drama',
  '🎬': 'clapper film movie',
  '📷': 'camera photo',
  '📺': 'tv television',
  '💻': 'laptop computer coding',
  '🖥️': 'desktop computer',
  '⌨️': 'keyboard typing',
  '🖱️': 'mouse computer',
  '📱': 'phone mobile',
  '🔋': 'battery energy',
  '💡': 'bulb idea',
  '🔧': 'wrench tool fix',
  '🔨': 'hammer tool build',
  '⚙️': 'gear settings',
  '🧩': 'puzzle piece',
  '🛠️': 'tools build',
  '⏰': 'alarm clock time',
  '⏳': 'hourglass time',
  '📅': 'calendar date schedule',
  '📆': 'calendar days',
  '📈': 'chart up growth stats',
  '📉': 'chart down',
  '📊': 'bar chart stats',
  '👇': 'point down',
  '👉': 'point right',
  '☝️': 'point up',
  '🚩': 'flag red',
  '🏁': 'checkered flag finish',
  '🔁': 'repeat loop',
  '🔂': 'repeat once',
  '🔄': 'refresh cycle',
  '1️⃣': 'one number',
  '2️⃣': 'two number',
  '3️⃣': 'three number',
  '❓': 'question',
  '❗': 'exclamation important',
  '✅': 'check yes done correct',
  '❌': 'cross no wrong',
  '🚫': 'forbidden stop',
  '♻️': 'recycle',
  '🆗': 'ok button',
};

/// Opens a rounded bottom sheet with a searchable emoji grid.
/// Returns the chosen emoji, or null when dismissed.
Future<String?> showEmojiPickerSheet(BuildContext context,
    {String current = '👋'}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: _EmojiPickerSheet(current: current),
    ),
  );
}

class _EmojiPickerSheet extends StatefulWidget {
  final String current;
  const _EmojiPickerSheet({required this.current});

  @override
  State<_EmojiPickerSheet> createState() => _EmojiPickerSheetState();
}

class _EmojiPickerSheetState extends State<_EmojiPickerSheet> {
  final _search = TextEditingController();
  late List<String> _matches =
      emojiKeywords.keys.toList(growable: false);

  @override
  void initState() {
    super.initState();
    _search.addListener(_filter);
  }

  @override
  void dispose() {
    _search.removeListener(_filter);
    _search.dispose();
    super.dispose();
  }

  void _filter() {
    final q = _search.text.trim().toLowerCase();
    setState(() {
      _matches = q.isEmpty
          ? emojiKeywords.keys.toList(growable: false)
          : emojiKeywords.entries
              .where((e) =>
                  e.key.contains(q) || e.value.contains(q))
              .map((e) => e.key)
              .toList(growable: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                controller: _search,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Search emoji, e.g. cat, book, heart',
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
            Expanded(
              child: _matches.isEmpty
                  ? const Center(
                      child: Text('No emoji match that search.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6, childAspectRatio: 1),
                      itemCount: _matches.length,
                      itemBuilder: (context, i) {
                        final emoji = _matches[i];
                        final selected = emoji == widget.current;
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.pop(context, emoji),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: selected
                                  ? cs.primaryContainer
                                  : null,
                              border: selected
                                  ? null
                                  : Border.all(color: cs.outline),
                            ),
                            child: Center(
                                child: Text(emoji,
                                    style: const TextStyle(fontSize: 24))),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
