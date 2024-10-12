import 'package:bsam_admin/main.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Compass extends CustomPainter {
  const Compass({required this.heading});
  final double heading;

  @override
  void paint(Canvas canvas, Size size) {
    const lineLength = 30;
    final startRadius = (size.width / 2) - lineLength - 10;
    final endRadius = (size.width / 2) - 10;

    final paint = Paint();
    paint.color = Colors.white;
    paint.strokeWidth = 5;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint
    );

    paint.color = tertiaryColor;

    for (var theta = 0; theta < 360; theta+=30) {
      canvas.drawLine(
        Offset(
          startRadius * cos(pi * theta / 180) + (size.width / 2),
          - startRadius * sin(pi * theta / 180) + (size.width / 2)
        ),
        Offset(
          endRadius * cos(pi * theta / 180) + (size.width / 2),
          - endRadius * sin(pi * theta / 180) + (size.width / 2)
        ),
        paint
      );
    }

    final angle = 90 - heading;

    final path = Path();
    path.moveTo(
      startRadius * cos(pi * angle / 180) + (size.width / 2),
      - startRadius * sin(pi * angle / 180) + (size.width / 2)
    );

    path.lineTo(
      startRadius * cos(pi * (angle + 160) / 180) + (size.width / 2),
      - startRadius * sin(pi * (angle + 160) / 180) + (size.width / 2)
    );

    path.lineTo(
      startRadius * cos(pi * (angle + 200) / 180) + (size.width / 2),
      - startRadius * sin(pi * (angle + 200) / 180) + (size.width / 2)
    );

    path.close();

    paint.color = primaryColor;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
