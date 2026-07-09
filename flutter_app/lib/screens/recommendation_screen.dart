import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recommendation_model.dart';
import '../providers/chat_provider.dart';
import '../providers/recommendation_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/confidence_card.dart';
import 'career_roadmap_screen.dart';
import 'parent_mode_screen.dart';
import 'report_screen.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessionId = context.read<ChatProvider>().sessionId;
      if (sessionId.isNotEmpty) {
        context.read<RecommendationProvider>().loadRecommendation(sessionId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Recommendations',
            style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
            label: const Text('PDF', style: TextStyle(fontSize: 12)),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ReportScreen())),
          ),
        ],
      ),
      body: Consumer<RecommendationProvider>(
        builder: (_, provider, __) {
          if (provider.loading) {
            return const Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(color: AppTheme.primary),
                SizedBox(height: 16),
                Text('Loading your recommendations...',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ]),
            );
          }

          if (!provider.hasRecommendation) {
            return _EmptyState();
          }

          final rec = provider.recommendation!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _TopBanner(dept: rec.topDepartments.isNotEmpty ? rec.topDepartments.first : null),
              const SizedBox(height: 14),
              _ActionRow(
                onParentMode: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ParentModeScreen(recommendation: rec))),
                onReport: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ReportScreen())),
              ),
              const SizedBox(height: 20),
              Row(children: [
                const Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Top Department Matches',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    Text('AI-scored across 4 dimensions',
                        style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  ]),
                ),
                Text(
                  '${rec.generatedAt.day}/${rec.generatedAt.month}/${rec.generatedAt.year}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textHint),
                ),
              ]),
              const SizedBox(height: 14),
              ...rec.topDepartments.asMap().entries.map((e) => ConfidenceCard(
                    dept: e.value,
                    rank: e.key + 1,
                    onRoadmap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CareerRoadmapScreen(dept: e.value)),
                    ),
                  )),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🤖', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text('No Recommendations Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          const Text(
            'Complete the AI assessment to get personalized department recommendations with confidence scores.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, height: 1.55),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.chat_outlined, size: 16),
            label: const Text('Go to Chat & Start Assessment'),
            onPressed: () => Navigator.pop(context),
          ),
        ]),
      ),
    );
  }
}

class _TopBanner extends StatelessWidget {
  final DepartmentScoreModel? dept;
  const _TopBanner({this.dept});

  @override
  Widget build(BuildContext context) {
    if (dept == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppTheme.primary, Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primary.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🎯 Best Match',
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(dept!.name,
                style: const TextStyle(
                    color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(dept!.code,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${dept!.confidenceScore}%',
              style: const TextStyle(
                  color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900)),
          const Text('Confidence',
              style: TextStyle(color: Colors.white70, fontSize: 11)),
        ]),
      ]),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final VoidCallback onParentMode;
  final VoidCallback onReport;

  const _ActionRow({required this.onParentMode, required this.onReport});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: _ActionBtn(
          emoji: '👨‍👩‍👧',
          label: 'Parent Mode',
          sublabel: 'EN + বাংলা',
          color: const Color(0xFFECFDF5),
          textColor: AppTheme.accent,
          onTap: onParentMode,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _ActionBtn(
          emoji: '📄',
          label: 'Download Report',
          sublabel: 'Full PDF report',
          color: const Color(0xFFFEF3C7),
          textColor: const Color(0xFF92400E),
          onTap: onReport,
        ),
      ),
    ]);
  }
}

class _ActionBtn extends StatelessWidget {
  final String emoji;
  final String label;
  final String sublabel;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.emoji,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 5),
          Text(label,
              style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w700)),
          Text(sublabel,
              style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.7))),
        ]),
      ),
    );
  }
}
