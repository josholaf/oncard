class Flashcard {
  final String id;
  String question;
  String answer;
  String note;
  List<String> tags;

  /// 0 = new, 5 = mastered. "Know" raises it, "Again" resets it.
  int mastery;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.note = '',
    List<String>? tags,
    this.mastery = 0,
  }) : tags = tags ?? const <String>[];

  bool get mastered => mastery >= 4;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'question': question,
        'answer': answer,
        'note': note,
        'tags': tags,
        'mastery': mastery,
      };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
        id: json['id'] as String,
        question: json['question'] as String,
        answer: json['answer'] as String,
        note: (json['note'] as String?) ?? '',
        tags: (json['tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[],
        mastery: (json['mastery'] as int?) ?? 0,
      );
}

class Deck {
  final String id;
  String name;
  String icon;
  int colorIndex;
  List<Flashcard> cards;

  Deck({
    required this.id,
    required this.name,
    this.icon = '📚',
    this.colorIndex = 0,
    List<Flashcard>? cards,
  }) : cards = cards ?? <Flashcard>[];

  double get progress {
    if (cards.isEmpty) return 0;
    final masteredCount = cards.where((c) => c.mastered).length;
    return masteredCount / cards.length;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'icon': icon,
        'colorIndex': colorIndex,
        'cards': cards.map((c) => c.toJson()).toList(),
      };

  factory Deck.fromJson(Map<String, dynamic> json) => Deck(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: (json['icon'] as String?) ?? '📚',
        colorIndex: (json['colorIndex'] as int?) ?? 0,
        cards: (json['cards'] as List<dynamic>?)
                ?.map((e) => Flashcard.fromJson(e as Map<String, dynamic>))
                .toList() ??
            <Flashcard>[],
      );
}
