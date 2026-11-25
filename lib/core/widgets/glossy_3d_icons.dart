import 'package:flutter/material.dart';

/// Renders colorful 3D glossy icons with amber/orange glassmorphic styling
/// matching the fintech UI design system in Image 2 & Image 3.
class Glossy3DIcon extends StatelessWidget {
  final String type; // 'home', 'discover', 'billing', 'account', 'complaint'
  final bool isSelected;
  final double size;

  const Glossy3DIcon({
    super.key,
    required this.type,
    this.isSelected = false,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _Glossy3DIconPainter(
          type: type,
          isSelected: isSelected,
        ),
      ),
    );
  }
}

class _Glossy3DIconPainter extends CustomPainter {
  final String type;
  final bool isSelected;

  _Glossy3DIconPainter({required this.type, required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final primaryOrange = isSelected ? const Color(0xFFFF7A00) : const Color(0xFFFFA040);
    final deepOrange = isSelected ? const Color(0xFFE65100) : const Color(0xFFD86A18);
    final highlight = Colors.white.withValues(alpha: isSelected ? 0.85 : 0.65);

    switch (type) {
      case 'home':
        _paintHome(canvas, size, primaryOrange, deepOrange, highlight);
        break;
      case 'discover':
        _paintDiscover(canvas, size, primaryOrange, deepOrange, highlight);
        break;
      case 'billing':
        _paintBilling(canvas, size, primaryOrange, deepOrange, highlight);
        break;
      case 'account':
        _paintAccount(canvas, size, primaryOrange, deepOrange, highlight);
        break;
      case 'complaint':
        _paintComplaint(canvas, size, primaryOrange, deepOrange, highlight);
        break;
      default:
        _paintHome(canvas, size, primaryOrange, deepOrange, highlight);
    }
  }

  void _paintHome(Canvas canvas, Size size, Color c1, Color c2, Color hl) {
    final w = size.width;
    final h = size.height;

    // Soft drop shadow
    final shadowPaint = Paint()
      ..color = c2.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final shadowPath = Path()
      ..moveTo(w * 0.5, h * 0.12)
      ..lineTo(w * 0.9, h * 0.48)
      ..lineTo(w * 0.8, h * 0.9)
      ..lineTo(w * 0.2, h * 0.9)
      ..lineTo(w * 0.1, h * 0.48)
      ..close();
    canvas.drawPath(shadowPath, shadowPaint);

    // Roof & Body
    final mainPaint = Paint()
      ..shader = LinearGradient(
        colors: [c1, c2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final homePath = Path();
    // Roof
    homePath.moveTo(w * 0.5, h * 0.1);
    homePath.lineTo(w * 0.92, h * 0.46);
    homePath.lineTo(w * 0.84, h * 0.52);
    homePath.lineTo(w * 0.78, h * 0.47);
    homePath.lineTo(w * 0.78, h * 0.88);
    homePath.lineTo(w * 0.22, h * 0.88);
    homePath.lineTo(w * 0.22, h * 0.47);
    homePath.lineTo(w * 0.16, h * 0.52);
    homePath.lineTo(w * 0.08, h * 0.46);
    homePath.close();

    canvas.drawPath(homePath, mainPaint);

    // Doorway cut / inner amber
    final doorPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    final doorRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(w * 0.38, h * 0.52, w * 0.24, h * 0.36),
      topLeft: const Radius.circular(5),
      topRight: const Radius.circular(5),
    );
    canvas.drawRRect(doorRect, doorPaint);

    // Inner door depth
    final innerDoorPaint = Paint()
      ..color = c2.withValues(alpha: 0.6);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(w * 0.43, h * 0.58, w * 0.14, h * 0.30),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      ),
      innerDoorPaint,
    );

    // Glass glossy highlight
    final hlPaint = Paint()
      ..color = hl
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final hlPath = Path()
      ..moveTo(w * 0.48, h * 0.13)
      ..lineTo(w * 0.18, h * 0.44);
    canvas.drawPath(hlPath, hlPaint);
  }

