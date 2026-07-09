import 'package:flutter/material.dart';
import '../models/student_profile_model.dart';
import '../utils/app_theme.dart';

class ProfileProgressCard extends StatelessWidget {
  final StudentProfileModel profile;

  const ProfileProgressCard({super.key, required this.profile});

  int get _completedFields {
    int c = 0;
    if (profile.sscGpa != null) c++;
    if (profile.hscGpa != null) c++;
    if (profile.group != null) c++;
    if (profile.favoriteSubjects.isNotEmpty) c++;
    if (profile.interests.isNotEmpty) c++;
    if (profile.careerGoals.isNotEmpty) c++;
    if (profile.financialConstraint != null) c++;
    return c;
  }

  static const int _totalFields = 7;

  @override
  Widget build(BuildContext context) {
    final pct = _completedFields / _totalFields;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('📋', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            const Text('Profile Progress', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            const Spacer(),
            Text('${(_completedFields / _totalFields * 100).round()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 6, children: [
            _chip('SSC GPA', profile.sscGpa != null),
            _chip('HSC GPA', profile.hscGpa != null),
            _chip('Group', profile.group != null),
            _chip('Subjects', profile.favoriteSubjects.isNotEmpty),
            _chip('Interests', profile.interests.isNotEmpty),
            _chip('Career Goals', profile.careerGoals.isNotEmpty),
            _chip('Budget', profile.financialConstraint != null),
          ]),
        ],
      ),
    );
  }

  Widget _chip(String label, bool done) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: done ? Colors.white : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, size: 12, color: done ? AppTheme.primary : Colors.white70),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: done ? AppTheme.primary : Colors.white70, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
