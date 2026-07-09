import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 550)));
    _anims = _ctrls.map((c) => Tween<double>(begin: 0, end: -7).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut))).toList();
    _start();
  }

  Future<void> _start() async {
    for (int i = 0; i < _ctrls.length; i++) {
      await Future.delayed(Duration(milliseconds: i * 150));
      if (mounted) _ctrls[i].repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF3B82F6)]), borderRadius: BorderRadius.circular(9)),
          child: const Center(child: Text('🤖', style: TextStyle(fontSize: 14))),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: AppTheme.botBubble,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Row(mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => AnimatedBuilder(
              animation: _anims[i],
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _anims[i].value),
                child: Container(
                  width: 7, height: 7,
                  margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                  decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                ),
              ),
            )),
          ),
        ),
      ]),
    );
  }
}
