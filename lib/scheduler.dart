import 'models.dart';

/// Four answer grades, Anki style.
enum Grade { again, hard, good, easy }

/// A compact spaced-repetition scheduler in the spirit of FSRS/SM-2.
///
/// Not a full FSRS implementation: it tracks a per-card stability (days the
/// trace is expected to survive) and an ease factor, and adapts both from the
/// grade the user gives. Everything is deterministic and offline.
class Scheduler {
  static const int _minute = 60 * 1000;
  static const int _day = 24 * 60 * 60 * 1000;

  static double _clampEase(double ease) => ease.clamp(1.3, 2.8).toDouble();

  /// Apply a grade to a card, mutating its review state.
  static void review(Flashcard card, Grade grade) {
    final now = DateTime.now().millisecondsSinceEpoch;
    card.reps += 1;

    if (grade == Grade.again) {
      card.lapses += 1;
      card.ease = _clampEase(card.ease - 0.2);
      card.stability = card.reps <= 1 ? 0.02 : 0.4;
      card.due = now + 10 * _minute;
      return;
    }

    if (card.stability < 1) {
      // Learning steps: minutes today, then graduate into days.
      switch (grade) {
        case Grade.hard:
          card.stability = 0.05;
          card.due = now + 10 * _minute;
          break;
        case Grade.good:
          card.ease = _clampEase(card.ease + 0.02);
          card.stability = 1;
          card.due = now + _day;
          break;
        case Grade.easy:
          card.ease = _clampEase(card.ease + 0.15);
          card.stability = 3;
          card.due = now + 3 * _day;
          break;
        case Grade.again:
          break; // handled above
      }
      return;
    }

    // Review steps: interval grows from stability, scaled by the grade.
    final double interval = card.stability;
    switch (grade) {
      case Grade.hard:
        card.ease = _clampEase(card.ease - 0.15);
        card.stability = interval * 1.2;
        break;
      case Grade.good:
        card.ease = _clampEase(card.ease + 0.02);
        card.stability = interval * card.ease;
        break;
      case Grade.easy:
        card.ease = _clampEase(card.ease + 0.15);
        card.stability = interval * card.ease * 1.3;
        break;
      case Grade.again:
        break; // handled above
    }
    card.due = now + (card.stability * _day).round();
  }

  /// Human label for the interval a grade would produce. Used in UI hints.
  static String intervalLabel(Flashcard card, Grade grade) {
    final before = card.stability;
    final beforeDue = card.due;
    review(card, grade);
    final diffDays = (card.due - DateTime.now().millisecondsSinceEpoch) / _day;
    // Roll back: label is a preview only.
    card.stability = before;
    card.due = beforeDue;
    card.reps -= 1;
    if (grade == Grade.again) card.lapses -= 1;
    if (diffDays < 1 / 24) return '<1h';
    if (diffDays < 1) return '${(diffDays * 24).round()}h';
    if (diffDays < 30) return '${diffDays.round()}d';
    return '${(diffDays / 30).round()}mo';
  }
}
