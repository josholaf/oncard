import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Occlusion regions are normalized quadruples: x, y, w, h in 0..1.

/// Paints occlusion regions over a card image. Hidden state fills the
/// regions; revealed draws a brand-color outline around each one.
class OcclusionPainter extends CustomPainter {
  final List<double> rects;
  final bool revealed;

  /// Live drag rectangle in local pixels, editor only.
  final Rect? drag;

  const OcclusionPainter({
    required this.rects,
    required this.revealed,
    this.drag,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i + 3 < rects.length; i += 4) {
      final rect = Rect.fromLTWH(
        rects[i] * size.width,
        rects[i + 1] * size.height,
        rects[i + 2] * size.width,
        rects[i + 3] * size.height,
      );
      _drawRegion(canvas, rect);
    }
    if (drag != null) _drawRegion(canvas, drag!);
  }

  void _drawRegion(Canvas canvas, Rect rect) {
    if (!revealed) {
      canvas.drawRect(rect, Paint()..color = const Color(0xEE232329));
      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.white.withOpacity(0.5),
      );
    } else {
      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFF6750A4),
      );
    }
  }

  @override
  bool shouldRepaint(OcclusionPainter oldDelegate) =>
      oldDelegate.revealed != revealed ||
      oldDelegate.drag != drag ||
      oldDelegate.rects.length != rects.length;
}

/// Full-screen editor: drag to hide a region, tap a region to remove it.
/// Returns the updated normalized rect list via Navigator.pop.
class OcclusionEditor extends StatefulWidget {
  final String imagePath;
  final List<double> initial;
  const OcclusionEditor({
    super.key,
    required this.imagePath,
    required this.initial,
  });

  @override
  State<OcclusionEditor> createState() => _OcclusionEditorState();
}

class _OcclusionEditorState extends State<OcclusionEditor> {
  late final List<double> _rects = List<double>.from(widget.initial);
  final _stackKey = GlobalKey();
  Offset? _start;
  Offset? _current;

  Size? get _box => _stackKey.currentContext?.size;

  void _commit() {
    final box = _box;
    final start = _start;
    final end = _current;
    setState(() {
      _start = null;
      _current = null;
    });
    if (box == null || start == null || end == null) return;
    final w = (end.dx - start.dx).abs();
    final h = (end.dy - start.dy).abs();
    if (w < 12 || h < 12) return;
    final left = math.min(start.dx, end.dx);
    final top = math.min(start.dy, end.dy);
    setState(() {
      _rects.addAll(<double>[
        (left / box.width).clamp(0.0, 1.0),
        (top / box.height).clamp(0.0, 1.0),
        (w / box.width).clamp(0.0, 1.0),
        (h / box.height).clamp(0.0, 1.0),
      ]);
    });
  }

  void _removeAt(Offset tap) {
    final box = _box;
    if (box == null) return;
    for (var i = 0; i + 3 < _rects.length; i += 4) {
      final rect = Rect.fromLTWH(
        _rects[i] * box.width,
        _rects[i + 1] * box.height,
        _rects[i + 2] * box.width,
        _rects[i + 3] * box.height,
      );
      if (rect.inflate(10).contains(tap)) {
        setState(() => _rects.removeRange(i, i + 4));
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final drag = (_start != null && _current != null && _box != null)
        ? Rect.fromPoints(_start!, _current!)
        : null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hide parts of image'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _rects),
            child: const Text('Done'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Drag over the image to hide a region. '
            'Tap a region to remove it.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (d) => setState(() {
                _start = d.localPosition;
                _current = d.localPosition;
              }),
              onPanUpdate: (d) => setState(() => _current = d.localPosition),
              onPanEnd: (_) => _commit(),
              onTapUp: (d) => _removeAt(d.localPosition),
              child: Stack(
                key: _stackKey,
                children: [
                  Image.file(
                    File(widget.imagePath),
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: OcclusionPainter(
                        rects: _rects,
                        revealed: false,
                        drag: drag,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _rects.isEmpty
                ? 'No regions hidden yet.'
                : (_rects.length ~/ 4).toString() +
                    ' region(s) hidden. They reveal on the answer side.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
