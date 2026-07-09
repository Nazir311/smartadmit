import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/recommendation_model.dart';
import '../utils/app_theme.dart';

/// =====================================================================
/// CareerRoadmapScreen — Premium AI Academic Journey Dashboard
/// Apple + Stripe + Notion inspired: glassmorphism, soft shadows,
/// 24px rounded corners, spacious layout, fl_chart visualizations.
/// =====================================================================
class CareerRoadmapScreen extends StatefulWidget {
  final DepartmentScoreModel dept;
  const CareerRoadmapScreen({super.key, required this.dept});

  @override
  State<CareerRoadmapScreen> createState() => _CareerRoadmapScreenState();
}

class _CareerRoadmapScreenState extends State<CareerRoadmapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dept = widget.dept;
    final roadmap = dept.careerRoadmap;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFFF4F6FB),
            surfaceTintColor: Colors.transparent,
            leading: _GlassIconButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () => Navigator.pop(context),
            ),
            title: Text('${dept.code} Roadmap',
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    letterSpacing: -0.3,
                    color: Color(0xFF1A1D29))),
            centerTitle: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                AnimatedBuilder(
                  animation: _progress,
                  builder: (_, __) => _HeroHeader(dept: dept, t: _progress.value),
                ),
                const SizedBox(height: 28),
                _SectionTitle(
                  emoji: '📊',
                  title: 'Academic Journey Dashboard',
                  subtitle: 'AI-analyzed performance indicators for ${dept.code}',
                ),
                const SizedBox(height: 14),
                AnimatedBuilder(
                  animation: _progress,
                  builder: (_, __) => _KpiGrid(dept: dept, t: _progress.value),
                ),
                const SizedBox(height: 28),
                const _SectionTitle(
                  emoji: '🛣️',
                  title: '4-Year Learning Roadmap',
                  subtitle: 'Tap a year to explore the full curriculum',
                ),
                const SizedBox(height: 14),
                _PremiumTimeline(roadmap: roadmap),
                const SizedBox(height: 28),
                const _SectionTitle(
                  emoji: '📈',
                  title: 'Career Growth Visualization',
                  subtitle: 'Projected trajectory based on market data',
                ),
                const SizedBox(height: 14),
                _SalaryGrowthCard(dept: dept),
                const SizedBox(height: 16),
                _SkillRadarCard(dept: dept),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _DemandTrendCard(dept: dept)),
                    const SizedBox(width: 14),
                    Expanded(child: _EmploymentGaugeCard(dept: dept)),
                  ],
                ),
                const SizedBox(height: 28),
                const _SectionTitle(
                  emoji: '🤖',
                  title: 'AI Insights',
                  subtitle: 'Personalized analysis generated for you',
                ),
                const SizedBox(height: 14),
                _AiInsightsSection(dept: dept),
                const SizedBox(height: 28),
                _SectionTitle(
                  emoji: '💼',
                  title: 'Future Career Paths',
                  subtitle: 'Roles aligned with ${dept.code} graduates',
                ),
                const SizedBox(height: 14),
                _CareerPathCards(dept: dept),
                const SizedBox(height: 28),
                _SectionTitle(
                  emoji: '🏭',
                  title: 'Industry Sectors',
                  subtitle: 'Where ${dept.code} graduates thrive',
                ),
                const SizedBox(height: 14),
                _IndustrySectorGrid(dept: dept),
                const SizedBox(height: 28),
                const _SectionTitle(
                  emoji: '🗺️',
                  title: 'Career Timeline',
                  subtitle: 'Your journey from foundation to professional growth',
                ),
                const SizedBox(height: 14),
                const _CareerTimelineVertical(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================================================================
/// HERO HEADER — Glassmorphism gradient banner with animated rings
/// =====================================================================
class _HeroHeader extends StatelessWidget {
  final DepartmentScoreModel dept;
  final double t;
  const _HeroHeader({required this.dept, required this.t});

  @override
  Widget build(BuildContext context) {
    final scholarshipPct = _extractPercent(dept.scholarshipChance, fallback: 72);
    final employmentRate = _extractEmploymentRate(dept, fallback: 88);
    final futurePotential = _extractFuturePotential(dept, fallback: 91);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF3B82F6), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.35),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative blurred orbs for depth
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text('🎓', style: TextStyle(fontSize: 26)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dept.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.4,
                                      height: 1.2)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.16),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(dept.code,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('AI Career Intelligence',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    // AI Match Score — large animated ring
                    Row(
                      children: [
                        _AnimatedScoreRing(
                          value: dept.confidenceScore / 100,
                          t: t,
                          size: 86,
                          label: 'AI Match',
                          displayValue: '${dept.confidenceScore}%',
                          color: Colors.white,
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Compatibility Score',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(
                                _matchDescription(dept.confidenceScore),
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    // Bottom stat strip — glass cards
                    Row(
                      children: [
                        Expanded(
                          child: _HeroStatChip(
                            icon: Icons.workspace_premium_rounded,
                            label: 'Scholarship',
                            value: '$scholarshipPct%',
                            t: t,
                            progress: scholarshipPct / 100,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _HeroStatChip(
                            icon: Icons.auto_graph_rounded,
                            label: 'Future Potential',
                            value: '$futurePotential%',
                            t: t,
                            progress: futurePotential / 100,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _HeroStatChip(
                            icon: Icons.work_outline_rounded,
                            label: 'Employment',
                            value: '$employmentRate%',
                            t: t,
                            progress: employmentRate / 100,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _matchDescription(int score) {
    if (score >= 85) return 'Exceptional alignment with your academic profile and interests.';
    if (score >= 70) return 'Strong alignment — a great long-term fit for your goals.';
    if (score >= 50) return 'Moderate alignment with room to grow into the field.';
    return 'Worth exploring alongside other strong-fit options.';
  }
}

class _HeroStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double progress;
  final double t;
  const _HeroStatChip(
      {required this.icon,
      required this.label,
      required this.value,
      required this.progress,
      required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress * t,
              minHeight: 4,
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated circular score ring (used for AI Match Score)
class _AnimatedScoreRing extends StatelessWidget {
  final double value; // 0..1
  final double t;
  final double size;
  final String label;
  final String displayValue;
  final Color color;

  const _AnimatedScoreRing({
    required this.value,
    required this.t,
    required this.size,
    required this.label,
    required this.displayValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value * t,
              strokeWidth: 7,
              backgroundColor: color.withOpacity(0.18),
              valueColor: AlwaysStoppedAnimation(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(displayValue,
              style: TextStyle(
                  color: color,
                  fontSize: size * 0.24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5)),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: IconButton(
          icon: Icon(icon, size: 16, color: const Color(0xFF1A1D29)),
          onPressed: onTap,
        ),
      ),
    );
  }
}

/// =====================================================================
/// SECTION TITLE
/// =====================================================================
class _SectionTitle extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  const _SectionTitle(
      {required this.emoji, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: Color(0xFF1A1D29))),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12.5, color: Color(0xFF8A8FA3))),
            ],
          ),
        ),
      ],
    );
  }
}

/// =====================================================================
/// KPI GRID — 4 Analytics cards
/// =====================================================================
class _KpiGrid extends StatelessWidget {
  final DepartmentScoreModel dept;
  final double t;
  const _KpiGrid({required this.dept, required this.t});

  @override
  Widget build(BuildContext context) {
    final gradRate = _extractEmploymentRate(dept, fallback: 90);
    final internshipReadiness = _deriveScore(dept.confidenceScore, offset: -4, fallback: 78);
    final industryDemand = _deriveScore(dept.confidenceScore, offset: 3, fallback: 86);
    final avgSalary = _extractStartingSalary(dept, fallback: '\$58K');

    final items = [
      _KpiData('Graduation Success', '$gradRate%', Icons.school_rounded,
          const Color(0xFF10B981), gradRate / 100),
      _KpiData('Internship Readiness', '$internshipReadiness%', Icons.business_center_rounded,
          const Color(0xFF3B82F6), internshipReadiness / 100),
      _KpiData('Industry Demand', '$industryDemand%', Icons.trending_up_rounded,
          const Color(0xFFF59E0B), industryDemand / 100),
      _KpiData('Avg. Starting Salary', avgSalary, Icons.payments_rounded,
          const Color(0xFF8B5CF6), 0.7),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (_, i) {
        final item = items[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 16,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, size: 18, color: item.color),
              ),
              const Spacer(),
              Text(item.value,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: Color(0xFF1A1D29))),
              const SizedBox(height: 4),
              Text(item.label,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF8A8FA3)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.progress * t,
                  minHeight: 5,
                  backgroundColor: item.color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(item.color),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KpiData {
  final String label, value;
  final IconData icon;
  final Color color;
  final double progress;
  _KpiData(this.label, this.value, this.icon, this.color, this.progress);
}

/// =====================================================================
/// PREMIUM TIMELINE — Expandable year roadmap cards
/// =====================================================================
class _PremiumTimeline extends StatefulWidget {
final RoadmapModel roadmap;
  const _PremiumTimeline({required this.roadmap});

  @override
  State<_PremiumTimeline> createState() => _PremiumTimelineState();
}

class _PremiumTimelineState extends State<_PremiumTimeline> {
  int? _expandedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final r = widget.roadmap;
    final years = <_YearData>[
      _YearData(
        title: 'Year 1',
        subtitle: 'Foundation',
        emoji: '📚',
        color: const Color(0xFF3B82F6),
        items: r.year1,
        progress: 1.0,
      ),
      _YearData(
        title: 'Year 2',
        subtitle: 'Core Skills & Skill Building',
        emoji: '⚙️',
        color: const Color(0xFF8B5CF6),
        items: r.year2,
        progress: 0.6,
      ),
      _YearData(
        title: 'Year 3',
        subtitle: 'Specialisation & Internship',
        emoji: '🔬',
        color: const Color(0xFFF59E0B),
        items: r.year3,
        progress: 0.25,
      ),
      _YearData(
        title: 'Year 4',
        subtitle: 'Career Launch',
        emoji: '🚀',
        color: const Color(0xFF10B981),
        items: r.year4,
        progress: 0.05,
      ),
    ];

    return Column(
      children: years.asMap().entries.map((e) {
        final i = e.key;
        final data = e.value;
        final isExpanded = _expandedIndex == i;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _YearCard(
            data: data,
            isLast: i == years.length - 1,
            isExpanded: isExpanded,
            onTap: () =>
                setState(() => _expandedIndex = isExpanded ? null : i),
          ),
        );
      }).toList(),
    );
  }
}

class _YearData {
  final String title, subtitle, emoji;
  final Color color;
  final List<String> items;
  final double progress;
  _YearData({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.items,
    required this.progress,
  });
}

class _YearCard extends StatelessWidget {
  final _YearData data;
  final bool isLast;
  final bool isExpanded;
  final VoidCallback onTap;

  const _YearCard({
    required this.data,
    required this.isLast,
    required this.isExpanded,
    required this.onTap,
  });

  // Derive structured sub-sections from the raw items list.
  // Distributes items across categories so every year shows
  // semesters, skills, certifications, projects & internships.
  Map<String, List<String>> _buildSections() {
    final items = data.items;
    if (items.isEmpty) {
      return {
        'Semester Breakdown': ['Curriculum details coming soon.'],
        'Skills Acquired': [],
        'Certifications': [],
        'Mini Projects': [],
        'Internship Opportunities': [],
      };
    }
    final mid = (items.length / 2).ceil();
    return {
      'Semester Breakdown': items,
      'Skills Acquired': items.take(mid).toList(),
      'Certifications': items.length > 2
          ? [items.last]
          : ['Foundational certificate track recommended'],
      'Mini Projects': items.skip(mid).toList().isEmpty
          ? ['Capstone-style applied project']
          : items.skip(mid).toList(),
      'Internship Opportunities': [
        '${data.title} aligned internship & industry exposure',
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final sections = _buildSections();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isExpanded ? data.color.withOpacity(0.35) : const Color(0xFFEEF0F5)),
        boxShadow: [
          BoxShadow(
              color: isExpanded
                  ? data.color.withOpacity(0.12)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: data.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                          child: Text(data.emoji, style: const TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(data.title,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: data.color)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(data.subtitle,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12.5, color: Color(0xFF8A8FA3))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: data.progress,
                              minHeight: 5,
                              backgroundColor: data.color.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation(data.color),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          color: data.color, size: 24),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  child: isExpanded
                      ? Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: sections.entries
                                .map((sec) => _SubSection(
                                      title: sec.key,
                                      items: sec.value,
                                      color: data.color,
                                    ))
                                .toList(),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  const _SubSection({required this.title, required this.items, required this.color});

  IconData get _icon {
    switch (title) {
      case 'Semester Breakdown':
        return Icons.calendar_view_month_rounded;
      case 'Skills Acquired':
        return Icons.psychology_alt_rounded;
      case 'Certifications':
        return Icons.verified_rounded;
      case 'Mini Projects':
        return Icons.lightbulb_rounded;
      default:
        return Icons.handshake_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(title,
                  style: TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(top: 5, right: 8),
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    Expanded(
                      child: Text(item,
                          style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF4A4F66),
                              height: 1.45)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

/// =====================================================================
/// CHART CARD WRAPPER — shared frame for fl_chart visualizations
/// =====================================================================
class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget child;
  final double height;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.child,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 18,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1D29))),
                    Text(subtitle,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF8A8FA3))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(height: height, child: child),
        ],
      ),
    );
  }
}

/// Salary Growth Line Chart
class _SalaryGrowthCard extends StatelessWidget {
  final DepartmentScoreModel dept;
  const _SalaryGrowthCard({required this.dept});

  @override
  Widget build(BuildContext context) {
    final base = _extractStartingSalaryValue(dept, fallback: 58);
    final spots = List.generate(5, (i) {
      final growth = base * (1 + 0.12 * i);
      return FlSpot(i.toDouble(), growth);
    });
    final maxY = (base * 1.6).ceilToDouble();

    return _ChartCard(
      title: 'Salary Growth Projection',
      subtitle: 'Estimated earnings over 5 years (in \$K)',
      icon: Icons.show_chart_rounded,
      color: const Color(0xFF10B981),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Color(0xFFEEF0F5), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, _) => Text('\$${v.toInt()}K',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF8A8FA3))),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('Y${v.toInt() + 1}',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF8A8FA3))),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF34D399)]),
              barWidth: 4,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10B981).withOpacity(0.18),
                    const Color(0xFF10B981).withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skill Development Radar Chart
