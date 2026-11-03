import 'package:flutter/material.dart';

/// Lightweight inline markup for card answers.
///
/// Supported syntax:
///   **bold**    *italic*    __underline__    ==highlight==
///   ==red: text==            colored highlight (palette names)
///   [red]text[/red]          colored text (red, blue, green, orange, purple)
///
/// Plain answers and markdown-style **bold** / *italic* from imported CSV
/// files render unchanged or styled, so existing cards keep working.
class RichMarkup {
  /// Fixed text palette so answers stay readable in both themes.
  static const Map<String, Color> colors = <String, Color>{
    'red': Color(0xFFD32F2F),
    'blue': Color(0xFF1565C0),
    'green': Color(0xFF2E7D32),
    'orange': Color(0xFFEF6C00),
    'purple': Color(0xFF6750A4),
  };

  /// Soft amber that reads on light and dark surfaces alike.
  static const Color highlight = Color(0x59FFD54F);

  static final RegExp _pattern = RegExp(
    r'\*\*(.+?)\*\*'
    r'|\*(.+?)\*'
    r'|__(.+?)__'
    r'|==(?:(red|blue|green|orange|purple|amber):)?(.+?)=='
    r'|\[(red|blue|green|orange|purple)\](.+?)\[/\6\]',
    dotAll: true,
  );

  /// Parses [text] into styled spans on top of [base].
  static List<InlineSpan> parseSpans(String text, TextStyle base) {
    final spans = <InlineSpan>[];
    var pos = 0;
    for (final m in _pattern.allMatches(text)) {
      if (m.start > pos) {
        spans.add(TextSpan(text: text.substring(pos, m.start)));
      }
      if (m[1] != null) {
        spans.add(TextSpan(
            text: m[1],
            style: base.copyWith(fontWeight: FontWeight.w700)));
      } else if (m[2] != null) {
        spans.add(
            TextSpan(text: m[2], style: base.copyWith(fontStyle: FontStyle.italic)));
      } else if (m[3] != null) {
        spans.add(TextSpan(
            text: m[3],
            style: base.copyWith(decoration: TextDecoration.underline)));
      } else if (m[5] != null) {
        final bg = m[4] != null && colors[m[4]] != null
            ? colors[m[4]]!.withOpacity(0.45)
            : highlight;
        spans.add(
            TextSpan(text: m[5], style: base.copyWith(backgroundColor: bg)));
      } else {
        spans.add(
            TextSpan(text: m[7], style: base.copyWith(color: colors[m[6]])));
      }
      pos = m.end;
    }
    if (pos < text.length) {
      spans.add(TextSpan(text: text.substring(pos)));
    }
    return spans;
  }

  /// Removes markup, leaving only the visible characters.
  static String stripMarkup(String text) => text
      .replaceAllMapped(_pattern, (m) => m[1] ?? m[2] ?? m[3] ?? m[5] ?? m[7] ?? '');

  /// Wraps (or unwraps, if already wrapped) the controller's current
  /// selection with [before] and [after]. An empty selection inserts the
  /// markers and drops the caret between them.
  static void toggleWrap(
      TextEditingController controller, String before, String after) {
    final text = controller.text;
    final sel = controller.selection;
    final s = sel.start < 0 ? text.length : sel.start;
    final e = sel.end < 0 ? text.length : sel.end;
    final selected = text.substring(s, e);

    // Already wrapped: remove the markers instead of doubling them.
    if (selected.length >= before.length + after.length &&
        selected.startsWith(before) &&
        selected.endsWith(after)) {
      final inner = selected.substring(
          before.length, selected.length - after.length);
      controller.value = TextEditingValue(
        text: text.replaceRange(s, e, inner),
        selection: TextSelection.collapsed(offset: s + inner.length),
      );
      return;
    }

    controller.value = TextEditingValue(
      text: text.replaceRange(s, e, '$before$selected$after'),
      selection:
          TextSelection.collapsed(offset: s + before.length + selected.length),
    );
  }
}
