/// Domain model for Oncard 2.0.
///
/// Card content (question, answer, note, tags, image) is kept separate from
/// the user's review state (due date, stability, ease, reps, lapses) so that
/// decks can be shared or synced later without leaking personal history.
class Flashcard {
  final String id;

  // Content.
  String question;
  String answer;
  String note;
  List<String> tags;
  String? imagePath;

  /// Optional audio attachment (pronunciation, lecture snippet).
  String? audioPath;

  /// Image occlusion regions: normalized x, y, w, h quadruples.
  List<double> occlusions;

  /// Cloze deletion group this card tests. 1 for non-cloze cards.
  int clozeIndex;

  // Review state.
  /// Epoch milliseconds when this card should be reviewed next.
  int due;
  /// Days until the memory trace is expected to decay. Grows on good grades.
  double stability;
  /// Scheduler ease factor, kept between 1.3 and 2.8.
  double ease;
  int reps;
  int lapses;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.note = '',
    List<String>? tags,
    this.imagePath,
    this.audioPath,
    List<double>? occlusions,
    this.clozeIndex = 1,
    this.due = 0,
    this.stability = 0,
    this.ease = 2.3,
    this.reps = 0,
    this.lapses = 0,
  })  : tags = tags ?? const <String>[],
        occlusions = occlusions ?? const <double>[];

  bool get isNew => reps == 0;

  bool get isDue => DateTime.now().millisecondsSinceEpoch >= due;

  /// A card counts as mastered once it survives three weeks without review.
  bool get mastered => stability >= 21;

  /// 0..5 dots for compact UI indicators. Migrated cards can carry real
  /// stability without recorded reps, so zero reps alone must not hide it.
  int get masteryDots {
    if (reps == 0 && stability <= 0) return 0;
    if (mastered) return 5;
    final dots = (stability / 21 * 5).ceil();
    return dots.clamp(1, 5).toInt();
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'question': question,
        'answer': answer,
        'note': note,
        'tags': tags,
        if (imagePath != null) 'imagePath': imagePath,
        if (audioPath != null) 'audioPath': audioPath,
        if (occlusions.isNotEmpty) 'occlusions': occlusions,
        'due': due,
        'stability': stability,
        'ease': ease,
        'reps': reps,
        'lapses': lapses,
        'clozeIndex': clozeIndex,
      };

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    final stability = (json['stability'] as num?)?.toDouble();
    // Migrate v1 data, which only stored a 0..5 mastery score. Old mastery
    // 4+ counted as mastered, so it maps to a clean 21-day stability.
    final double migrated;
    if (stability != null) {
      migrated = stability;
    } else {
      final oldMastery = (json['mastery'] as int?) ?? 0;
      migrated = oldMastery >= 4 ? 21.0 : oldMastery * 4.2;
    }
    return Flashcard(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      note: (json['note'] as String?) ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
      imagePath: json['imagePath'] as String?,
      audioPath: json['audioPath'] as String?,
      occlusions: (json['occlusions'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const <double>[],
      due: (json['due'] as int?) ?? 0,
      stability: migrated,
      ease: (json['ease'] as num?)?.toDouble() ?? 2.3,
      reps: (json['reps'] as int?) ?? 0,
      lapses: (json['lapses'] as int?) ?? 0,
      clozeIndex: (json['clozeIndex'] as int?) ?? 1,
    );
  }
}

class Deck {
  final String id;
  String name;
  String icon;
  int colorIndex;
  bool favorite;
  int createdAt;
  int lastStudied;
  List<Flashcard> cards;

  Deck({
    required this.id,
    required this.name,
    this.icon = '📚',
    this.colorIndex = 0,
    this.favorite = false,
    int? createdAt,
    this.lastStudied = 0,
    List<Flashcard>? cards,
  })  : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        cards = cards ?? <Flashcard>[];

  int get dueCount =>
      cards.where((c) => c.isDue && !c.mastered).length;

  int get newCount => cards.where((c) => c.isNew).length;

  double get progress {
    if (cards.isEmpty) return 0;
    return cards.where((c) => c.mastered).length / cards.length;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'icon': icon,
        'colorIndex': colorIndex,
        'favorite': favorite,
        'createdAt': createdAt,
        'lastStudied': lastStudied,
        'cards': cards.map((c) => c.toJson()).toList(),
      };

  factory Deck.fromJson(Map<String, dynamic> json) => Deck(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: (json['icon'] as String?) ?? '📚',
        colorIndex: (json['colorIndex'] as int?) ?? 0,
        favorite: (json['favorite'] as bool?) ?? false,
        createdAt: (json['createdAt'] as int?),
        lastStudied: (json['lastStudied'] as int?) ?? 0,
        cards: (json['cards'] as List<dynamic>?)
                ?.map((e) => Flashcard.fromJson(e as Map<String, dynamic>))
                .toList() ??
            <Flashcard>[],
      );
}

/// One day of study activity, used by the statistics screen.
class DayLog {
  final String date;
  int reviewed;
  int correct;

  DayLog({required this.date, this.reviewed = 0, this.correct = 0});

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'date': date, 'reviewed': reviewed, 'correct': correct};

  factory DayLog.fromJson(Map<String, dynamic> json) => DayLog(
        date: json['date'] as String,
        reviewed: (json['reviewed'] as int?) ?? 0,
        correct: (json['correct'] as int?) ?? 0,
      );
}
