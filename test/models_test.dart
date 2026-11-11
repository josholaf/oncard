import 'package:flutter_test/flutter_test.dart';

import 'package:oncard/data/models.dart';
import 'package:oncard/data/sample_decks.dart';
import 'package:oncard/data/scheduler.dart';

void main() {
  test('flashcard survives a JSON round trip', () {
    final card = Flashcard(
      id: 'a',
      question: 'What is the entrypoint of a Flutter app?',
      answer: 'The main() function, which calls runApp().',
      note: 'Basics',
      tags: <String>['flutter', 'dart'],
      imagePath: '/tmp/x.png',
      due: 1730000000000,
      stability: 5.5,
      ease: 2.4,
      reps: 7,
      lapses: 1,
    );
    final copy = Flashcard.fromJson(card.toJson());
    expect(copy.id, 'a');
    expect(copy.question, card.question);
    expect(copy.answer, card.answer);
    expect(copy.note, card.note);
    expect(copy.tags, card.tags);
    expect(copy.imagePath, card.imagePath);
    expect(copy.due, card.due);
    expect(copy.stability, card.stability);
    expect(copy.ease, card.ease);
    expect(copy.reps, card.reps);
    expect(copy.lapses, card.lapses);
  });

  test('v1 mastery data migrates into stability', () {
    final legacy = Flashcard.fromJson(<String, dynamic>{
      'id': 'old',
      'question': 'q',
      'answer': 'a',
      'mastery': 5,
    });
    expect(legacy.stability, 21);
    expect(legacy.mastered, isTrue);
    expect(legacy.masteryDots, 5);
  });

  test('deck progress counts mastered cards', () {
    final deck = Deck(id: 'd', name: 'Test');
    deck.cards.add(Flashcard(id: '1', question: 'q', answer: 'a', stability: 30));
    deck.cards.add(Flashcard(id: '2', question: 'q', answer: 'a', stability: 25));
    deck.cards.add(Flashcard(id: '3', question: 'q', answer: 'a'));
    deck.cards.add(Flashcard(id: '4', question: 'q', answer: 'a'));
    expect(deck.progress, 0.5);
  });

  test('deck survives a JSON round trip', () {
    final deck = Deck(id: 'd', name: 'Deck', icon: '🧠', colorIndex: 2, favorite: true);
    deck.cards.add(Flashcard(id: 'c1', question: 'q', answer: 'a', stability: 2));
    final copy = Deck.fromJson(deck.toJson());
    expect(copy.name, 'Deck');
    expect(copy.icon, '🧠');
    expect(copy.colorIndex, 2);
    expect(copy.favorite, isTrue);
    expect(copy.cards.single.question, 'q');
    expect(copy.cards.single.stability, 2);
  });

  test('scheduler graduates new cards and grows intervals', () {
    final card = Flashcard(id: 'c', question: 'q', answer: 'a');
    expect(card.isNew, isTrue);

    Scheduler.review(card, Grade.good);
    expect(card.reps, 1);
    expect(card.stability, 1);
    expect(card.due, greaterThan(0));

    final before = card.stability;
    Scheduler.review(card, Grade.good);
    expect(card.stability, greaterThan(before));

    final againBefore = card.stability;
    Scheduler.review(card, Grade.again);
    expect(card.lapses, 1);
    expect(card.stability, lessThan(againBefore));

    // A lapse puts the card back into learning, due within the hour.
    final dueInMillis = card.due - DateTime.now().millisecondsSinceEpoch;
    expect(dueInMillis, lessThan(60 * 60 * 1000));
    expect(dueInMillis, greaterThan(0));
  });

  test('day log round trip', () {
    final log = DayLog(date: '2026-11-01', reviewed: 12, correct: 10);
    final copy = DayLog.fromJson(log.toJson());
    expect(copy.date, log.date);
    expect(copy.reviewed, 12);
    expect(copy.correct, 10);
  });

  test('sample decks seed one deck with cards', () {
    final decks = SampleDecks.build();
    expect(decks.length, 1);
    for (final deck in decks) {
      expect(deck.cards, isNotEmpty);
    }
  });
}
