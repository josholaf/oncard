import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_data.dart';

/// First-launch introduction. Skippable, shown only while
/// [AppData.onboarded] is false.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  final TextEditingController _nameController = TextEditingController();
  final Set<String> _interests = <String>{};

  static const List<String> _interestOptions = <String>[
    'Student',
    'Medicine',
    'Languages',
    'Programming',
    'Work',
    'Just for fun',
  ];

  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _go(int index) {
    _controller.animateToPage(index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic);
  }

  void _finish() {
    context
        .read<AppData>()
        .completeOnboarding(_nameController.text.trim(), _interests.toList());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final last = _page == 3;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: TextButton(onPressed: _finish, child: const Text('Skip')),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _welcomePage(cs, tt),
                  _featuresPage(cs, tt),
                  _personalizePage(cs, tt),
                  _startPage(cs, tt),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  const Spacer(),
                  for (var i = 0; i < 4; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _page ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? cs.primary
                            : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: last ? _finish : () => _go(_page + 1),
                    child: Text(last ? 'Get started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBadge(ColorScheme cs, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cs.primary.withOpacity(0.12),
      ),
      child: Icon(icon, size: 56, color: cs.primary),
    );
  }

  Widget _welcomePage(ColorScheme cs, TextTheme tt) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 450),
                builder: (context, v, child) => Opacity(
                  opacity: v,
                  child: Transform.scale(scale: 0.9 + 0.1 * v, child: child),
                ),
                child: _iconBadge(cs, Icons.style_rounded),
              ),
            ),
            const SizedBox(height: 28),
            Text('Welcome to Oncard', style: tt.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'Remember anything with spaced repetition. '
              'No account, no ads, works fully offline.',
              style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureRow(ColorScheme cs, IconData icon, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: cs.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(body, style: TextStyle(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuresPage(ColorScheme cs, TextTheme tt) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Everything you need', style: tt.headlineMedium),
            const SizedBox(height: 24),
            _featureRow(cs, Icons.style_rounded, 'Learn with flashcards',
                'Flip the card, recall the answer. Spaced repetition does the scheduling.'),
            _featureRow(cs, Icons.folder_rounded, 'Organize your decks',
                'Icons, colors, tags and notes keep every subject tidy.'),
            _featureRow(cs, Icons.insights_rounded, 'Track your progress',
                'Streaks, goals and a full-year heatmap show how far you have come.'),
          ],
        ),
      ),
    );
  }

  Widget _personalizePage(ColorScheme cs, TextTheme tt) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What brings you here?', style: tt.headlineMedium),
            const SizedBox(height: 12),
            Text('Pick anything that applies. You can change this later.',
                style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in _interestOptions)
                  FilterChip(
                    label: Text(option),
                    selected: _interests.contains(option),
                    onSelected: (selected) => setState(() {
                      selected
                          ? _interests.add(option)
                          : _interests.remove(option);
                    }),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _startPage(ColorScheme cs, TextTheme tt) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ready when you are', style: tt.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'No account needed. Your decks stay on this device.',
              style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your name (optional)',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No account, ever. Everything lives on your device.',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
