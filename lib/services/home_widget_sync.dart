import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:home_widget/home_widget.dart';
import 'package:path_provider/path_provider.dart';

import '../data/app_data.dart';
import '../data/models.dart';

/// Pushes streak, due counts and the deck list to the Android
/// home-screen widget, plus a rendered heatmap image. Never throws:
/// the widget is a nicety, not a dependency.
Future<void> updateHomeWidget(AppData data) async {
  try {
    await HomeWidget.saveWidgetData('streak', '${data.streak}');
    await HomeWidget.saveWidgetData('due', '${data.totalDue}');
    final deckLines = <String>[];
    for (final deck in data.decks.take(3)) {
      deckLines.add(deck.dueCount > 0
          ? '${deck.name} · ${deck.dueCount} due'
          : deck.name);
    }
    for (var i = 0; i < 3; i++) {
      await HomeWidget.saveWidgetData(
          'deck${i}', i < deckLines.length ? deckLines[i] : '');
    }
    final heatPath = await _renderHeatmap(data);
    if (heatPath != null) {
      await HomeWidget.saveWidgetData('heatmapPath', heatPath);
    }
    await HomeWidget.updateWidget(androidName: 'OncardWidgetProvider');
  } catch (_) {
    // Widgets unavailable on this platform or build: ignore.
  }
}

/// Draws a 16-week study heatmap to a PNG the widget can display.
Future<String?> _renderHeatmap(AppData data) async {
  try {
    const weeks = 16;
    const cell = 10.0;
    const gap = 3.0;
    const opacities = <double>[0, 0.25, 0.45, 0.7, 1.0];
    final byDay = <String, DayLog>{
      for (final log in data.history) log.date: log
    };
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDay = today
        .subtract(Duration(days: today.weekday - 1 + (weeks - 1) * 7));

    int countOn(DateTime d) => byDay[dayKey(d)]?.reviewed ?? 0;
    var maxCount = 1;
    for (var i = 0; i < weeks * 7; i++) {
      final c = countOn(firstDay.add(Duration(days: i)));
      if (c > maxCount) maxCount = c;
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const step = cell + gap;
    for (var w = 0; w < weeks; w++) {
      for (var d = 0; d < 7; d++) {
        final date = firstDay.add(Duration(days: w * 7 + d));
        final count = countOn(date);
        final isFuture = date.isAfter(today);
        final level = count == 0 || isFuture
            ? 0
            : (((count - 1) / maxCount * 3).round() + 1).clamp(1, 4).toInt();
        final rect = Rect.fromLTWH(w * step, d * step, cell, cell);
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2.5));
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = level == 0
                ? const Color(0xFF3A3B44)
                : const Color(0xFF6750A4).withOpacity(opacities[level]),
        );
      }
    }
    final picture = recorder.endRecording();
    final image = await picture.toImage(
        (weeks * step).round(), (7 * step).round());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/oncard_heatmap.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  } catch (_) {
    return null;
  }
}