  void _paintDiscover(Canvas canvas, Size size, Color c1, Color c2, Color hl) {
    final w = size.width;
    final h = size.height;

    // Magnifying glass lens rim
    final rimPaint = Paint()
      ..shader = LinearGradient(
        colors: [c1, c2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6;

    final center = Offset(w * 0.42, h * 0.42);
    final radius = w * 0.30;
    canvas.drawCircle(center, radius, rimPaint);

    // Glass lens fill (subtle warm reflection)
    final lensFill = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.7),
          c1.withValues(alpha: 0.2),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 1.8, lensFill);

    // Handle
    final handlePaint = Paint()
      ..shader = LinearGradient(
        colors: [c1, c2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(w * 0.6, h * 0.6, w * 0.4, h * 0.4))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.65, h * 0.65),
      Offset(w * 0.90, h * 0.90),
      handlePaint,
    );

    // Glossy reflection arc
    final hlPaint = Paint()
      ..color = hl
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final arcRect = Rect.fromCircle(center: center, radius: radius - 3);
    canvas.drawArc(arcRect, 3.8, 1.2, false, hlPaint);
  }

  void _paintBilling(Canvas canvas, Size size, Color c1, Color c2, Color hl) {
    final w = size.width;
    final h = size.height;

    // Bill sheet container
    final docPaint = Paint()
      ..shader = LinearGradient(
        colors: [c1, c2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final docRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.16, h * 0.12, w * 0.68, h * 0.78),
      const Radius.circular(6),
    );
    canvas.drawRRect(docRect, docPaint);

    // Inner sheet paper (white)
    final paperPaint = Paint()..color = Colors.white;
    final paperRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, h * 0.18, w * 0.56, h * 0.66),
      const Radius.circular(4),
    );
    canvas.drawRRect(paperRect, paperPaint);

    // BILL text / header lines
    final linePaint = Paint()
      ..color = c2
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(w * 0.30, h * 0.32), Offset(w * 0.68, h * 0.32), linePaint);
    canvas.drawLine(Offset(w * 0.30, h * 0.44), Offset(w * 0.68, h * 0.44), linePaint);
    canvas.drawLine(Offset(w * 0.30, h * 0.56), Offset(w * 0.54, h * 0.56), linePaint);

    // Circular badge overlapping bottom left
    final badgePaint = Paint()
      ..shader = LinearGradient(colors: [c1, c2]).createShader(Rect.fromLTWH(w * 0.1, h * 0.6, w * 0.32, h * 0.32));
    canvas.drawCircle(Offset(w * 0.28, h * 0.74), w * 0.15, badgePaint);

    final badgeInner = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.28, h * 0.74), w * 0.11, badgeInner);
    final userHead = Paint()..color = c2;
    canvas.drawCircle(Offset(w * 0.28, h * 0.71), w * 0.045, userHead);
  }

  void _paintAccount(Canvas canvas, Size size, Color c1, Color c2, Color hl) {
    final w = size.width;
    final h = size.height;

    // Head
    final headPaint = Paint()
      ..shader = LinearGradient(
        colors: [c1, c2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(w * 0.25, h * 0.1, w * 0.5, h * 0.4));

    final headCenter = Offset(w * 0.5, h * 0.32);
    final headRadius = w * 0.22;
    canvas.drawCircle(headCenter, headRadius, headPaint);

    // Torso / shoulders
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [c1, c2],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.15, h * 0.55, w * 0.7, h * 0.4));

    final bodyPath = Path()
      ..moveTo(w * 0.15, h * 0.90)
      ..quadraticBezierTo(w * 0.18, h * 0.60, w * 0.5, h * 0.60)
      ..quadraticBezierTo(w * 0.82, h * 0.60, w * 0.85, h * 0.90)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Glossy shine highlight on head
    final hlPaint = Paint()
      ..color = hl
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: headCenter, radius: headRadius - 2),
      3.8,
      1.1,
      false,
      hlPaint,
    );
  }

  void _paintComplaint(Canvas canvas, Size size, Color c1, Color c2, Color hl) {
    final w = size.width;
    final h = size.height;

    // Speech bubble background
    final bubblePaint = Paint()..color = Colors.white;
    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.15, w * 0.70, h * 0.65),
      Radius.circular(w * 0.25),
    );
    canvas.drawRRect(bubbleRect, bubblePaint);

    // Exclamation circle
    final exCircle = Paint()..color = const Color(0xFFE53935);
    canvas.drawCircle(Offset(w * 0.5, h * 0.47), w * 0.20, exCircle);

    // Exclamation mark
    final textPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.5, h * 0.38), Offset(w * 0.5, h * 0.48), textPaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.55), 1.4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _Glossy3DIconPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected || oldDelegate.type != type;
  }
}
