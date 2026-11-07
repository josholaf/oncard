import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_data.dart';
import '../models.dart';
import '../update_bar.dart';
import '../widgets.dart';
import 'profile_screen.dart';
import 'study_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const quotes = <String>[
    'Repetition is the mother of learning.',
    'Small steps every day beat cramming every way.',
    'You remember what you retrieve, not what you reread.',
    'Consistency compounds. Show up again tomorrow.',
    'A card a day keeps forgetting away.',
    'Focus on the card in front of you.',
    'Mastery is built one honest review at a time.',
  ];

  void _openDeck(BuildContext context, Deck deck) {
    Navigator.push(
        context,
        MaterialPageRoute<void>(
            builder: (_) => StudyScreen(deck: deck, mode: StudyMode.flip)));
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final quote = quotes[now.weekday % quotes.length];
    final greeting = now.hour < 12
        ? 'Good morning'
        : (now.hour < 18 ? 'Good afternoon' : 'Good evening');

    final Deck? nextDeck = data.nextDeckToStudy;
    final goalProgress =
        data.dailyGoal == 0 ? 0.0 : data.reviewedToday / data.dailyGoal;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 2),
                  Text(data.displayName,
                      style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (_) => const ProfileScreen())),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: cs.primary.withOpacity(0.12),
                child: Text(
                  (data.displayName.isEmpty
                          ? 'G'
                          : data.displayName[0])
                      .toUpperCase(),
                  style: TextStyle(
                      color: cs.primary, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
            '${now.weekday == 7 ? 'Sunday' : _weekday(now.weekday)}, ${now.day} ${_month(now.month)}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: cs.onSurfaceVariant)),

        // Update bar appears only when a newer release is known.
        const UpdateBar(),

        const SizedBox(height: 20),

        // Hero card: workload, goal ring and streak in one glance.
        Card(
          color: cs.primary,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Today',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: cs.onPrimary.withOpacity(0.8))),
                    ),
                    Icon(Icons.local_fire_department_rounded,
                        size: 18, color: Color(0xFFE8B95D)),
                    const SizedBox(width: 4),
                    Text('${data.streak}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: cs.onPrimary)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _bigStat(context, data.totalDue, 'Due'),
                          const SizedBox(height: 12),
                          _bigStat(context, data.totalNew, 'New'),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 84,
                            height: 84,
                            child: CircularProgressIndicator(
                              value: goalProgress.clamp(0.0, 1.0).toDouble(),
                              strokeWidth: 7,
                              strokeCap: StrokeCap.round,
                              color: cs.onPrimary,
                              backgroundColor: cs.onPrimary.withOpacity(0.2),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                  '${(goalProgress.clamp(0.0, 1.0) * 100).round()}%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(color: cs.onPrimary)),
                              Text('of goal',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                          color: cs.onPrimary
                                              .withOpacity(0.7))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: cs.onPrimary,
                        foregroundColor: cs.primary),
                    onPressed: nextDeck == null
                        ? null
                        : () => _openDeck(context, nextDeck),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(nextDeck == null
                        ? 'Nothing to study'
                        : 'Start studying'),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Today at a glance: streak, mastered cards, deck count.
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.local_fire_department_rounded,
                value: '${data.streak}',
                label: 'day streak',
                color: const Color(0xFFD99A42),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.school_rounded,
                value: '${data.learnedTotal}',
                label: 'mastered',
                color: const Color(0xFF39845B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.style_rounded,
                value: '${data.decks.length}',
                label: 'decks',
                color: const Color(0xFF6C5AA6),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        if (data.recentlyStudied.isNotEmpty) ...[
          Text('Pick up where you left off',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: data.recentlyStudied.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final deck = data.recentlyStudied[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _openDeck(context, deck),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DeckAvatar(
                              icon: deck.icon,
                              colorIndex: deck.colorIndex,
                              size: 34),
                          const SizedBox(height: 8),
                          Text(deck.name,
                              style:
                                  Theme.of(context).textTheme.labelLarge),
                          if (deck.dueCount > 0)
                            Text('${deck.dueCount} due',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: cs.error)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],

        Text('My decks', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (data.decks.isEmpty)
          const EmptyState(
              icon: Icons.style,
              title: 'No decks yet',
              subtitle: 'Create your first deck from the Create tab.')
        else
          ...data.decks.map((deck) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DeckRow(deck: deck, onTap: () => _openDeck(context, deck)),
              )),

        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.format_quote_rounded,
                    color: cs.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(quote,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontStyle: FontStyle.italic)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bigStat(BuildContext context, int value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$value',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
        Text(label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    Theme.of(context).colorScheme.onPrimary.withOpacity(0.8))),
      ],
    );
  }

  static String _weekday(int w) => const <String>[
        '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
      ][w];
  static String _month(int m) => const <String>[
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][m];
}

class _DeckRow extends StatelessWidget {
  final Deck deck;
  final VoidCallback onTap;
  const _DeckRow({required this.deck, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              DeckAvatar(icon: deck.icon, colorIndex: deck.colorIndex),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(deck.name,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Text(
                        '${deck.cards.length} cards',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              if (deck.dueCount > 0)
                CountBadge(
                    label: '${deck.dueCount} due',
                    color: const Color(0xFF9C4146)),
            ],
          ),
        ),
      ),
    );
  }
}
