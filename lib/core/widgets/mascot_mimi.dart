import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Mimi, the speech-bubble mascot, drawn without remote or SVG assets.
class MascotMimi extends StatelessWidget {
  const MascotMimi({super.key, this.thinking = false, this.width = 200});
  final bool thinking;
  final double width;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size(width, width * .84),
      painter: _MimiPainter(AppPalette.of(context), thinking),
    ),
  );
}

class _MimiPainter extends CustomPainter {
  _MimiPainter(this.p, this.thinking);
  final AppPalette p;
  final bool thinking;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 200, size.height / 168);
    final brush = Paint();
    void circle(double x, double y, double r, Color color) {
      canvas.drawCircle(
        Offset(x, y),
        r,
        brush
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }

    circle(
      100,
      88,
      76,
      thinking ? p.listening.background : p.speaking.background,
    );
    if (thinking) {
      circle(152, 40, 6, p.listening.ink);
      circle(166, 26, 9, p.listening.ink);
      circle(186, 10, 5, p.listening.edge);
    } else {
      circle(160, 30, 10, p.listening.background);
      circle(36, 44, 7, p.writing.background);
    }
    final bubble = Path()
      ..moveTo(58, 70)
      ..cubicTo(62, 47, 78, 34, 100, 34)
      ..lineTo(104, 34)
      ..cubicTo(128, 34, 146, 52, 146, 76)
      ..lineTo(146, 84)
      ..cubicTo(146, 108, 128, 126, 104, 126)
      ..lineTo(90, 126)
      ..lineTo(70, 142)
      ..lineTo(74, 122)
      ..cubicTo(60, 112, 55, 100, 58, 70)
      ..close();
    canvas.drawPath(bubble, brush..color = p.primary);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4
      ..color = p.onPrimary;
    if (thinking) {
      canvas.drawPath(
        Path()
          ..moveTo(80, 80)
          ..quadraticBezierTo(88, 74, 96, 80)
          ..moveTo(110, 80)
          ..quadraticBezierTo(118, 74, 126, 80),
        stroke,
      );
      circle(103, 100, 5, p.onPrimary);
    } else {
      canvas.drawOval(
        const Rect.fromLTWH(81, 69, 14, 18),
        brush..color = p.onPrimary,
      );
      canvas.drawOval(
        const Rect.fromLTWH(111, 69, 14, 18),
        brush..color = p.onPrimary,
      );
      circle(90, 80, 3.5, p.ink);
      circle(120, 80, 3.5, p.ink);
      canvas.drawPath(
        Path()
          ..moveTo(94, 96)
          ..quadraticBezierTo(103, 104, 112, 96),
        stroke,
      );
      canvas.drawLine(
        const Offset(146, 72),
        const Offset(164, 50),
        stroke
          ..color = p.primary
          ..strokeWidth = 10,
      );
      circle(166, 47, 8, p.primary);
    }
  }

  @override
  bool shouldRepaint(covariant _MimiPainter oldDelegate) =>
      p != oldDelegate.p || thinking != oldDelegate.thinking;
}
