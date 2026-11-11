import 'package:flutter_test/flutter_test.dart';
import 'package:oncard/ui/cloze.dart';

void main() {
  test('detects numbered and bare cloze markers', () {
    expect(Cloze.hasCloze('{{c1::four}} chambers'), isTrue);
    expect(Cloze.hasCloze('{{four}} chambers'), isTrue);
    expect(Cloze.hasCloze('plain question'), isFalse);
  });

  test('groups collects distinct deletion numbers sorted', () {
    expect(Cloze.groups('a {{c2::x}} b {{c1::y}} {{c2::z}}'), [1, 2]);
    expect(Cloze.groups('a {{x}} b {{y}}'), [1]);
  });

  test('nextGroup returns one past the highest', () {
    expect(Cloze.nextGroup('{{c2::x}} {{c1::y}}'), 3);
    expect(Cloze.nextGroup('no cloze here'), 1);
  });

  test('answerFor joins the hidden text of one group', () {
    const t = '{{c1::Rwanda}} borders {{c2::Tanzania}} and {{c1::DRC}}';
    expect(Cloze.answerFor(t, 1), 'Rwanda / DRC');
    expect(Cloze.answerFor(t, 2), 'Tanzania');
  });

  test('blanked hides only the card group', () {
    const t = 'The heart has {{c1::four}} chambers.';
    expect(Cloze.blanked(t, 1), 'The heart has [ \u2026 ] chambers.');
  });

  test('stripped removes markers for TTS and previews', () {
    expect(Cloze.stripped('{{c1::four}} chambers'), 'four chambers');
  });
}
