import 'package:flutter/material.dart';
import '../models/recommendation_model.dart';
import '../utils/app_theme.dart';
import '../utils/extensions.dart';
import 'score_bar.dart';
import 'score_ring.dart';

class ConfidenceCard extends StatelessWidget {
  final DepartmentScoreModel dept;
  final int rank;
  final VoidCallback? onRoadmap;

  const ConfidenceCard({
    super.key,
    required this.dept,
    required this.rank,
    this.onRoadmap,
  });

  String get _medal => rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉';

  Color get _borderColor {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    return const Color(0xFFCD7F32);
  }

  Color get _scoreColor {
    if (dept.confidenceScore >= 85) return AppTheme.accent;
    if (dept.confidenceScore >= 70) return AppTheme.primary;
    if (dept.confidenceScore >= 55) return AppTheme.warning;
    return AppTheme.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: rank == 1 ? _borderColor.withOpacity(0.6) : AppTheme.divider,
          width: rank == 1 ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header row
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ScoreRing(
                score: dept.confidenceScore, size: 72, strokeWidth: 7, color: _scoreColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(_medal, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(dept.name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary)),
                  ),
                ]),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: _scoreColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    '${dept.code} • ${dept.confidenceScore}% Match',
                    style: TextStyle(
                        fontSize: 11,
                        color: _scoreColor,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'BDT ${dept.tuitionPerSemester.toLocaleString()}/sem',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary),
                ),
              ]),
            ),
          ]),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Score bars
          ScoreBar(label: 'Academic Alignment', score: dept.academicAlignment, color: const Color(0xFF2563EB)),
          ScoreBar(label: 'Interest Alignment', score: dept.interestAlignment, color: const Color(0xFF10B981)),
          ScoreBar(label: 'Career Alignment', score: dept.careerAlignment, color: const Color(0xFFF59E0B)),
          ScoreBar(label: 'Practical Fit', score: dept.practicalFit, color: const Color(0xFF8B5CF6)),

          // Reasoning
          if (dept.reasoning.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text('Why this department?',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 6),
            ...dept.reasoning.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('✓ ',
                        style: TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                    Expanded(
                      child: Text(r,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              height: 1.4)),
                    ),
                  ]),
                )),
          ],

          const SizedBox(height: 8),
          Text('🎓 ${dept.scholarshipChance}',
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w600)),

          // Roadmap button
          if (onRoadmap != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onRoadmap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.map_outlined, size: 14, color: AppTheme.primary),
                  SizedBox(width: 6),
                  Text('View 4-Year Career Roadmap',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
