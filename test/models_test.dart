import 'package:flutter_test/flutter_test.dart';

import 'package:oncard/models.dart';
import 'package:oncard/sample_decks.dart';

void main() {
  test('flashcard survives a JSON round trip', () {
    final card = Flashcard(
      id: 'a',
      question: 'What is the entrypoint of a Flutter app?',
      answer: 'The main() function, which calls runApp().',
      note: 'Basics',
      tags: <String>['flutter', 'dart'],
      mastery: 3,
    );
    final copy = Flashcard.fromJson(card.toJson());
    expect(copy.id, 'a');
    expect(copy.question, card.question);
    expect(copy.answer, card.answer);
    expect(copy.note, card.note);
    expect(copy.tags, card.tags);
    expect(copy.mastery, 3);
  });

  test('deck progress counts mastered cards', () {
    final deck = Deck(id: 'd', name: 'Test');
    deck.cards.add(Flashcard(id: '1', question: 'q', answer: 'a', mastery: 4));
    deck.cards.add(Flashcard(id: '2', question: 'q', answer: 'a', mastery: 5));
    deck.cards.add(Flashcard(id: '3', question: 'q', answer: 'a', mastery: 0));
    deck.cards.add(Flashcard(id: '4', question: 'q', answer: 'a'));
    expect(deck.progress, 0.5);
  });

  test('deck survives a JSON round trip', () {
    final deck = Deck(id: 'd', name: 'Deck', icon: '🧠', colorIndex: 2);
    deck.cards
        .add(Flashcard(id: 'c1', question: 'q', answer: 'a', mastery: 1));
    final copy = Deck.fromJson(deck.toJson());
    expect(copy.name, 'Deck');
    expect(copy.icon, '🧠');
    expect(copy.colorIndex, 2);
    expect(copy.cards.single.question, 'q');
    expect(copy.cards.single.mastery, 1);
  });

  test('sample decks seed six decks with cards', () {
    final decks = SampleDecks.build();
    expect(decks.length, 6);
    for (final deck in decks) {
      expect(deck.cards, isNotEmpty);
    }
  });
}
