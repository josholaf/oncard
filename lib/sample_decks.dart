import 'package:uuid/uuid.dart';

import 'models.dart';

class SampleDecks {
  static List<Deck> build() {
    const uuid = Uuid();

    Flashcard card(String q, String a,
        [String n = '', List<String> t = const <String>[]]) {
      return Flashcard(id: uuid.v4(), question: q, answer: a, note: n, tags: t);
    }

    Deck deck(String id, String name, String icon, int color,
            List<Flashcard> cards) =>
        Deck(id: id, name: name, icon: icon, colorIndex: color, cards: cards);

    return <Deck>[
      deck('sample-anaesthesia', 'Anaesthesia Basics', '🫀', 2, [
        card(
            'What is the minimum fasting period for solids before elective anaesthesia?',
            '6 hours for solids and 2 hours for clear fluids, per most guidelines.',
            "Always confirm your hospital's protocol."),
        card(
            'Define MAC (Minimum Alveolar Concentration).',
            'The alveolar concentration of an inhaled anaesthetic that prevents movement in 50% of patients responding to a standard surgical stimulus.'),
        card(
            'Which agents are classic triggers of malignant hyperthermia?',
            'Volatile anaesthetics such as halothane, plus succinylcholine. Treat with dantrolene.'),
        card(
            'What is the adult IV dose of atropine for bradycardia?',
            '0.5 to 1 mg IV, repeated every 3 to 5 minutes as needed.'),
      ]),
    ];
  }
}
