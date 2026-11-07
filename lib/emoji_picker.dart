import 'package:flutter/material.dart';

import 'lucide_icons.dart';

/// Opens the searchable Lucide icon library. Returns the chosen icon as
/// 'lucide:<name>', optionally suffixed with '@#RRGGBB' when a color was
/// picked, or null when dismissed without a choice.
Future<String?> showEmojiPickerSheet(BuildContext context,
    {String current = 'lucide:book-open'}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: const _IconLibrarySheet(),
    ),
  );
}

/// Swatches offered under the icon grid.
const List<String> iconSwatches = <String>[
  '#F5F5F5', // white
  '#9E9E9E', // gray
  '#F44336', // red
  '#FF9800', // orange
  '#FFEB3B', // yellow
  '#4CAF50', // green
  '#009688', // teal
  '#2196F3', // blue
  '#E91E63', // pink
];

Color _hexColor(String hex) {
  final value = int.tryParse('FF' + hex.substring(1), radix: 16);
  return Color(value ?? 0xFFFFFFFF);
}

class _IconLibrarySheet extends StatefulWidget {
  const _IconLibrarySheet();

  @override
  State<_IconLibrarySheet> createState() => _IconLibrarySheetState();
}

class _IconLibrarySheetState extends State<_IconLibrarySheet> {
  final _search = TextEditingController();
  final String _selectedName;
  String? _color;
  List<String> _matches = const <String>[];

  _IconLibrarySheetState() : _selectedName = '';

  @override
  void initState() {
    super.initState();
    _filter();
    _search.addListener(_filter);
  }

  @override
  void dispose() {
    _search.removeListener(_filter);
    _search.dispose();
    super.dispose();
  }

  void _filter() {
    final q = _search.text.trim().toLowerCase();
    setState(() {
      _matches = q.isEmpty
          ? kLucideIcons.keys.toList(growable: false)
          : kLucideIcons.keys
              .where((name) => name.replaceAll('-', ' ').contains(q))
              .toList(growable: false);
    });
  }

  void _done() {
    Navigator.pop(context,
        'lucide:' + _selectedName + (_color == null ? '' : '@' + _color!));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                'Icon library',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _search,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Search icons, e.g. book, rocket, brain',
                  prefixIcon: const Icon(Icons.search_rounded),
                  isDense: true,
                  filled: true,
                  fillColor: cs.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _matches.isEmpty
                  ? const Center(
                      child: Text('Nothing matches that search.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6, childAspectRatio: 1),
                      itemCount: _matches.length,
                      itemBuilder: (context, i) {
                        final name = _matches[i];
                        final selected = name == _selectedName;
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => setState(() => _selectedName = name),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: selected ? cs.primaryContainer : null,
                            ),
                            child: Center(
                              child: LucideIcon(
                                  name: name,
                                  size: 26,
                                  color: _color == null
                                      ? cs.onSurface
                                      : _hexColor(_color!)),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final hex in iconSwatches)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () =>
                              setState(() => _color = _color == hex ? null : hex),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _hexColor(hex),
                              border: _color == hex
                                  ? Border.all(color: cs.primary, width: 3)
                                  : Border.all(color: cs.outlineVariant),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _done,
                  child: const Text('Done'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
