import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_data.dart';
import '../models.dart';
import '../widgets.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final cs = Theme.of(context).colorScheme;

    final byDate = <String, DayLog>{
      for (final log in data.history) log.date: log,
    };
    final now = DateTime.now();

    int reviewedOn(DateTime day) => byDate[dayKey(day)]?.reviewed ?? 0;

    final totalReviewed =
        data.history.fold(0, (sum, log) => sum + log.reviewed);
    final totalCorrect =
        data.history.fold(0, (sum, log) => sum + log.correct);
    final accuracy =
        totalReviewed == 0 ? 0 : (totalCorrect / totalReviewed * 100).round();

    final dueTomorrow = data.decks
        .fold(0, (sum, deck) => sum + deck.cards
            .where((c) =>
                !c.mastered &&
                c.due > now.millisecondsSinceEpoch &&
                c.due <= now.millisecondsSinceEpoch + 24 * 3600 * 1000)
            .length);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('This week',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 6; i >= 0; i--)
                      () {
                        final day = now.subtract(Duration(days: i));
                        final count = reviewedOn(day);
                        final maxCount = [
                          for (var j = 0; j < 7; j++)
                            reviewedOn(now.subtract(Duration(days: j))),
                        ].fold(1, (m, v) => v > m ? v : m);
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (count > 0)
                                  Text('$count',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                const SizedBox(height: 4),
                                FractionallySizedBox(
                                  heightFactor:
                                      (count / maxCount).clamp(0.04, 1.0).toDouble(),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: cs.primary.withOpacity(
                                          dayKey(day) == dayKey(now)
                                              ? 1.0
                                              : 0.45),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  const <String>[
                                    'M', 'T', 'W', 'T', 'F', 'S', 'S'
                                  ][day.weekday - 1],
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: cs.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        );
                      }(),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: StatCard(
                    icon: Icons.check_circle_rounded,
                    value: '$accuracy%',
                    label: 'accuracy'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                    icon: Icons.school_rounded,
                    value: '${data.learnedTotal}',
                    label: 'cards learned'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                    icon: Icons.local_fire_department_rounded,
                    value: '${data.streak}',
                    label: 'day streak'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                    icon: Icons.schedule_rounded,
                    value: '$dueTomorrow',
                    label: 'due tomorrow'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text('Study calendar',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StudyHeatmap(byDate: byDate),
            ),
          ),
        ],
      ),
    );
  }
}
