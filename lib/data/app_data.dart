import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'models.dart';
import 'sample_decks.dart';
import 'scheduler.dart';

const uuid = Uuid();

String dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime? parseDayKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) return null;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return null;
  return DateTime(y, m, d);
}

/// Max freezes a user can hold. Keeps the streak meaningful.
const int kMaxStreakFreezes = 2;

/// Streak lengths that grant one freeze (if under the cap).
const List<int> kFreezeMilestones = <int>[7, 30, 100];

class AppData extends ChangeNotifier {
  final SharedPreferences _prefs;
  List<Deck> decks = <Deck>[];
  ThemeMode themeMode = ThemeMode.system;
  int streak = 0;
  String lastStudyDay = '';
  int dailyGoal = 20;
  bool ttsEnabled = false;

  /// Streak freezes held (0..[kMaxStreakFreezes]). Each covers one missed day.
  int freezes = 0;

  /// Last freeze used (for a one-shot UI toast); cleared by [clearFreezeUsedNotice].
  int lastFreezesUsed = 0;

  /// True after a freeze was just earned at a milestone.
  int lastFreezeEarnedAt = 0;

  /// Library view style, remembered between sessions.
  bool libraryGrid = false;
  String librarySort = 'recent';
  bool libraryFavoritesOnly = false;
  bool onboarded = false;
  String displayName = 'Guest';
  String? photoPath;
  List<String> interests = <String>[];
  List<DayLog> history = <DayLog>[];

  /// Latest release found by the update checker (null = up to date).
  String? updateVersion;
  String? updateUrl;

  AppData(this._prefs) {
    _load();
  }

