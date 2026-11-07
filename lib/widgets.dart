import 'package:flutter/material.dart';

import 'app_data.dart';
import 'models.dart';
import 'lucide_icons.dart';
import 'theme.dart';

/// Five small dots showing how deep a card's memory trace is.
class MasteryDots extends StatelessWidget {
  final int mastery;
  const MasteryDots({super.key, required this.mastery});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < mastery;
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? cs.primary : cs.surfaceContainerHighest,
          ),
        );
      }),
    );
  }
}

/// Pill badge for due/new counts.
class CountBadge extends StatelessWidget {
  final String label;
  final Color color;
  const CountBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).brightness == Brightness.dark
        ? lightenForDark(color)
        : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Friendly empty state with icon and hint.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const EmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Icon(icon,
                  size: 40,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// Small statistic card used on Home and Stats.
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? color;
  const StatCard(
      {super.key,
      required this.icon,
      required this.value,
      required this.label,
      this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tint = color ?? cs.primary;
    // Dark mode: lighten icon colors so they read on dark surfaces.
    final shown = Theme.of(context).brightness == Brightness.dark
        ? lightenForDark(tint)
        : tint;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: shown.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: shown),
            ),
            const SizedBox(height: 12),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

/// Deck icons may carry a color suffix: 'lucide:book-2@#FF9800'.
/// These helpers split the icon from its optional color.
String iconBase(String icon) {
  final at = icon.indexOf('@');
  return at == -1 ? icon : icon.substring(0, at);
}

/// The color suffix of a deck icon, or null when it has none.
Color? iconTint(String icon) {
  final at = icon.indexOf('@');
  if (at == -1) return null;
  final hex = icon.substring(at + 1);
  if (hex.length != 7 || !hex.startsWith('#')) return null;
  final value = int.tryParse('FF${hex.substring(1)}', radix: 16);
  return value == null ? null : Color(value);
}

/// Renders a deck icon that is either an emoji character or a
/// 'lucide:<name>' reference from the Lucide icon set.
class DeckIcon extends StatelessWidget {
  final String icon;
  final double size;
  final Color? color;
  const DeckIcon({super.key, required this.icon, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final base = iconBase(icon);
    final tint = color ?? iconTint(icon);
    if (base.startsWith('lucide:')) {
      return LucideIcon(name: base.substring(7), size: size, color: tint);
    }
    return Text(base, style: TextStyle(fontSize: size, color: tint));
  }
}

/// Deck avatar: just the icon, tinted with the deck color. No circle.
class DeckAvatar extends StatelessWidget {
  final String icon;
  final int colorIndex;
  final double size;
  const DeckAvatar(
      {super.key, required this.icon, required this.colorIndex, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final base = iconTint(icon) ??
        deckPalette[colorIndex % deckPalette.length];
    // Dark mode: lighten deck colors so icons stay high contrast.
    final tint = Theme.of(context).brightness == Brightness.dark
        ? lightenForDark(base)
        : base;
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: DeckIcon(
          icon: icon,
          size: size * 0.8,
          color: tint,
        ),
      ),
    );
  }
}

/// GitHub-style contribution heatmap of study activity.
///
/// Columns are weeks (most recent on the right), rows are weekdays, cells
/// are colored in five steps from none to full intensity. Month labels sit
/// above the grid and a Less/More legend below it.
class StudyHeatmap extends StatelessWidget {
  final Map<String, DayLog> byDate;

  /// How many week columns to show, counting back from the current week.
  final int weeks;

  const StudyHeatmap({super.key, required this.byDate, this.weeks = 26});

  static const List<double> _levelOpacity = <double>[0, 0.25, 0.45, 0.7, 1.0];

  static const List<String> _monthShort = <String>[
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDay =
        today.subtract(Duration(days: today.weekday - 1 + (weeks - 1) * 7));

    int countOn(DateTime d) => byDate[dayKey(d)]?.reviewed ?? 0;

    var maxCount = 1;
    for (var i = 0; i < weeks * 7; i++) {
      final c = countOn(firstDay.add(Duration(days: i)));
      if (c > maxCount) maxCount = c;
    }

    final columns = <Widget>[];
    final monthLabels = <Widget>[];
    var prevMonth = -1;
    for (var w = 0; w < weeks; w++) {
      final cells = <Widget>[];
      for (var d = 0; d < 7; d++) {
        final date = firstDay.add(Duration(days: w * 7 + d));
        final count = countOn(date);
        final isFuture = date.isAfter(today);
        final level = count == 0 || isFuture
            ? 0
            : (((count - 1) / maxCount * 3).round() + 1).clamp(1, 4).toInt();
        cells.add(Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: level == 0
                ? cs.surfaceContainerHighest.withOpacity(0.6)
                : cs.primary.withOpacity(_levelOpacity[level]),
          ),
        ));
      }
      columns.add(Column(children: cells));

      final weekStart = firstDay.add(Duration(days: w * 7));
      final label = weekStart.month != prevMonth
          ? _monthShort[weekStart.month]
          : '';
      monthLabels.add(SizedBox(
        width: 15,
        child: Text(label,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontSize: 9, color: cs.onSurfaceVariant)),
      ));
      prevMonth = weekStart.month;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: monthLabels),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                for (var d = 0; d < 7; d++)
                  SizedBox(
                    height: 15,
                    width: 22,
                    child: d == 1 || d == 3 || d == 5
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              d == 1 ? 'M' : (d == 3 ? 'W' : 'F'),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontSize: 9, color: cs.onSurfaceVariant),
                            ),
                          )
                        : null,
                  ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: columns),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('Less',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 10, color: cs.onSurfaceVariant)),
            const SizedBox(width: 4),
            for (final opacity in _levelOpacity)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: opacity == 0
                      ? cs.surfaceContainerHighest.withOpacity(0.6)
                      : cs.primary.withOpacity(opacity),
                ),
              ),
            const SizedBox(width: 2),
            Text('More',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 10, color: cs.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }
}
