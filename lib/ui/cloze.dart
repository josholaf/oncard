import 'package:flutter/material.dart';

/// Cloze support.
///
/// Markers inside a card question:
///   {{c1::hidden text}}   numbered deletion, Anki style
///   {{hidden text}}       unnumbered, treated as c1
///
/// A question with N distinct deletion numbers expands into N cards,
/// one per number. Each card only blanks its own group while studying;
/// other groups show their text.
final RegExp _clozeRe = RegExp(r'\{\{(?:c(\d+)::)?(.+?)\}\}',
    dotAll: true);

class Cloze {
  static bool hasCloze(String text) => _clozeRe.hasMatch(text);

  /// Distinct deletion numbers in the text, sorted ascending.
  static List<int> groups(String text) {
    final found = <int>{};
    for (final m in _clozeRe.allMatches(text)) {
      found.add(int.tryParse(m.group(1) ?? '') ?? 1);
    }
    final list = found.toList()..sort();
    return list;
  }

  /// The next unused deletion number (one past the current highest).
  static int nextGroup(String text) {
    var max = 0;
    for (final g in groups(text)) {
      if (g > max) max = g;
    }
    return max + 1;
  }

  /// The expected answer for one group: its hidden texts joined.
  /// Used when the card has no explicit answer typed in the editor.
  static String answerFor(String text, int group) {
    final parts = <String>[];
    for (final m in _clozeRe.allMatches(text)) {
      if ((int.tryParse(m.group(1) ?? '') ?? 1) == group) {
        parts.add(m.group(2)!);
      }
    }
    return parts.join(' / ');
  }

  /// Question side: the card group becomes a blank, other groups
  /// show their text as plain words.
  static String blanked(String text, int group) =>
      text.replaceAllMapped(_clozeRe, (m) {
        final g = int.tryParse(m.group(1) ?? '') ?? 1;
        return g == group ? '[ \u2026 ]' : m.group(2)!;
      });

  /// Plain text with every marker removed. For TTS, previews and search.
  static String stripped(String text) =>
      text.replaceAllMapped(_clozeRe, (m) => m.group(2)!);

  /// Reveal side: the card group is bold and underlined, the rest is
  /// plain text, so the full sentence reads correctly.
  static List<TextSpan> revealSpans(String text, int group,
      TextStyle style) {
    final spans = <TextSpan>[];
    var last = 0;
    for (final m in _clozeRe.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      final g = int.tryParse(m.group(1) ?? '') ?? 1;
      final hidden = m.group(2)!;
      spans.add(g == group
          ? TextSpan(
              text: hidden,
              style: style.copyWith(
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
              ))
          : TextSpan(text: hidden));
      last = m.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last)));
    }
    return spans;
  }
}
