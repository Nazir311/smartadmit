import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ScoreRing extends StatefulWidget {
  final int score;
  final double size;
  final double strokeWidth;
  final String? label;
  final TextStyle? scoreStyle;
  final TextStyle? labelStyle;
  final Color? color;

  const ScoreRing({
    super.key,
    required this.score,
    this.size = 80,
    this.strokeWidth = 8,
    this.label,
    this.scoreStyle,
    this.labelStyle,
    this.color,
  });

  @override
  State<ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<ScoreRing> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = Tween<double>(begin: 0, end: widget.score / 100).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _ringColor {
    if (widget.color != null) return widget.color!;
    if (widget.score >= 85) return AppTheme.accent;
    if (widget.score >= 70) return AppTheme.primary;
    if (widget.score >= 50) return AppTheme.warning;
    return AppTheme.error;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => CustomPaint(
          painter: _RingPainter(
            progress: _anim.value,
            color: _ringColor,
            strokeWidth: widget.strokeWidth,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.score}%',
                  style: widget.scoreStyle ??
                      TextStyle(
                        fontSize: widget.size * 0.22,
                        fontWeight: FontWeight.w800,
                        color: _ringColor,
                      ),
                ),
                if (widget.label != null)
                  Text(
                    widget.label!,
                    style: widget.labelStyle ??
                        TextStyle(
                          fontSize: widget.size * 0.12,
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({required this.progress, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, fgPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.color != color;
}
