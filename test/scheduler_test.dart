import 'package:flutter_test/flutter_test.dart';
import 'package:oncard/data/models.dart';
import 'package:oncard/data/scheduler.dart';

Flashcard _card({
  double stability = 0,
  double ease = 2.5,
  int reps = 0,
  int lapses = 0,
  int? due,
}) {
  return Flashcard(
    id: 'c1',
    question: 'Q',
    answer: 'A',
    stability: stability,
    ease: ease,
    reps: reps,
    lapses: lapses,
    due: due ?? 0,
  );
}

void main() {
  group('Scheduler.review', () {
    test('Again on new card sets short due and raises lapses', () {
      final card = _card();
      Scheduler.review(card, Grade.again);
      expect(card.reps, 1);
      expect(card.lapses, 1);
      expect(card.ease, lessThan(2.5));
      expect(card.stability, lessThan(1));
      expect(card.due, greaterThan(0));
    });

    test('Good on learning card graduates to about 1 day', () {
      final card = _card(stability: 0.05, reps: 1);
      final before = DateTime.now().millisecondsSinceEpoch;
      Scheduler.review(card, Grade.good);
      expect(card.stability, 1);
      // Roughly one day out
      final days =
          (card.due - before) / (24 * 60 * 60 * 1000);
      expect(days, closeTo(1.0, 0.05));
    });

    test('Easy on learning card sets stability to 3 days', () {
      final card = _card(stability: 0.05, reps: 1);
      Scheduler.review(card, Grade.easy);
      expect(card.stability, 3);
      expect(card.ease, greaterThan(2.5));
    });

    test('Hard on review card slows growth', () {
      final card = _card(stability: 10, ease: 2.5, reps: 5);
      Scheduler.review(card, Grade.hard);
      expect(card.stability, closeTo(12.0, 0.01));
      expect(card.ease, lessThan(2.5));
    });

    test('Good on review card multiplies by ease', () {
      final card = _card(stability: 10, ease: 2.0, reps: 5);
      Scheduler.review(card, Grade.good);
      expect(card.stability, closeTo(20.0, 0.01));
    });

    test('Easy on review card multiplies by ease * 1.3', () {
      final card = _card(stability: 10, ease: 2.0, reps: 5);
      Scheduler.review(card, Grade.easy);
      expect(card.stability, closeTo(26.0, 0.01));
    });

    test('Ease is clamped between 1.3 and 2.8', () {
      final low = _card(stability: 5, ease: 1.35, reps: 3);
      for (var i = 0; i < 10; i++) {
        Scheduler.review(low, Grade.hard);
      }
      expect(low.ease, greaterThanOrEqualTo(1.3));

      final high = _card(stability: 5, ease: 2.7, reps: 3);
      for (var i = 0; i < 10; i++) {
        Scheduler.review(high, Grade.easy);
      }
      expect(high.ease, lessThanOrEqualTo(2.8));
    });
  });

  group('Scheduler.intervalLabel', () {
    test('does not permanently mutate the card', () {
      final card = _card(stability: 5, ease: 2.5, reps: 3, lapses: 1);
      final stab = card.stability;
      final due = card.due;
      final reps = card.reps;
      final lapses = card.lapses;
      final label = Scheduler.intervalLabel(card, Grade.good);
      expect(label.isNotEmpty, isTrue);
      expect(card.stability, stab);
      expect(card.due, due);
      expect(card.reps, reps);
      expect(card.lapses, lapses);
    });

    test('Again label is short interval', () {
      final card = _card(stability: 5, ease: 2.5, reps: 3);
      final label = Scheduler.intervalLabel(card, Grade.again);
      expect(label, anyOf('<1h', '1h', '10m'));
    });
  });
}
