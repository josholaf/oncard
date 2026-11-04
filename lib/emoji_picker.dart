import 'package:flutter/material.dart';

import 'lucide_icons.dart';

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
  '🍕': 'pizza food italian',
  '🍔': 'burger food fast',
  '🍟': 'fries food',
  '🌭': 'hotdog food',
  '🍿': 'popcorn movie snack',
  '🥐': 'croissant breakfast',
  '🥖': 'bread bakery baguette',
  '🥗': 'salad healthy food',
  '🍜': 'noodles ramen food',
  '🍣': 'sushi japanese food',
  '🍩': 'donut sweet',
  '🍪': 'cookie sweet',
  '🍦': 'ice cream dessert',
  '🍫': 'chocolate sweet',
  '🍎': 'apple fruit red',
  '🍌': 'banana fruit',
  '🍇': 'grapes fruit',
  '🍉': 'watermelon fruit',
  '🍓': 'strawberry fruit',
  '🍒': 'cherry fruit',
  '🥑': 'avocado food',
  '🥕': 'carrot vegetable',
  '🌽': 'corn vegetable',
  '⚽': 'soccer football sport',
  '🏀': 'basketball sport',
  '🏉': 'football sport',
  '⚾': 'baseball sport',
  '🎾': 'tennis sport',
  '🏐': 'volleyball sport',
  '🎱': 'pool billiards game',
  '🏓': 'ping pong table tennis',
  '🏸': 'badminton sport',
  '🥊': 'boxing fight sport',
  '🚴': 'cycling bike sport',
  '🏊': 'swimming sport',
  '🏃': 'running sport',
  '🧘': 'yoga meditate calm',
  '⛷️': 'skiing winter sport',
  '🤸': 'gymnastics sport',
  '🐘': 'elephant animal',
  '🦒': 'giraffe animal',
  '🦓': 'zebra animal',
  '🐄': 'cow animal farm',
  '🐎': 'horse animal',
  '🐑': 'sheep animal farm',
  '🦌': 'deer animal',
  '🐓': 'rooster chicken',
  '🦃': 'turkey bird',
  '🦚': 'peacock bird',
  '🦜': 'parrot bird',
  '🐌': 'snail slow',
  '🐛': 'bug caterpillar',
  '🐜': 'ant insect',
  '🦠': 'germ microbe virus',
  '🚄': 'train fast rail',
  '🚂': 'train steam rail',
  '🛵': 'scooter moto',
  '🚕': 'taxi car',
  '🚌': 'bus',
  '🚙': 'suv car',
  '🛶': 'canoe boat',
  '🚁': 'helicopter',
  '🛰️': 'satellite space',
  '⌚': 'watch time',
  '🕶️': 'sunglasses cool',
  '💍': 'ring wedding',
  '🎒': 'backpack school',
  '👗': 'dress fashion',
  '👟': 'sneaker shoe running',
  '🎩': 'hat top hat',
  '☮️': 'peace',
  '☯️': 'yin yang balance',
  '⚛️': 'atom science',
  '🆓': 'free button',
  '🆙': 'up button',
  '💯': 'hundred perfect score',
  '🆒': 'cool button',
  '🆚': 'versus vs',
};

/// Opens a rounded bottom sheet with a searchable emoji and icon grid.
/// Returns the chosen emoji, a 'lucide:<name>' icon reference, or null
/// when dismissed.
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
  bool _icons = false;
  List<String> _emojiMatches = emojiKeywords.keys.toList(growable: false);
  List<String> _iconMatches = kLucideIcons.keys.toList(growable: false);

  @override
  void initState() {
    super.initState();
    if (widget.current.startsWith('lucide:')) _icons = true;
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
      _emojiMatches = q.isEmpty
          ? emojiKeywords.keys.toList(growable: false)
          : emojiKeywords.entries
              .where((e) => e.key.contains(q) || e.value.contains(q))
              .map((e) => e.key)
              .toList(growable: false);
      _iconMatches = kLucideIcons.keys
          .where((name) => name.replaceAll('-', ' ').contains(q))
          .toList(growable: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final matches = _icons ? _iconMatches : _emojiMatches;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Emoji')),
                  ButtonSegment(value: true, label: Text('Icons')),
                ],
                selected: <bool>{_icons},
                onSelectionChanged: (selection) =>
                    setState(() => _icons = selection.first),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _search,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: _icons
                      ? 'Search icons, e.g. book, rocket'
                      : 'Search emoji, e.g. cat, book, heart',
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
              child: matches.isEmpty
                  ? const Center(
                      child: Text('Nothing matches that search.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6, childAspectRatio: 1),
                      itemCount: matches.length,
                      itemBuilder: (context, i) {
                        final item = matches[i];
                        final value = _icons ? 'lucide:' + item : item;
                        final selected = value == widget.current;
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.pop(context, value),
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
                              child: _icons
                                  ? LucideIcon(
                                      name: item,
                                      size: 24,
                                      color: cs.onSurface)
                                  : Text(item,
                                      style:
                                          const TextStyle(fontSize: 24)),
                            ),
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
