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
      deck('sample-physiology', 'Medical Physiology', '🧬', 1, [
        card(
            'What is the normal resting cardiac output in an adult?',
            'About 5 L/min (heart rate 70 bpm x stroke volume 70 mL).'),
        card(
            'Which hormone lowers blood glucose?',
            'Insulin, released by pancreatic beta cells.'),
        card(
            'What is the primary buffer system in extracellular fluid?',
            'The bicarbonate system (HCO3-/CO2), with the lungs and kidneys as partners.'),
        card(
            'Where does most nutrient absorption occur in the GI tract?',
            'The jejunum, followed by the ileum.'),
      ]),
      deck('sample-dart', 'Programming (Dart)', '💻', 3, [
        card(
            'What does the final keyword mean in Dart?',
            'A final variable can be set only once, with its value fixed at runtime.'),
        card(
            'How do List and Set differ?',
            'A List keeps insertion order and allows duplicates. A Set stores only unique items.'),
        card(
            'What is the entrypoint of a Flutter app?',
            'The main() function, which calls runApp() with the root widget.'),
        card(
            'What do async and await do?',
            'async marks a function as returning a Future. await pauses inside it until that Future completes.'),
      ]),
      deck('sample-french', 'French', '🇫🇷', 4, [
        card('Bonjour', 'Hello / Good day'),
        card('Merci beaucoup', 'Thank you very much'),
        card("Comment ça va ?", 'How are you?'),
        card("S'il vous plaît", 'Please'),
      ]),
      deck('sample-japanese', 'Japanese', '🇯🇵', 4, [
        card('おはよう (ohayou)', 'Good morning'),
        card('ありがとう (arigatou)', 'Thank you'),
        card('おねがいします (onegaishimasu)', 'Please (polite)'),
        card('すみません (sumimasen)', 'Excuse me / sorry'),
      ]),
      deck('sample-agriculture', 'Agriculture', '🌱', 5, [
        card(
            'What are the three primary macronutrients plants need?',
            'Nitrogen (N), phosphorus (P), and potassium (K).'),
        card(
            'What is crop rotation and why is it used?',
            'Growing different crops in sequence on the same land to preserve soil health and break pest cycles.'),
        card(
            'Define photosynthesis in one sentence.',
            'Plants convert light energy, water, and CO2 into glucose and oxygen using chlorophyll.'),
        card(
            'What does pH measure in soil?',
            'Acidity or alkalinity on a 0 to 14 scale. Most crops grow best between 6.0 and 7.0.'),
      ]),
    ];
  }
}
