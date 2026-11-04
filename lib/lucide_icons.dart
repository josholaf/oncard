import 'package:flutter/material.dart';

/// Icons from the Lucide icon set (https://lucide.dev), open source under
/// the ISC license. Each entry maps an icon name to normalized SVG path
/// data on a 24x24 grid. Rendered by [LucideIcon] as 2px round strokes.
const Map<String, List<String>> kLucideIcons = <String, List<String>>{
  'graduation-cap': <String>['M21.42 10.922a1 1 0 0 0-.019-1.838L12.83 5.18a2 2 0 0 0-1.66 0L2.6 9.08a1 1 0 0 0 0 1.832l8.57 3.908a2 2 0 0 0 1.66 0z', 'M22 10v6', 'M6 12.5V16a6 3 0 0 0 12 0v-3.5'],
};

/// Renders a Lucide icon by [name] at [size], stroked in [color].
class LucideIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;
  const LucideIcon({super.key, required this.name, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final paths = kLucideIcons[name];
    if (paths == null) {
      return SizedBox(width: size, height: size);
    }
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    return CustomPaint(
      size: Size.square(size),
      painter: _LucidePainter(paths, c),
    );
  }
}

class _LucidePainter extends CustomPainter {
  final List<String> paths;
  final Color color;
  const _LucidePainter(this.paths, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.save();
    canvas.scale(size.width / 24);
    for (final d in paths) {
      canvas.drawPath(parseSvgPath(d), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LucidePainter old) =>
      old.color != color || old.paths != paths;
}

/// Minimal SVG path parser covering the commands Lucide data uses:
/// M/m L/l H/h V/v C/c S/s Q/q T/t A/a Z/z on a 24x24 grid.
Path parseSvgPath(String d) {
  final path = Path();
  final tokens =
      RegExp(r'([A-Za-z])|([-+]?[0-9]*\.?[0-9]+)').allMatches(d).toList();
  var cx = 0.0, cy = 0.0; // current point
  var sx = 0.0, sy = 0.0; // subpath start
  var px = 0.0, py = 0.0; // last cubic control point
  var qx = 0.0, qy = 0.0; // last quad control point
  var i = 0;

  double next() => double.parse(tokens[i++].group(0)!);
  bool hasNext() => i < tokens.length && tokens[i].group(1) == null;

  while (i < tokens.length) {
    final cmd = tokens[i].group(1);
    if (cmd == null) break;
    i++;
    final rel = cmd.toLowerCase() == cmd;
    switch (cmd) {
      case 'M':
      case 'm':
        while (true) {
          final x = next(), y = next();
          cx = rel ? cx + x : x;
          cy = rel ? cy + y : y;
          path.moveTo(cx, cy);
          sx = cx; sy = cy;
          if (!hasNext()) break;
        }
        break;
      case 'L':
      case 'l':
        while (hasNext()) {
          final x = next(), y = next();
          cx = rel ? cx + x : x;
          cy = rel ? cy + y : y;
          path.lineTo(cx, cy);
        }
        break;
      case 'H':
      case 'h':
        while (hasNext()) {
          final x = next();
          cx = rel ? cx + x : x;
          path.lineTo(cx, cy);
        }
        break;
      case 'V':
      case 'v':
        while (hasNext()) {
          final y = next();
          cy = rel ? cy + y : y;
          path.lineTo(cx, cy);
        }
        break;
      case 'C':
      case 'c':
        while (hasNext()) {
          var x1 = next(), y1 = next(), x2 = next(), y2 = next(), x = next(), y = next();
          if (rel) { x1 += cx; y1 += cy; x2 += cx; y2 += cy; x += cx; y += cy; }
          path.cubicTo(x1, y1, x2, y2, x, y);
          px = x2; py = y2;
          cx = x; cy = y;
        }
        break;
      case 'S':
      case 's':
        while (hasNext()) {
          var x2 = next(), y2 = next(), x = next(), y = next();
          if (rel) { x2 += cx; y2 += cy; x += cx; y += cy; }
          final x1 = 2 * cx - px, y1 = 2 * cy - py;
          path.cubicTo(x1, y1, x2, y2, x, y);
          px = x2; py = y2;
          cx = x; cy = y;
        }
        break;
      case 'Q':
      case 'q':
        while (hasNext()) {
          var x1 = next(), y1 = next(), x = next(), y = next();
          if (rel) { x1 += cx; y1 += cy; x += cx; y += cy; }
          path.quadraticBezierTo(x1, y1, x, y);
          qx = x1; qy = y1;
          cx = x; cy = y;
        }
        break;
      case 'T':
      case 't':
        while (hasNext()) {
          final x = next(), y = next();
          cx = rel ? cx + x : x;
          cy = rel ? cy + y : y;
          final x1 = 2 * cx - qx, y1 = 2 * cy - qy;
          path.quadraticBezierTo(x1, y1, cx, cy);
          qx = x1; qy = y1;
        }
        break;
      case 'A':
      case 'a':
        while (hasNext()) {
          final rx = next(), ry = next(), rot = next();
          final large = next(), sweep = next();
          final x = next(), y = next();
          final tx = rel ? cx + x : x;
          final ty = rel ? cy + y : y;
          path.arcToPoint(
            Offset(tx, ty),
            radius: Radius.elliptical(rx, ry),
            rotation: rot,
            largeArc: large > 0.5,
            clockwise: sweep > 0.5,
          );
          cx = tx; cy = ty;
        }
        break;
      case 'Z':
      case 'z':
        path.close();
        cx = sx; cy = sy;
        break;
    }
  }
  return path;
}
