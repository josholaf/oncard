import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'models.dart';
import 'sample_decks.dart';

const uuid = Uuid();

class AppData extends ChangeNotifier {
  final SharedPreferences _prefs;
  List<Deck> decks = <Deck>[];
  ThemeMode themeMode = ThemeMode.system;
  int streak = 0;
  String lastStudyDay = '';

  AppData(this._prefs) {
    _load();
  }

  static String _dayKey(DateTime d) =>
      d.year.toString() +
      '-' +
      d.month.toString().padLeft(2, '0') +
      '-' +
      d.day.toString().padLeft(2, '0');

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
    final savedTheme = _prefs.getString('oncard.theme');
    themeMode = savedTheme == 'light'
        ? ThemeMode.light
        : (savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.system);
    _save();
  }

  Future<void> _save() async {
    await _prefs.setString(
        'oncard.decks', jsonEncode(decks.map((d) => d.toJson()).toList()));
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

  Deck? deckById(String id) {
    for (final d in decks) {
      if (d.id == id) return d;
    }
    return null;
  }

  void addDeck(String name, String icon, int colorIndex) {
    decks.add(Deck(id: uuid.v4(), name: name, icon: icon, colorIndex: colorIndex));
    _save();
    notifyListeners();
  }

  void deleteDeck(String id) {
    decks.removeWhere((d) => d.id == id);
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
      {required String question, required String answer, String note = ''}) {
    final deck = deckById(deckId);
    if (deck == null) return;
    for (final card in deck.cards) {
      if (card.id == cardId) {
        card.question = question;
        card.answer = answer;
        card.note = note;
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

  void recordReview(String deckId, String cardId, bool knew) {
    final deck = deckById(deckId);
    if (deck == null) return;
    for (final card in deck.cards) {
      if (card.id == cardId) {
        card.mastery = knew ? (card.mastery >= 5 ? 5 : card.mastery + 1) : 0;
        break;
      }
    }
    final today = _dayKey(DateTime.now());
    if (lastStudyDay != today) {
      final yesterday =
          _dayKey(DateTime.now().subtract(const Duration(days: 1)));
      streak = lastStudyDay == yesterday ? streak + 1 : 1;
      lastStudyDay = today;
      _prefs.setInt('oncard.streak', streak);
      _prefs.setString('oncard.lastDay', today);
    }
    _save();
    notifyListeners();
  }
}