  void _load() {
    final raw = _prefs.getString('oncard.decks');
    if (raw != null && raw.isNotEmpty) {
      try {
        decks = (jsonDecode(raw) as List<dynamic>)
            .map((e) => Deck.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        decks = <Deck>[];
      }
    }
    if (decks.isEmpty) {
      decks = SampleDecks.build();
    }
    streak = _prefs.getInt('oncard.streak') ?? 0;
    lastStudyDay = _prefs.getString('oncard.lastDay') ?? '';
    dailyGoal = _prefs.getInt('oncard.goal') ?? 20;
    ttsEnabled = _prefs.getBool('oncard.tts') ?? false;
    freezes = (_prefs.getInt('oncard.freezes') ?? 0).clamp(0, kMaxStreakFreezes);
    libraryGrid = _prefs.getBool('oncard.libraryGrid') ?? false;
    librarySort = _prefs.getString('oncard.librarySort') ?? 'recent';
    libraryFavoritesOnly = _prefs.getBool('oncard.libraryFav') ?? false;
    onboarded = _prefs.getBool('onboarded') ?? false;
    displayName = _prefs.getString('oncard.name') ?? 'Guest';
    final savedPhoto = _prefs.getString('oncard.photo');
    photoPath = (savedPhoto == null || savedPhoto.isEmpty) ? null : savedPhoto;
    final rawInterests = _prefs.getString('oncard.interests');
    if (rawInterests != null && rawInterests.isNotEmpty) {
      try {
        interests = (jsonDecode(rawInterests) as List<dynamic>)
            .map((e) => e as String)
            .toList();
      } catch (_) {
        interests = <String>[];
      }
    }
    final savedTheme = _prefs.getString('oncard.theme');
    themeMode = savedTheme == 'light'
        ? ThemeMode.light
        : (savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.system);
    final rawHistory = _prefs.getString('oncard.history');
    if (rawHistory != null && rawHistory.isNotEmpty) {
      try {
        history = (jsonDecode(rawHistory) as List<dynamic>)
            .map((e) => DayLog.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        history = <DayLog>[];
      }
    }
    applyPendingFreezes();
    _save();
  }

  Future<void> _save() async {
    await _prefs.setString(
        'oncard.decks', jsonEncode(decks.map((d) => d.toJson()).toList()));
    await _prefs.setString(
        'oncard.history', jsonEncode(history.map((d) => d.toJson()).toList()));
    await _prefs.setInt('oncard.streak', streak);
    await _prefs.setString('oncard.lastDay', lastStudyDay);
    await _prefs.setInt('oncard.freezes', freezes);
  }

  void _persistStreak() {
    _prefs.setInt('oncard.streak', streak);
    _prefs.setString('oncard.lastDay', lastStudyDay);
    _prefs.setInt('oncard.freezes', freezes);
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    _prefs.setString(
        'oncard.theme',
        mode == ThemeMode.light
            ? 'light'
            : (mode == ThemeMode.dark ? 'dark' : 'system'));
    notifyListeners();
  }

  void setDailyGoal(int goal) {
    dailyGoal = goal;
    _prefs.setInt('oncard.goal', goal);
    notifyListeners();
  }

  void setTtsEnabled(bool enabled) {
    ttsEnabled = enabled;
    _prefs.setBool('oncard.tts', enabled);
    notifyListeners();
  }

  void setLibraryGrid(bool grid) {
    libraryGrid = grid;
    _prefs.setBool('oncard.libraryGrid', grid);
    notifyListeners();
  }

  void setLibrarySort(String sort) {
    librarySort = sort;
    _prefs.setString('oncard.librarySort', sort);
    notifyListeners();
  }

  void setLibraryFavoritesOnly(bool only) {
    libraryFavoritesOnly = only;
    _prefs.setBool('oncard.libraryFav', only);
    notifyListeners();
  }

  void completeOnboarding(String name, List<String> selected) {
    displayName = name.isEmpty ? 'Guest' : name;
    interests = selected;
    onboarded = true;
    _prefs.setBool('onboarded', true);
    _prefs.setString('oncard.name', displayName);
    _prefs.setString('oncard.interests', jsonEncode(interests));
    notifyListeners();
  }

  void setDisplayName(String name) {
    displayName = name.isEmpty ? 'Guest' : name;
    _prefs.setString('oncard.name', displayName);
    notifyListeners();
  }

  void setPhoto(String? path) {
    photoPath = (path == null || path.isEmpty) ? null : path;
    _prefs.setString('oncard.photo', path ?? '');
    notifyListeners();
  }

  void signOutGuest() {
    displayName = 'Guest';
    interests = <String>[];
    onboarded = false;
    photoPath = null;
    _prefs.setString('oncard.photo', '');
    _prefs.setString('oncard.name', displayName);
    _prefs.setString('oncard.interests', jsonEncode(interests));
    _prefs.setBool('onboarded', false);
    notifyListeners();
  }

  void setUpdateInfo(String? version, String? url) {
    updateVersion = version;
    updateUrl = url;
    notifyListeners();
  }

  void clearFreezeNotices() {
    lastFreezesUsed = 0;
    lastFreezeEarnedAt = 0;
  }

  Deck? deckById(String id) {
    for (final d in decks) {
      if (d.id == id) return d;
    }
    return null;
  }

  int get totalDue =>
      decks.fold(0, (sum, deck) => sum + deck.dueCount);

  int get totalNew =>
      decks.fold(0, (sum, deck) => sum + deck.newCount);

  int get reviewedToday {
    final today = dayKey(DateTime.now());
    for (final log in history) {
      if (log.date == today) return log.reviewed;
    }
    return 0;
  }

  int get learnedTotal =>
      decks.fold(0, (sum, deck) => sum + deck.cards.where((c) => c.mastered).length);

  bool get streakAtRisk {
    if (streak <= 0 || lastStudyDay.isEmpty) return false;
    final today = dayKey(DateTime.now());
    return lastStudyDay != today;
  }

  Deck? get nextDeckToStudy {
    Deck? best;
    var bestScore = -1;
    for (final deck in decks) {
      final score = deck.dueCount + deck.newCount;
      if (score > bestScore) {
        best = deck;
        bestScore = score;
      }
    }
    return best;
  }

  List<Deck> get recentlyStudied {
    final sorted = <Deck>[...decks]
      ..sort((a, b) => b.lastStudied.compareTo(a.lastStudied));
    return sorted.where((d) => d.lastStudied > 0).take(4).toList();
  }

  int applyPendingFreezes({DateTime? now}) {
    if (lastStudyDay.isEmpty || streak <= 0) return 0;
    final today = now ?? DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final last = parseDayKey(lastStudyDay);
    if (last == null) return 0;

    final daysSince = todayDate.difference(last).inDays;
    if (daysSince <= 1) return 0;

    var missed = daysSince - 1;
    var used = 0;
    while (missed > 0 && freezes > 0) {
      freezes--;
      used++;
      missed--;
    }

    if (used > 0) {
      lastFreezesUsed = used;
    }

    if (missed > 0) {
      streak = 0;
      lastStudyDay = '';
    } else {
      lastStudyDay = dayKey(todayDate.subtract(const Duration(days: 1)));
    }
    _persistStreak();
    return used;
  }

  void _maybeEarnFreeze(int previousStreak, int newStreak) {
    for (final m in kFreezeMilestones) {
      if (previousStreak < m && newStreak >= m && freezes < kMaxStreakFreezes) {
        freezes++;
        lastFreezeEarnedAt = m;
        break;
      }
    }
  }

  void addDeck(String name, String icon, int colorIndex) {
    decks.add(
        Deck(id: uuid.v4(), name: name, icon: icon, colorIndex: colorIndex));
    _save();
    notifyListeners();
  }

  void updateDeck(String id,
      {required String name, required String icon, required int colorIndex}) {
    final deck = deckById(id);
    if (deck == null) return;
    deck.name = name;
    deck.icon = icon;
    deck.colorIndex = colorIndex;
    _save();
    notifyListeners();
  }

  void deleteDeck(String id) {
    decks.removeWhere((d) => d.id == id);
    _save();
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final deck = deckById(id);
    if (deck == null) return;
    deck.favorite = !deck.favorite;
    _save();
    notifyListeners();
  }

  void addCard(String deckId, Flashcard card) {
    deckById(deckId)?.cards.add(card);
    _save();
    notifyListeners();
  }

  void addCards(String deckId, List<Flashcard> cards) {
    deckById(deckId)?.cards.addAll(cards);
    _save();
    notifyListeners();
  }

  void updateCard(String deckId, String cardId,
      {required String question,
      required String answer,
      String note = '',
      String? imagePath,
      String? audioPath,
      List<double>? occlusions,
      List<String>? tags}) {
    final deck = deckById(deckId);
    if (deck == null) return;
    for (final card in deck.cards) {
      if (card.id == cardId) {
        card.question = question;
        card.answer = answer;
        card.note = note;
        card.imagePath = imagePath;
        card.audioPath = audioPath;
        if (occlusions != null) card.occlusions = occlusions;
        if (tags != null) card.tags = tags;
        break;
      }
    }
    _save();
    notifyListeners();
  }

  void deleteCard(String deckId, String cardId) {
    deckById(deckId)?.cards.removeWhere((c) => c.id == cardId);
    _save();
    notifyListeners();
  }

  void deleteCards(String deckId, List<String> cardIds) {
    final deck = deckById(deckId);
    if (deck == null) return;
    final ids = Set<String>.from(cardIds);
    deck.cards.removeWhere((c) => ids.contains(c.id));
    _save();
    notifyListeners();
  }

  void moveCards(String fromDeckId, List<String> cardIds, String toDeckId) {
    final from = deckById(fromDeckId);
    final to = deckById(toDeckId);
    if (from == null || to == null || fromDeckId == toDeckId) return;
    final ids = Set<String>.from(cardIds);
    final moved = from.cards.where((c) => ids.contains(c.id)).toList();
    from.cards.removeWhere((c) => ids.contains(c.id));
    to.cards.addAll(moved);
    _save();
    notifyListeners();
  }

  void editTags(String deckId, List<String> cardIds,
      {required bool add, required String tag}) {
    final deck = deckById(deckId);
    if (deck == null || tag.trim().isEmpty) return;
    final ids = Set<String>.from(cardIds);
    final clean = tag.trim();
    for (final card in deck.cards) {
      if (!ids.contains(card.id)) continue;
      if (add) {
        if (!card.tags.contains(clean)) card.tags = [...card.tags, clean];
      } else {
        card.tags = card.tags.where((t) => t != clean).toList();
      }
    }
    _save();
    notifyListeners();
  }

  void recordReview(String deckId, Flashcard card, Grade grade) {
    Scheduler.review(card, grade);
    final deck = deckById(deckId);
    if (deck != null) {
      deck.lastStudied = DateTime.now().millisecondsSinceEpoch;
    }

    final today = dayKey(DateTime.now());
    final correct = grade != Grade.again;

    DayLog log;
    final existing = history.where((l) => l.date == today).toList();
    if (existing.isEmpty) {
      log = DayLog(date: today);
      history.add(log);
      history.sort((a, b) => a.date.compareTo(b.date));
      if (history.length > 400) history.removeRange(0, history.length - 400);
    } else {
      log = existing.single;
    }
    log.reviewed += 1;
    if (correct) log.correct += 1;

    if (lastStudyDay != today) {
      applyPendingFreezes();

      final previous = streak;
      final yesterday =
          dayKey(DateTime.now().subtract(const Duration(days: 1)));
      if (lastStudyDay == yesterday || lastStudyDay == today) {
        streak = streak <= 0 ? 1 : streak + 1;
      } else if (lastStudyDay.isEmpty) {
        streak = 1;
      } else {
        streak = 1;
      }
      lastStudyDay = today;
      _maybeEarnFreeze(previous, streak);
      _persistStreak();
    }

    _save();
    notifyListeners();
  }

  String exportBackup() => jsonEncode(<String, dynamic>{
        'version': 2,
        'decks': decks.map((d) => d.toJson()).toList(),
        'history': history.map((h) => h.toJson()).toList(),
        'streak': streak,
        'lastStudyDay': lastStudyDay,
        'dailyGoal': dailyGoal,
        'freezes': freezes,
      });

  Future<bool> importBackup(String json) async {
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      final imported = (data['decks'] as List<dynamic>?)
              ?.map((e) => Deck.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <Deck>[];
      if (imported.isEmpty) return false;
      decks = imported;
      history = (data['history'] as List<dynamic>?)
              ?.map((e) => DayLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <DayLog>[];
      streak = (data['streak'] as int?) ?? streak;
      lastStudyDay = (data['lastStudyDay'] as String?) ?? lastStudyDay;
      dailyGoal = (data['dailyGoal'] as int?) ?? dailyGoal;
      freezes = ((data['freezes'] as int?) ?? freezes)
          .clamp(0, kMaxStreakFreezes);
      await _save();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void resetAll() {
    decks = SampleDecks.build();
    history = <DayLog>[];
    streak = 0;
    lastStudyDay = '';
    freezes = 0;
    _save();
    notifyListeners();
  }
}
