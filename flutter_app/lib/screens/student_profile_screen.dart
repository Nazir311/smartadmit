import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student_profile_model.dart';
import '../providers/chat_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/recommendation_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/profile_progress_card.dart';
import 'chat_screen.dart';
import 'recommendation_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessionId = context.read<ChatProvider>().sessionId;
      if (sessionId.isNotEmpty) {
        context.read<ProfileProvider>().loadProfile(sessionId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (_, provider, __) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          if (!provider.hasProfile) {
            return _EmptyProfileView(
              onStart: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const ChatScreen(initialMessage: 'Start Assessment')),
              ),
            );
          }

          final p = provider.profile!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ProfileProgressCard(profile: p),
              const SizedBox(height: 16),
              _AcademicCard(profile: p),
              const SizedBox(height: 12),
              _InterestsCard(profile: p),
              const SizedBox(height: 12),
              _CareerCard(profile: p),
              const SizedBox(height: 12),
              _StatusCard(profile: p),
              const SizedBox(height: 16),
              if (p.profileComplete)
                _ViewResultsCTA(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RecommendationScreen())),
                ),
              if (p.profileComplete) const SizedBox(height: 12),
              _RestartButton(
                onRestart: () => _confirmRestart(context, provider),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  void _confirmRestart(BuildContext context, ProfileProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Restart Assessment?'),
        content: const Text(
            'This clears your current profile and recommendations. You will start fresh.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ChatProvider>().clearChat();
              provider.clear();
              context.read<RecommendationProvider>().clear();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const ChatScreen(initialMessage: 'Start Assessment')),
              );
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}

class _EmptyProfileView extends StatelessWidget {
  final VoidCallback onStart;
  const _EmptyProfileView({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('📋', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text('No Profile Yet',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          const Text(
            'Start the AI assessment to build your student profile and get personalised recommendations.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text('Start Assessment'),
            onPressed: onStart,
          ),
        ]),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 148,
          child: Text('$label:',
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

class _ChipRow extends StatelessWidget {
  final String label;
  final List<String> items;
  const _ChipRow(this.label, this.items);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$label:',
            style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        items.isEmpty
            ? const Text('Not provided',
                style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textHint,
                    fontStyle: FontStyle.italic))
            : Wrap(
                spacing: 6,
                runSpacing: 6,
                children: items
                    .map((item) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(item,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w500)),
                        ))
                    .toList(),
              ),
      ]),
    );
  }
}

class _AcademicCard extends StatelessWidget {
  final StudentProfileModel profile;
  const _AcademicCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(title: '🎓 Academic Info', children: [
      _InfoRow('SSC GPA', profile.sscGpa?.toString() ?? 'Not provided'),
      _InfoRow('HSC GPA', profile.hscGpa?.toString() ?? 'Not provided'),
      _InfoRow(
          'Effective GPA',
          profile.effectiveGpa > 0
              ? profile.effectiveGpa.toStringAsFixed(2)
              : 'N/A'),
      _InfoRow('Academic Group', profile.group ?? 'Not provided'),
    ]);
  }
}

class _InterestsCard extends StatelessWidget {
  final StudentProfileModel profile;
  const _InterestsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(title: '💡 Interests & Skills', children: [
      _ChipRow('Favourite Subjects', profile.favoriteSubjects),
      _ChipRow('Interests', profile.interests),
      _ChipRow('Skills', profile.skills),
    ]);
  }
}

class _CareerCard extends StatelessWidget {
  final StudentProfileModel profile;
  const _CareerCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(title: '🚀 Career & Financial', children: [
      _ChipRow('Career Goals', profile.careerGoals),
      _InfoRow('Budget Level', profile.financialConstraint ?? 'Not provided'),
      _InfoRow(
          'Scholarship Interest',
          profile.scholarshipInterest == true
              ? 'Yes'
              : profile.scholarshipInterest == false
                  ? 'No'
                  : 'Not provided'),
    ]);
  }
}

class _StatusCard extends StatelessWidget {
  final StudentProfileModel profile;
  const _StatusCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(title: '📊 Assessment Status', children: [
      _InfoRow('Current Stage', profile.completionStage.toUpperCase()),
      _InfoRow('Profile Complete',
          profile.profileComplete ? '✅ Complete' : '⏳ In Progress'),
    ]);
  }
}

class _ViewResultsCTA extends StatelessWidget {
  final VoidCallback onTap;
  const _ViewResultsCTA({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppTheme.accent, Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: AppTheme.accent.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 5))
          ],
        ),
        child: const Row(children: [
          Text('🎯', style: TextStyle(fontSize: 28)),
          SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Recommendations Are Ready!',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
              SizedBox(height: 2),
              Text('Tap to view confidence scores and career roadmaps',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
            ]),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ]),
      ),
    );
  }
}

class _RestartButton extends StatelessWidget {
  final VoidCallback onRestart;
  const _RestartButton({required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRestart,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.error.withOpacity(0.25)),
        ),
        child: const Row(children: [
          Icon(Icons.refresh_rounded, color: AppTheme.error, size: 18),
          SizedBox(width: 10),
          Expanded(
              child: Text('Restart Assessment',
                  style: TextStyle(
                      color: AppTheme.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 13))),
          Icon(Icons.arrow_forward_ios, color: AppTheme.error, size: 14),
        ]),
      ),
    );
  }
}