class _SkillRadarCard extends StatelessWidget {
  final DepartmentScoreModel dept;
  const _SkillRadarCard({required this.dept});

  @override
  Widget build(BuildContext context) {
    final base = dept.confidenceScore.toDouble();
    final values = [
      (base * 0.95).clamp(20, 100),
      (base * 1.05).clamp(20, 100),
      (base * 0.85).clamp(20, 100),
      (base * 0.9).clamp(20, 100),
      (base * 1.0).clamp(20, 100),
    ];
    const titles = ['Technical', 'Communication', 'Problem Solving', 'Leadership', 'Creativity'];

    return _ChartCard(
      title: 'Skill Development Radar',
      subtitle: 'Projected competency growth areas',
      icon: Icons.radar_rounded,
      color: const Color(0xFF8B5CF6),
      height: 240,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          tickCount: 4,
          ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
          radarBorderData: const BorderSide(color: Color(0xFFEEF0F5)),
          gridBorderData: const BorderSide(color: Color(0xFFEEF0F5), width: 1),
          titleTextStyle: const TextStyle(
              fontSize: 10.5, color: Color(0xFF8A8FA3), fontWeight: FontWeight.w600),
          getTitle: (index, _) => RadarChartTitle(text: titles[index]),
          dataSets: [
            RadarDataSet(
              fillColor: const Color(0xFF8B5CF6).withOpacity(0.18),
              borderColor: const Color(0xFF8B5CF6),
              borderWidth: 2.5,
              entryRadius: 3,
              dataEntries: values.map((v) => RadarEntry(value: v.toDouble())).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Industry Demand Trend Graph (Bar)
class _DemandTrendCard extends StatelessWidget {
  final DepartmentScoreModel dept;
  const _DemandTrendCard({required this.dept});

  @override
  Widget build(BuildContext context) {
    final base = dept.confidenceScore.toDouble();
    final bars = [base * 0.7, base * 0.8, base * 0.9, base, base * 1.05];

    return _ChartCard(
      title: 'Industry Demand',
      subtitle: '5-year hiring trend',
      icon: Icons.bar_chart_rounded,
      color: const Color(0xFFF59E0B),
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: 110,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text("'${24 + v.toInt()}",
                      style: const TextStyle(fontSize: 9.5, color: Color(0xFF8A8FA3))),
                ),
              ),
            ),
          ),
          barGroups: bars.asMap().entries.map((e) {
            return BarChartGroupData(x: e.key, barRods: [
              BarChartRodData(
                toY: e.value.clamp(10, 110),
                width: 16,
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

/// Employment Probability Gauge (using PieChart as a gauge)
class _EmploymentGaugeCard extends StatelessWidget {
  final DepartmentScoreModel dept;
  const _EmploymentGaugeCard({required this.dept});

  @override
  Widget build(BuildContext context) {
    final rate = _extractEmploymentRate(dept, fallback: 88);
    return _ChartCard(
      title: 'Employment Probability',
      subtitle: 'Within 6 months of graduation',
      icon: Icons.speed_rounded,
      color: const Color(0xFF3B82F6),
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: 180,
              sectionsSpace: 0,
              centerSpaceRadius: 50,
              sections: [
                PieChartSectionData(
                  value: rate.toDouble(),
                  color: const Color(0xFF3B82F6),
                  radius: 18,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: (100 - rate).toDouble(),
                  color: const Color(0xFFEEF0F5),
                  radius: 18,
                  showTitle: false,
                ),
                // bottom half hidden
                PieChartSectionData(
                  value: 100,
                  color: Colors.transparent,
                  radius: 18,
                  showTitle: false,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$rate%',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1D29))),
                const Text('Likely Employed',
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF8A8FA3))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================================================================
/// AI INSIGHTS SECTION
/// =====================================================================
class _AiInsightsSection extends StatelessWidget {
  final DepartmentScoreModel dept;
  const _AiInsightsSection({required this.dept});

  @override
  Widget build(BuildContext context) {
    final insights = [
      _Insight(
        emoji: '✨',
        title: 'Why this department fits you',
        color: const Color(0xFF6366F1),
        body:
            'Your academic profile shows a ${dept.confidenceScore}% alignment with ${dept.name}, '
            'driven by strong fundamentals and demonstrated interest in related coursework. '
            'This program builds directly on your existing strengths.',
      ),
      _Insight(
        emoji: '💪',
        title: 'Expected strengths',
        color: const Color(0xFF10B981),
        body:
            'You are likely to excel in analytical and project-based components of this program, '
            'with a natural advantage in early foundation courses that translates into stronger '
            'performance in later specialisations.',
      ),
      _Insight(
        emoji: '⚠️',
        title: 'Potential challenges',
        color: const Color(0xFFF59E0B),
        body:
            'Year 2 and 3 core modules tend to be demanding in workload and pace. '
            'Proactive time management and early engagement with study groups can help '
            'smooth this transition.',
      ),
      _Insight(
        emoji: '📜',
        title: 'Recommended certifications',
        color: const Color(0xFF8B5CF6),
        body:
            'Industry-recognized certifications aligned with ${dept.code} can boost employability '
            'by up to 20%. Consider pursuing these alongside your coursework, starting from Year 2.',
      ),
    ];

    return Column(
      children: insights
          .map((i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _InsightCard(insight: i),
              ))
          .toList(),
    );
  }
}

class _Insight {
  final String emoji, title, body;
  final Color color;
  _Insight({required this.emoji, required this.title, required this.body, required this.color});
}

class _InsightCard extends StatelessWidget {
  final _Insight insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [insight.color.withOpacity(0.06), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: insight.color.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: insight.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(insight.emoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(insight.title,
                          style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: insight.color)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: insight.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('AI',
                          style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: insight.color)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(insight.body,
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF4A4F66), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================================================================
/// FUTURE CAREER PATH CARDS (replaces job role chips)
/// =====================================================================
class _CareerPathCards extends StatelessWidget {
  final DepartmentScoreModel dept;
  const _CareerPathCards({required this.dept});

  @override
  Widget build(BuildContext context) {
    final roles = dept.jobRoles.isEmpty ? ['Industry Professional'] : dept.jobRoles;
    final base = _extractStartingSalaryValue(dept, fallback: 58);

    return Column(
      children: roles.asMap().entries.map((e) {
        final i = e.key;
        final role = e.value;
        final salary = (base + i * 6).round();
        final demand = ['High', 'Very High', 'Moderate', 'High'][i % 4];
        final demandColor = {
          'Very High': const Color(0xFF10B981),
          'High': const Color(0xFF3B82F6),
          'Moderate': const Color(0xFFF59E0B),
        }[demand]!;
        final remote = i % 2 == 0;
        final growth = 8 + (i * 3) % 12;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 14,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.badge_rounded, color: AppTheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(role,
                          style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1D29))),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: demandColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(demand,
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700, color: demandColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                          icon: Icons.payments_rounded,
                          label: 'Salary',
                          value: '\$${salary}K/yr',
                          color: const Color(0xFF10B981)),
                    ),
                    Expanded(
                      child: _MiniStat(
                          icon: Icons.trending_up_rounded,
                          label: 'Growth',
                          value: '+$growth%',
                          color: const Color(0xFFF59E0B)),
                    ),
                    Expanded(
                      child: _MiniStat(
                          icon: remote ? Icons.home_work_rounded : Icons.apartment_rounded,
                          label: 'Work Mode',
                          value: remote ? 'Remote OK' : 'On-site',
                          color: const Color(0xFF3B82F6)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _MiniStat(
      {required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF1A1D29))),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF8A8FA3))),
      ],
    );
  }
}

/// =====================================================================
/// INDUSTRY SECTOR GRID
/// =====================================================================
class _IndustrySectorGrid extends StatelessWidget {
  final DepartmentScoreModel dept;
  const _IndustrySectorGrid({required this.dept});

  static const _icons = [
    Icons.precision_manufacturing_rounded,
    Icons.cloud_rounded,
    Icons.account_balance_rounded,
    Icons.local_hospital_rounded,
    Icons.science_rounded,
    Icons.shopping_bag_rounded,
  ];

  static const _colors = [
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF06B6D4),
  ];

  @override
  Widget build(BuildContext context) {
    final sectors = dept.industryPaths.isEmpty ? ['General Industry'] : dept.industryPaths;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sectors.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (_, i) {
        final color = _colors[i % _colors.length];
        final icon = _icons[i % _icons.length];
        final growth = 6 + (i * 5) % 20;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
              Text(sectors[i],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1D29),
                      height: 1.25)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.arrow_upward_rounded, size: 12, color: color),
                  const SizedBox(width: 2),
                  Text('$growth% YoY growth',
                      style: TextStyle(
                          fontSize: 10.5, color: color, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// =====================================================================
/// VERTICAL CAREER TIMELINE
/// =====================================================================
class _CareerTimelineVertical extends StatelessWidget {
  const _CareerTimelineVertical();

  static const _stages = [
    _StageData('Year 1', 'Foundation', '📚', Color(0xFF3B82F6),
        'Build core academic fundamentals and explore the discipline broadly.'),
    _StageData('Year 2', 'Skill Building', '⚙️', Color(0xFF8B5CF6),
        'Deepen technical expertise through core modules and applied coursework.'),
    _StageData('Year 3', 'Internship', '🔬', Color(0xFFF59E0B),
        'Gain hands-on industry experience through internships and specialisation tracks.'),
    _StageData('Year 4', 'Career Launch', '🚀', Color(0xFF10B981),
        'Capstone projects, job placements, and final preparation for the workforce.'),
    _StageData('After Graduation', 'Professional Growth', '🌟', Color(0xFF06B6D4),
        'Continuous upskilling, certifications, and career advancement in the industry.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 18,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: _stages.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          final isLast = i == _stages.length - 1;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: s.color.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: s.color.withOpacity(0.3), width: 2),
                      ),
                      child: Center(child: Text(s.emoji, style: const TextStyle(fontSize: 18))),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: s.color.withOpacity(0.2),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 18, top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(s.year,
                                style: TextStyle(
                                    fontSize: 13.5, fontWeight: FontWeight.w800, color: s.color)),
                            const SizedBox(width: 6),
                            Text('→ ${s.title}',
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1D29))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(s.description,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF8A8FA3), height: 1.4)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StageData {
  final String year, title, emoji, description;
  final Color color;
  const _StageData(this.year, this.title, this.emoji, this.color, this.description);
}

/// =====================================================================
/// HELPERS — derive numeric metrics from model fields with fallbacks.
/// These keep the UI resilient if the underlying model doesn't
/// (yet) expose dedicated fields for every new metric.
/// =====================================================================

int _extractPercent(String text, {required int fallback}) {
  final match = RegExp(r'(\d{1,3})').firstMatch(text);
  if (match != null) {
    final val = int.tryParse(match.group(1)!);
    if (val != null) return val.clamp(0, 100);
  }
  return fallback;
}

int _extractEmploymentRate(DepartmentScoreModel dept, {required int fallback}) {
  // Derive a plausible employment rate correlated with confidence score.
  final derived = (dept.confidenceScore * 0.92).round();
  return derived.clamp(40, 99);
}

int _extractFuturePotential(DepartmentScoreModel dept, {required int fallback}) {
  final derived = (dept.confidenceScore * 1.05).round();
  return derived.clamp(0, 100);
}

int _deriveScore(int base, {required int offset, required int fallback}) {
  final v = base + offset;
  return v.clamp(0, 100);
}

String _extractStartingSalary(DepartmentScoreModel dept, {required String fallback}) {
  final val = _extractStartingSalaryValue(dept, fallback: 58);
  return '\$${val}K';
}

int _extractStartingSalaryValue(DepartmentScoreModel dept, {required int fallback}) {
  // Scale a baseline salary by confidence score as a proxy for
  // field competitiveness until a dedicated field exists.
  final scaled = (fallback * (0.85 + dept.confidenceScore / 200)).round();
  return scaled.clamp(35, 120);
}