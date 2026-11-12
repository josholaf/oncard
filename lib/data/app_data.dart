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

class AppData extends ChangeNotifier {
  final SharedPreferences _prefs;
  List<Deck> decks = <Deck>[];
  ThemeMode themeMode = ThemeMode.system;
  int streak = 0;
  String lastStudyDay = '';
  int dailyGoal = 20;
  bool ttsEnabled = false;

  /// Library view style, remembered between sessions.
  bool libraryGrid = false;
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
    libraryGrid = _prefs.getBool('oncard.libraryGrid') ?? false;
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
    _save();
  }

  Future<void> _save() async {
    await _prefs.setString(
        'oncard.decks', jsonEncode(decks.map((d) => d.toJson()).toList()));
    await _prefs.setString(
        'oncard.history', jsonEncode(history.map((d) => d.toJson()).toList()));
  }

  // ---- Preferences ----

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

  /// Remembers the library grid/list choice.
  void setLibraryGrid(bool grid) {
    libraryGrid = grid;
    _prefs.setBool('oncard.libraryGrid', grid);
    notifyListeners();
  }

  /// Finishes onboarding and remembers the chosen profile.
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

  /// Stores the profile photo path. Pass null to remove it.
  void setPhoto(String? path) {
    photoPath = (path == null || path.isEmpty) ? null : path;
    _prefs.setString('oncard.photo', path ?? '');
    notifyListeners();
  }

  /// Guest sign out: resets the profile and replays the onboarding.
  /// Study data is never touched.
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

  /// Called by the update checker once a newer GitHub release is found.
  /// Pass nulls to hide the update bar again.
  void setUpdateInfo(String? version, String? url) {
    updateVersion = version;
    updateUrl = url;
    notifyListeners();
  }

  // ---- Queries ----

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

  // ---- Deck mutations ----

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

  // ---- Card mutations ----

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

  /// Bulk delete used by the card browser.
  void deleteCards(String deckId, List<String> cardIds) {
    final deck = deckById(deckId);
    if (deck == null) return;
    final ids = Set<String>.from(cardIds);
    deck.cards.removeWhere((c) => ids.contains(c.id));
    _save();
    notifyListeners();
  }

  /// Moves cards to another deck, keeping all review state.
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

  /// Adds or removes one tag on many cards at once.
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

  // ---- Study ----

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
      final yesterday =
          dayKey(DateTime.now().subtract(const Duration(days: 1)));
      streak = lastStudyDay == yesterday ? streak + 1 : 1;
      lastStudyDay = today;
      _prefs.setInt('oncard.streak', streak);
      _prefs.setString('oncard.lastDay', today);
    }

    _save();
    notifyListeners();
  }

  // ---- Backup ----

  String exportBackup() => jsonEncode(<String, dynamic>{
        'version': 2,
        'decks': decks.map((d) => d.toJson()).toList(),
        'history': history.map((h) => h.toJson()).toList(),
        'streak': streak,
        'lastStudyDay': lastStudyDay,
        'dailyGoal': dailyGoal,
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
    _save();
    notifyListeners();
  }
}
