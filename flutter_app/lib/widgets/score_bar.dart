import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ScoreBar extends StatefulWidget {
  final String label;
  final int score;
  final Color? color;

  const ScoreBar({super.key, required this.label, required this.score, this.color});

  @override
  State<ScoreBar> createState() => _ScoreBarState();
}

class _ScoreBarState extends State<ScoreBar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
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

  Color get _barColor {
    if (widget.color != null) return widget.color!;
    if (widget.score >= 80) return AppTheme.accent;
    if (widget.score >= 60) return AppTheme.primary;
    if (widget.score >= 40) return AppTheme.warning;
    return AppTheme.error;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
              Text('${widget.score}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _barColor)),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _anim.value,
                minHeight: 6,
                backgroundColor: _barColor.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(_barColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
