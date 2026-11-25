import 'package:flutter/material.dart';

/// Translucent 3D amber/orange glassmorphic bust avatar matching Image 3
class Glossy3DAvatar extends StatelessWidget {
  final double size;
  final VoidCallback? onCameraTap;

  const Glossy3DAvatar({
    super.key,
    this.size = 100,
    this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 16,
      height: size + 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 3D Glassmorphic Avatar
          CustomPaint(
            size: Size(size, size),
            painter: _GlossyAvatarPainter(),
          ),

          // Overlapping Camera Badge at bottom-right (Image 3)
          Positioned(
            right: 4,
            bottom: 4,
            child: GestureDetector(
              onTap: onCameraTap,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A4A4A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlossyAvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Outer soft glow shadow
    final glowPaint = Paint()
      ..color = const Color(0xFFFA8C16).withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.44, glowPaint);

    // 1. Head (Translucent glossy orange/amber sphere with 3D reflection)
    final headCenter = Offset(w * 0.5, h * 0.32);
    final headRadius = w * 0.25;

    // Base amber gradient
    final headPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.4),
        radius: 0.85,
        colors: [
          Color(0xFFFFB049), // highlight top-left
          Color(0xFFFF7A00), // mid orange
          Color(0xFFE65100), // shadow edge
        ],
      ).createShader(Rect.fromCircle(center: headCenter, radius: headRadius));
    canvas.drawCircle(headCenter, headRadius, headPaint);

    // Head glossy rim highlight
    final headHl = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: headCenter, radius: headRadius - 2),
      3.6,
      1.2,
      false,
      headHl,
    );

    // 2. Torso / Shoulders (Translucent glossy 3D curve matching Image 3)
    final torsoPath = Path()
      ..moveTo(w * 0.12, h * 0.94)
      ..quadraticBezierTo(w * 0.14, h * 0.62, w * 0.5, h * 0.62)
      ..quadraticBezierTo(w * 0.86, h * 0.62, w * 0.88, h * 0.94)
      ..close();

    final torsoPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFF9E1B),
          Color(0xFFFF6D00),
          Color(0xFFD84315),
        ],
      ).createShader(Rect.fromLTWH(w * 0.1, h * 0.6, w * 0.8, h * 0.4));
    canvas.drawPath(torsoPath, torsoPaint);

    // Torso top highlight arc
    final torsoHl = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final hlArc = Path()
      ..moveTo(w * 0.26, h * 0.68)
      ..quadraticBezierTo(w * 0.5, h * 0.63, w * 0.74, h * 0.68);
    canvas.drawPath(hlArc, torsoHl);

    // Subtle inner reflection
    final innerArc = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.45, h * 0.26), headRadius * 0.35, innerArc);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
