import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../data/app_data.dart';
import '../data/models.dart';
import 'lucide_icons.dart';
import 'theme.dart';

/// Five small dots showing how deep a card's memory trace is.
class MasteryDots extends StatelessWidget {
  final int mastery;
  const MasteryDots({super.key, required this.mastery});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Mastery $mastery of 5',
      child: Row(
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
      ),
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
    return Semantics(
      label: label,
      child: Container(
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
      ),
    );
  }
}

/// Friendly empty state with icon, title, subtitle and optional action.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$title. $subtitle',
      child: Center(
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
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
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
    final shown = Theme.of(context).brightness == Brightness.dark
        ? lightenForDark(tint)
        : tint;
    return Semantics(
      label: '$label: $value',
      child: Card(
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
      ),
    );
  }
}

String iconBase(String icon) {
  final at = icon.indexOf('@');
  return at == -1 ? icon : icon.substring(0, at);
}

Color? iconTint(String icon) {
  final at = icon.indexOf('@');
  if (at == -1) return null;
  final hex = icon.substring(at + 1);
  if (hex.length != 7 || !hex.startsWith('#')) return null;
  final value = int.tryParse('FF${hex.substring(1)}', radix: 16);
  return value == null ? null : Color(value);
}

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
/// Designed to look like GitHub's graph so the habit is familiar, but the
/// copy and levels reward **steady, sustainable** days — not crushing
/// workload. A full, even row of light/medium squares beats a few black
/// days of overload.
///
/// - Columns = weeks (oldest left, newest right)
/// - Rows = weekdays Mon–Sun
/// - Levels use the daily goal as the "comfortable" target so level 4
///   only appears when you go well past a sustainable day
class StudyHeatmap extends StatelessWidget {
  final Map<String, DayLog> byDate;

  /// How many week columns to show.
  final int weeks;

  /// Comfortable reviews per day (from settings daily goal). Used so
  /// color steps map to sustainable load instead of max-in-year spikes.
  final int dailyGoal;

  /// Compact = slightly smaller for Home; full = larger for Stats.
  final bool compact;

  const StudyHeatmap({
    super.key,
    required this.byDate,
    this.weeks = 52,
    this.dailyGoal = 20,
    this.compact = false,
  });

  /// Opacity steps. Level 0 = empty, 1–3 = healthy range, 4 = heavy day.
  static const List<double> _levelOpacity = <double>[0, 0.28, 0.48, 0.72, 1.0];

  static const List<String> _monthShort = <String>[
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  static const List<String> _weekdayShort = <String>[
    'Mon',
    '',
    'Wed',
    '',
    'Fri',
    '',
    ''
  ];

  /// Map review count → 0..4 using daily goal as the "enough" mark.
  /// Encourages showing up most days at a calm pace rather than grinding.
  int levelFor(int count, int goal) {
    if (count <= 0) return 0;
    final g = goal.clamp(5, 200);
    if (count < (g * 0.4).ceil()) return 1;
    if (count < g) return 2;
    if (count <= (g * 1.4).ceil()) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDay =
        today.subtract(Duration(days: today.weekday - 1 + (weeks - 1) * 7));

    int countOn(DateTime d) => byDate[dayKey(d)]?.reviewed ?? 0;

    var activeDays = 0;
    var heavyDays = 0;
    for (var i = 0; i < weeks * 7; i++) {
      final date = firstDay.add(Duration(days: i));
      if (date.isAfter(today)) break;
      final c = countOn(date);
      if (c > 0) activeDays++;
      if (levelFor(c, dailyGoal) >= 4) heavyDays++;
    }

    final caption = activeDays == 0
        ? 'Show up a little each day — green streaks beat cram days.'
        : heavyDays > activeDays * 0.25
            ? 'Several heavy days. Smaller daily sessions stick better.'
            : activeDays >= 20
                ? 'Steady pace. Consistency beats overload.'
                : 'Keep the squares lighting up — short sessions count.';

    return LayoutBuilder(builder: (context, box) {
      const labelW = 28.0;
      final gridW = (box.maxWidth - labelW).clamp(120.0, 800.0);
      final per = gridW / weeks;
      final gap = compact ? per * 0.18 : per * 0.22;
      final cell = (per - gap).clamp(compact ? 8.0 : 10.0, 18.0);
      final cellGap = gap.clamp(1.5, 4.0);

      final monthSegments = <Widget>[];
      var run = 0;
      var runMonth = -1;
      void flushMonth() {
        if (runMonth == -1) return;
        monthSegments.add(SizedBox(
          width: run * (cell + cellGap),
          child: Text(
            _monthShort[runMonth],
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: compact ? 9 : 11,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ));
      }

      final weekColumns = <Widget>[];
      for (var w = 0; w < weeks; w++) {
        final cells = <Widget>[];
        for (var d = 0; d < 7; d++) {
          final date = firstDay.add(Duration(days: w * 7 + d));
          final count = countOn(date);
          final isFuture = date.isAfter(today);
          final level = isFuture ? 0 : levelFor(count, dailyGoal);
          final color = level == 0
              ? cs.surfaceContainerHighest.withOpacity(0.55)
              : cs.primary.withOpacity(_levelOpacity[level]);

          final tip = isFuture
              ? 'Future'
              : count == 0
                  ? 'No reviews · ${_fmt(date)}'
                  : '$count review${count == 1 ? '' : 's'} · ${_fmt(date)}';

          cells.add(Padding(
            padding: EdgeInsets.all(cellGap / 2),
            child: Tooltip(
              message: tip,
              child: Container(
                width: cell,
                height: cell,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(cell * 0.28),
                  color: color,
                ),
              ),
            ),
          ));
        }
        weekColumns.add(Column(
          mainAxisSize: MainAxisSize.min,
          children: cells,
        ));

        final month = firstDay.add(Duration(days: w * 7)).month;
        if (month != runMonth) {
          flushMonth();
          run = 0;
          runMonth = month;
        }
        run++;
      }
      flushMonth();

      final dayLabels = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var d = 0; d < 7; d++)
            SizedBox(
              height: cell + cellGap,
              width: labelW,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _weekdayShort[d],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: compact ? 8 : 9,
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ),
            ),
        ],
      );

      return Semantics(
        label:
            'Study activity heatmap for the past $weeks weeks. $caption',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: labelW),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: monthSegments,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dayLabels,
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: weekColumns,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Less',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: cs.onSurfaceVariant,
                      ),
                ),
                const SizedBox(width: 6),
                for (var i = 0; i < _levelOpacity.length; i++)
                  Container(
                    width: compact ? 11 : 13,
                    height: compact ? 11 : 13,
                    margin: const EdgeInsets.only(right: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: i == 0
                          ? cs.surfaceContainerHighest.withOpacity(0.55)
                          : cs.primary.withOpacity(_levelOpacity[i]),
                    ),
                  ),
                Text(
                  'More',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              caption,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.3,
                  ),
            ),
          ],
        ),
      );
    });
  }

  static String _fmt(DateTime d) {
    const months = <String>[
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[d.month]} ${d.day}';
  }
}
