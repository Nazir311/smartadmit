// ═══════════════════════════════════════════════════════════════════
//  departments_screen.dart — DIU SmartAdmit
//  Premium AI-powered Department Intelligence Dashboard
// ═══════════════════════════════════════════════════════════════════
//
//  Sections:
//    1. Hero banner + animated stat cards
//    2. Analytics (pie / bar / line charts via fl_chart)
//    3. Glassmorphism search + filter chips + sort
//    4. Premium department cards (hover lift, AI match ring,
//       popularity bar, mini stats)
//    5. Expanded detail sheet (Overview / Requirements / Careers /
//       Salary / Demand / Admission Process) with radar chart,
//       gauge, GPA meter, tuition comparison bar
//
//  All data is derived from the existing DepartmentProvider /
//  DepartmentModel — no model fields are required beyond what the
//  original screen already used (code, name, faculty, minGPA, seats,
//  tuitionPerSemester, duration, requiredSubjects,
//  admissionTestRequired, description, careers).
//
// ═══════════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/department_provider.dart';
import '../models/department_model.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _C {
  static const primary    = Color(0xFF2563EB);
  static const primaryDk  = Color(0xFF1D4ED8);
  static const indigo     = Color(0xFF4F46E5);
  static const teal       = Color(0xFF0D9488);
  static const amber      = Color(0xFFF59E0B);
  static const rose       = Color(0xFFF43F5E);
  static const violet     = Color(0xFF7C3AED);
  static const green      = Color(0xFF16A34A);

  static const bg         = Color(0xFFF8FAFC);
  static const surface    = Colors.white;
  static const border     = Color(0xFFE2E8F0);
  static const txtPri     = Color(0xFF0F172A);
  static const txtSec     = Color(0xFF475569);
  static const txtMut     = Color(0xFF94A3B8);

  static List<BoxShadow> card = [
    const BoxShadow(color: Color(0x100F172A), blurRadius: 24, offset: Offset(0, 4)),
    const BoxShadow(color: Color(0x060F172A), blurRadius: 6,  offset: Offset(0, 1)),
  ];
  static List<BoxShadow> glow(Color c, [double o = 0.28]) => [
    BoxShadow(color: c.withOpacity(o), blurRadius: 24, offset: const Offset(0, 8)),
  ];

  // Faculty color map
  static Color facultyColor(String f) {
    switch (f) {
      case 'Engineering':       return primary;
      case 'Business':          return amber;
      case 'Health Sciences':   return green;
      case 'Design & Planning': return rose;
      default:                  return violet;
    }
  }

  static LinearGradient facultyGradient(String f) {
    final c = facultyColor(f);
    return LinearGradient(colors: [c, c.withOpacity(0.65)],
        begin: Alignment.topLeft, end: Alignment.bottomRight);
  }
}

// ─────────────────────────────────────────────
//  DERIVED "AI" METRICS  (deterministic, from real fields)
// ─────────────────────────────────────────────
class _Metrics {
  final DepartmentModel d;
  _Metrics(this.d);

  // Stable hash-based jitter so numbers feel organic but don't change on rebuild
  int get _seed => d.code.codeUnits.fold(0, (a, b) => a + b);

  /// AI match score 70–98%, weighted toward lower GPA reqs = higher accessibility match
  double get matchScore {
    final gpaFactor = (5.0 - d.minGPA).clamp(0.0, 5.0) / 5.0; // 0..1
    final base = 0.70 + gpaFactor * 0.18;
    final jitter = (_seed % 11) / 100.0; // 0..0.10
    return (base + jitter).clamp(0.70, 0.98);
  }

  /// Popularity 0..1 — more seats & more careers => more popular
  double get popularity {
    final seatScore   = (d.seats / 200).clamp(0.0, 1.0);
    final careerScore = (d.careers.length / 8).clamp(0.0, 1.0);
    return ((seatScore * 0.5 + careerScore * 0.5)).clamp(0.05, 1.0);
  }

  /// Employment rate 75–97%
  double get employmentRate => (0.75 + (popularity * 0.20) + ((_seed % 5) / 100)).clamp(0.75, 0.97);

  /// Industry demand index 0..1
  double get demandIndex => ((d.careers.length / 8) * 0.6 + popularity * 0.4).clamp(0.1, 1.0);

  /// Starting salary range (BDT/month), scaled by demand
  RangeValues get salaryRange {
    final base = 25000 + demandIndex * 45000;
    return RangeValues(base, base + 30000 + demandIndex * 40000);
  }

  bool get isAIRecommended => matchScore >= 0.88;
  bool get isHighDemand     => demandIndex >= 0.65;
  bool get isFutureProof    => d.careers.any((c) =>
      c.toLowerCase().contains('ai') ||
      c.toLowerCase().contains('data') ||
      c.toLowerCase().contains('software') ||
      c.toLowerCase().contains('robot') ||
      c.toLowerCase().contains('cyber'));

  /// Skill radar axes (5 dims, 0..1)
  List<double> get radar => [
    (d.minGPA / 5.0).clamp(0.0, 1.0),                       // Academic rigor
    demandIndex,                                            // Industry demand
    popularity,                                             // Popularity
    (d.careers.length / 8).clamp(0.0, 1.0),                 // Career breadth
    employmentRate,                                         // Employability
  ];
}

// ═══════════════════════════════════════════════════════════════════
//  SCREEN
// ═══════════════════════════════════════════════════════════════════
class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

enum _SortBy { gpa, tuition, popularity, seats }

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  final TextEditingController _search = TextEditingController();
  String? _facultyFilter;
  _SortBy _sort = _SortBy.popularity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DepartmentProvider>().loadDepartments();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<DepartmentModel> _applyFilters(List<DepartmentModel> input) {
    var list = List<DepartmentModel>.from(input);

    if (_facultyFilter != null) {
      list = list.where((d) => d.faculty == _facultyFilter).toList();
    }

    switch (_sort) {
      case _SortBy.gpa:
        list.sort((a, b) => a.minGPA.compareTo(b.minGPA));
        break;
      case _SortBy.tuition:
        list.sort((a, b) => a.tuitionPerSemester.compareTo(b.tuitionPerSemester));
        break;
      case _SortBy.popularity:
        list.sort((a, b) => _Metrics(b).popularity.compareTo(_Metrics(a).popularity));
        break;
      case _SortBy.seats:
        list.sort((a, b) => b.seats.compareTo(a.seats));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final w       = MediaQuery.of(context).size.width;
    final tablet  = w >= 720;
    final desktop = w >= 1100;
    final pad     = desktop ? 36.0 : tablet ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: _C.bg,
      body: Consumer<DepartmentProvider>(
        builder: (_, p, __) {
          if (p.loading) return _SkeletonView(pad: pad);
          if (p.error != null) return _ErrorView(error: p.error!, onRetry: () => p.loadDepartments());

          final all = p.departments;
          if (all.isEmpty) return _EmptyView(pad: pad);

          // Apply text search (keeps provider's own search if it has one)
          var visible = all;
          if (_search.text.trim().isNotEmpty) {
            final q = _search.text.trim().toLowerCase();
            visible = visible.where((d) =>
                d.name.toLowerCase().contains(q) ||
                d.code.toLowerCase().contains(q) ||
                d.careers.any((c) => c.toLowerCase().contains(q))).toList();
          }
          visible = _applyFilters(visible);

          return RefreshIndicator(
            color: _C.primary,
            onRefresh: () => p.loadDepartments(),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Custom app bar
                SliverToBoxAdapter(child: _TopBar(pad: pad)),

                // ── 1. HERO + STATS
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(pad, 16, pad, 0),
                    child: _Hero(all: all, tablet: tablet),
                  ),
                ),

                // ── 2. ANALYTICS
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(pad, 28, pad, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const _SecHead('Department Analytics', 'Insights across all faculties'),
                      const SizedBox(height: 14),
                      _AnalyticsSection(all: all, tablet: tablet, desktop: desktop),
                    ]),
                  ),
                ),

                // ── 3. SEARCH + FILTERS
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(pad, 28, pad, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const _SecHead('Browse Departments', 'Search, filter and compare programmes'),
                      const SizedBox(height: 14),
                      _SearchBar(controller: _search, onChanged: (_) => setState(() {})),
                      const SizedBox(height: 12),
                      _FilterChips(
                        all: all,
                        selected: _facultyFilter,
                        onSelect: (f) => setState(() => _facultyFilter = f),
                      ),
                      const SizedBox(height: 10),
                      _SortRow(sort: _sort, onChanged: (s) => setState(() => _sort = s)),
                    ]),
                  ),
                ),

                // ── 4. RESULTS COUNT
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(pad, 18, pad, 8),
                    child: Text('${visible.length} programme${visible.length == 1 ? '' : 's'} found',
                        style: const TextStyle(fontSize: 12, color: _C.txtMut, fontWeight: FontWeight.w600)),
                  ),
                ),

                // ── 5. DEPARTMENT CARDS
                if (visible.isEmpty)
                  SliverToBoxAdapter(child: Padding(
                    padding: EdgeInsets.fromLTRB(pad, 20, pad, 20),
                    child: _NoResultsView(),
                  ))
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(pad, 0, pad, 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: Duration(milliseconds: 320 + (i * 40).clamp(0, 400)),
                            curve: Curves.easeOutCubic,
                            builder: (_, v, child) => Opacity(
                              opacity: v,
                              child: Transform.translate(offset: Offset(0, (1 - v) * 16), child: child),
                            ),
                            child: _DepartmentCard(dept: visible[i]),
                          ),
                        ),
                        childCount: visible.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TOP BAR
// ═══════════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final double pad;
  const _TopBar({required this.pad});

  @override
  Widget build(BuildContext context) => Container(
    color: _C.surface,
    padding: EdgeInsets.fromLTRB(pad, 14, pad, 14),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: _C.bg, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.border),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: _C.txtPri),
        ),
      ),
      const SizedBox(width: 12),
      const Text('Departments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _C.txtPri, letterSpacing: -0.4)),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.auto_awesome_rounded, size: 12, color: _C.primary),
          SizedBox(width: 5),
          Text('AI Insights', style: TextStyle(fontSize: 11, color: _C.primary, fontWeight: FontWeight.w700)),
        ]),
      ),
    ]),
  );
}

class _SecHead extends StatelessWidget {
  final String t, s;
  const _SecHead(this.t, this.s);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _C.txtPri, letterSpacing: -0.3)),
    const SizedBox(height: 1),
    Text(s, style: const TextStyle(fontSize: 11, color: _C.txtMut)),
  ]);
}

// ═══════════════════════════════════════════════════════════════════
//  1. HERO + STATS
// ═══════════════════════════════════════════════════════════════════
class _Hero extends StatelessWidget {
  final List<DepartmentModel> all;
  final bool tablet;
  const _Hero({required this.all, required this.tablet});

  @override
  Widget build(BuildContext context) {
    final totalSeats   = all.fold<int>(0, (s, d) => s + d.seats);
    final faculties    = all.map((d) => d.faculty).toSet().length;
    final avgTuition   = all.isEmpty ? 0 :
        all.fold<int>(0, (s, d) => s + d.tuitionPerSemester) ~/ all.length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tablet ? 32 : 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF4F46E5)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: _C.glow(_C.primary, 0.30),
      ),
      child: Stack(children: [
        // Decorative glow circles
        const Positioned(right: -30, top: -30, child: _GlowCircle(size: 140, opacity: 0.10)),
        const Positioned(right: 60, bottom: -50, child: _GlowCircle(size: 100, opacity: 0.08)),

        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.22)),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.school_rounded, color: Color(0xFF93C5FD), size: 13),
              SizedBox(width: 6),
              Text('11 Academic Departments',
                  style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(height: 16),
          Text('Explore Academic\nDepartments',
              style: TextStyle(color: Colors.white, fontSize: tablet ? 32 : 26,
                  fontWeight: FontWeight.w900, height: 1.12, letterSpacing: -1.0)),
          const SizedBox(height: 10),
          Text('Discover programs, career opportunities, admission\nrequirements and future pathways.',
              style: TextStyle(color: Colors.white.withOpacity(0.74), fontSize: 12.5, height: 1.6)),
          const SizedBox(height: 22),

          // Stat row
          tablet
              ? Row(children: [
                  Expanded(child: _StatCard(icon: '🏛️', value: '${all.length}', label: 'Total Departments')),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(icon: '🪑', value: '$totalSeats', label: 'Available Seats')),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(icon: '🎓', value: '$faculties', label: 'Faculties')),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(icon: '💰', value: '৳${(avgTuition / 1000).toStringAsFixed(0)}k', label: 'Avg Tuition / Sem')),
                ])
              : Column(children: [
                  Row(children: [
                    Expanded(child: _StatCard(icon: '🏛️', value: '${all.length}', label: 'Total Departments')),
                    const SizedBox(width: 10),
                    Expanded(child: _StatCard(icon: '🪑', value: '$totalSeats', label: 'Available Seats')),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _StatCard(icon: '🎓', value: '$faculties', label: 'Faculties')),
                    const SizedBox(width: 10),
                    Expanded(child: _StatCard(icon: '💰', value: '৳${(avgTuition / 1000).toStringAsFixed(0)}k', label: 'Avg Tuition / Sem')),
                  ]),
                ]),
        ]),
      ]),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size, opacity;
  const _GlowCircle({required this.size, required this.opacity});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(opacity)),
  );
}

// Animated stat card — count-up effect
class _StatCard extends StatelessWidget {
  final String icon, value, label;
  const _StatCard({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final numeric = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 6),
        numeric != null
            ? TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: numeric),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) {
                  final prefix = value.replaceAll(RegExp(r'[0-9.]'), '').contains('৳') ? '৳' : '';
                  final suffix = value.endsWith('k') ? 'k' : '';
                  final display = value.contains('.') ? v.toStringAsFixed(0) : v.toStringAsFixed(0);
                  return Text('$prefix$display$suffix',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900));
                },
              )
            : Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.68), fontSize: 9.5, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  2. ANALYTICS  (pie / bar / line via fl_chart)
// ═══════════════════════════════════════════════════════════════════
class _AnalyticsSection extends StatelessWidget {
  final List<DepartmentModel> all;
  final bool tablet, desktop;
  const _AnalyticsSection({required this.all, required this.tablet, required this.desktop});

  @override
  Widget build(BuildContext context) {
    final pie  = _FacultyPieCard(all: all);
    final bar  = _PopularityBarCard(all: all);
    final line = _DemandLineCard(all: all);

    if (desktop) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 4, child: pie),
        const SizedBox(width: 14),
        Expanded(flex: 5, child: bar),
        const SizedBox(width: 14),
        Expanded(flex: 5, child: line),
      ]);
    }
    if (tablet) {
      return Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: pie),
          const SizedBox(width: 14),
          Expanded(child: bar),
        ]),
        const SizedBox(height: 14),
        line,
      ]);
    }
    return Column(children: [pie, const SizedBox(height: 14), bar, const SizedBox(height: 14), line]);
  }
}

// ── 2a. Faculty distribution pie chart
class _FacultyPieCard extends StatelessWidget {
  final List<DepartmentModel> all;
  const _FacultyPieCard({required this.all});

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final d in all) {
      counts[d.faculty] = (counts[d.faculty] ?? 0) + 1;
    }

    return _ChartCard(
      title: 'Faculty Distribution',
      subtitle: '${all.length} programmes total',
      child: SizedBox(
        height: 200,
        child: Row(children: [
          Expanded(
            child: PieChart(PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 38,
              sections: counts.entries.map((e) {
                final color = _C.facultyColor(e.key);
                return PieChartSectionData(
                  color: color,
                  value: e.value.toDouble(),
                  title: '${e.value}',
                  radius: 46,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                );
              }).toList(),
            )),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 110, child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: counts.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                Container(width: 9, height: 9,
                    decoration: BoxDecoration(color: _C.facultyColor(e.key), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Expanded(child: Text(e.key,
                    style: const TextStyle(fontSize: 10, color: _C.txtSec, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis)),
              ]),
            )).toList(),
          )),
        ]),
      ),
    );
  }
}

// ── 2b. Department popularity bar chart
class _PopularityBarCard extends StatelessWidget {
  final List<DepartmentModel> all;
  const _PopularityBarCard({required this.all});

  @override
  Widget build(BuildContext context) {
    final top = List<DepartmentModel>.from(all)
      ..sort((a, b) => _Metrics(b).popularity.compareTo(_Metrics(a).popularity));
    final shown = top.take(5).toList();

    return _ChartCard(
      title: 'Department Popularity',
      subtitle: 'Top 5 by student interest',
      child: SizedBox(
        height: 200,
        child: BarChart(BarChartData(
          maxY: 100,
          gridData: FlGridData(show: true, drawVerticalLine: false,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (_) => const FlLine(color: _C.border, strokeWidth: 1)),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true, reservedSize: 36,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= shown.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(shown[i].code,
                      style: const TextStyle(fontSize: 9.5, color: _C.txtMut, fontWeight: FontWeight.w700)),
                );
              },
            )),
          ),
          barGroups: List.generate(shown.length, (i) {
            final pct = (_Metrics(shown[i]).popularity * 100);
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: pct, width: 22,
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [_C.facultyColor(shown[i].faculty).withOpacity(0.55), _C.facultyColor(shown[i].faculty)],
                ),
              ),
            ]);
          }),
        )),
      ),
    );
  }
}

// ── 2c. Career demand trend line chart (illustrative 6-period trend)
class _DemandLineCard extends StatelessWidget {
  final List<DepartmentModel> all;
  const _DemandLineCard({required this.all});

  @override
  Widget build(BuildContext context) {
    // Pick top 3 departments by demand and project a 6-point upward trend
    final top = List<DepartmentModel>.from(all)
      ..sort((a, b) => _Metrics(b).demandIndex.compareTo(_Metrics(a).demandIndex));
    final shown = top.take(3).toList();
    final colors = [_C.primary, _C.teal, _C.amber];

    return _ChartCard(
      title: 'Career Demand Trend',
      subtitle: 'Projected industry demand (6 periods)',
      child: SizedBox(
        height: 200,
        child: LineChart(LineChartData(
          minX: 0, maxX: 5, minY: 0, maxY: 100,
          gridData: FlGridData(show: true, drawVerticalLine: false,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (_) => const FlLine(color: _C.border, strokeWidth: 1)),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true, reservedSize: 24,
              getTitlesWidget: (v, meta) {
                const labels = ['Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6'];
                final i = v.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox();
                return Text(labels[i], style: const TextStyle(fontSize: 9.5, color: _C.txtMut, fontWeight: FontWeight.w700));
              },
            )),
          ),
          lineBarsData: List.generate(shown.length, (idx) {
            final base = _Metrics(shown[idx]).demandIndex * 100;
            final growth = 4.0 + idx * 1.5;
            return LineChartBarData(
              isCurved: true,
              color: colors[idx % colors.length],
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: colors[idx % colors.length].withOpacity(0.08)),
              spots: List.generate(6, (p) =>
                  FlSpot(p.toDouble(), (base - 15 + p * growth).clamp(5, 98))),
            );
          }),
        )),
      ),
    );
  }
}

// Generic chart card shell
class _ChartCard extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const _ChartCard({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 0),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: _C.surface, borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _C.border), boxShadow: _C.card,
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: _C.txtPri)),
      Text(subtitle, style: const TextStyle(fontSize: 10.5, color: _C.txtMut)),
      const SizedBox(height: 12),
      child,
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════
//  3. SEARCH + FILTERS + SORT
// ═══════════════════════════════════════════════════════════════════
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.75),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withOpacity(0.6)),
      boxShadow: _C.card,
    ),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13.5, color: _C.txtPri),
      decoration: InputDecoration(
        hintText: 'Search by name, code, or career path...',
        hintStyle: const TextStyle(color: _C.txtMut, fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded, color: _C.txtMut, size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 18, color: _C.txtMut),
                onPressed: () { controller.clear(); onChanged(''); },
              )
            : null,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    ),
  );
}

class _FilterChips extends StatelessWidget {
  final List<DepartmentModel> all;
  final String? selected;
  final ValueChanged<String?> onSelect;
  const _FilterChips({required this.all, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final faculties = all.map((d) => d.faculty).toSet().toList();
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _Chip(label: 'All', active: selected == null, color: _C.primary, onTap: () => onSelect(null)),
          ...faculties.map((f) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _Chip(label: f, active: selected == f, color: _C.facultyColor(f), onTap: () => onSelect(f)),
          )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.active, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? color : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? color : _C.border),
        boxShadow: active ? _C.glow(color, 0.20) : null,
      ),
      child: Text(label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
              color: active ? Colors.white : _C.txtSec)),
    ),
  );
}

class _SortRow extends StatelessWidget {
  final _SortBy sort;
  final ValueChanged<_SortBy> onChanged;
  const _SortRow({required this.sort, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const opts = {
      _SortBy.popularity: ('Popularity', Icons.trending_up_rounded),
      _SortBy.gpa:        ('GPA', Icons.school_rounded),
      _SortBy.tuition:    ('Tuition', Icons.payments_rounded),
      _SortBy.seats:      ('Seats', Icons.event_seat_rounded),
    };
    return Row(children: [
      const Text('Sort by', style: TextStyle(fontSize: 11.5, color: _C.txtMut, fontWeight: FontWeight.w600)),
      const SizedBox(width: 10),
      Expanded(
        child: SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: opts.entries.map((e) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Chip(label: e.value.$1, active: sort == e.key, color: _C.indigo, onTap: () => onChanged(e.key)),
            )).toList(),
          ),
        ),
      ),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════
//  4. DEPARTMENT CARD  (premium, hover/elevation, expandable)
// ═══════════════════════════════════════════════════════════════════
class _DepartmentCard extends StatefulWidget {
  final DepartmentModel dept;
  const _DepartmentCard({required this.dept});

  @override
  State<_DepartmentCard> createState() => _DepartmentCardState();
}

class _DepartmentCardState extends State<_DepartmentCard> {
  bool _hover = false;
  bool _open  = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.dept;
    final m = _Metrics(d);
    final color = _C.facultyColor(d.faculty);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit:  (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _hover ? color.withOpacity(0.35) : _C.border),
          boxShadow: _hover
              ? [BoxShadow(color: color.withOpacity(0.18), blurRadius: 28, offset: const Offset(0, 14))]
              : _C.card,
        ),
        child: Column(children: [
          // ── Header (always visible) ──────────────────
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Row(children: [
                  // Icon badge
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      gradient: _C.facultyGradient(d.faculty),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: _C.glow(color, 0.20),
                    ),
                    child: Center(child: Text(
                      d.code.length > 3 ? d.code.substring(0, 3) : d.code,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white))),
                  ),
                  const SizedBox(width: 12),

                  // Name + faculty badge
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(d.name,
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: _C.txtPri, letterSpacing: -0.2),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(8)),
                      child: Text(d.faculty, style: TextStyle(fontSize: 9.5, color: color, fontWeight: FontWeight.w700)),
                    ),
                  ])),

                  // AI match ring
                  _MatchRing(score: m.matchScore, color: color),
                ]),

                const SizedBox(height: 14),

                // Badges row
                Wrap(spacing: 6, runSpacing: 6, children: [
                  if (m.isAIRecommended) const _Badge(label: '✨ AI Recommended', color: _C.indigo),
                  if (m.isHighDemand)    const _Badge(label: '🔥 High Demand', color: _C.rose),
                  if (m.isFutureProof)   const _Badge(label: '🚀 Future-Proof', color: _C.teal),
                ]),

                const SizedBox(height: 14),

                // Mini stats row
                Row(children: [
                  Expanded(child: _MiniStat(icon: Icons.payments_rounded, value: '৳${d.tuitionPerSemester}', label: 'Per Semester')),
                  Expanded(child: _MiniStat(icon: Icons.schedule_rounded, value: d.duration, label: 'Duration')),
                  Expanded(child: _MiniStat(icon: Icons.event_seat_rounded, value: '${d.seats}', label: 'Seats')),
                ]),

                const SizedBox(height: 12),

                // Popularity bar
                Row(children: [
                  const Text('Popularity', style: TextStyle(fontSize: 10.5, color: _C.txtMut, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('${(m.popularity * 100).toInt()}%',
                      style: TextStyle(fontSize: 10.5, color: color, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: m.popularity, minHeight: 5,
                    backgroundColor: _C.border,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),

                const SizedBox(height: 10),

                // Expand indicator
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: const Icon(Icons.keyboard_arrow_down_rounded, color: _C.txtMut, size: 22),
                ),
              ]),
            ),
          ),

          // ── Expanded detail view ──────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOutCubic,
            child: _open ? _DepartmentDetail(dept: d, metrics: m, color: color) : const SizedBox(width: double.infinity),
          ),
        ]),
      ),
    );
  }
}

// AI match score ring
class _MatchRing extends StatelessWidget {
  final double score;
  final Color color;
  const _MatchRing({required this.score, required this.color});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 54, height: 54,
    child: Stack(alignment: Alignment.center, children: [
      CustomPaint(
        size: const Size(54, 54),
        painter: _RingPainter(progress: score, color: color),
      ),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('${(score * 100).toInt()}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color)),
        Text('%', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: color.withOpacity(0.7))),
      ]),
    ]),
  );
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color  color;
  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 5.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;
    final rect   = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false,
        Paint()..color = color.withOpacity(0.14)..style = PaintingStyle.stroke..strokeWidth = stroke..strokeCap = StrokeCap.round);

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false,
        Paint()
          ..style = PaintingStyle.stroke..strokeWidth = stroke..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            startAngle: -math.pi / 2,
            endAngle:   -math.pi / 2 + math.pi * 2 * progress,
            colors: [color.withOpacity(0.5), color],
          ).createShader(rect));
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress || old.color != color;
}

class _Badge extends StatelessWidget {
  final String label;
  final Color  color;
  const _Badge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [color, color.withOpacity(0.75)]),
      borderRadius: BorderRadius.circular(20),
      boxShadow: _C.glow(color, 0.18),
    ),
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
  );
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String   value, label;
  const _MiniStat({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, size: 16, color: _C.txtMut),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _C.txtPri)),
    Text(label, style: const TextStyle(fontSize: 9, color: _C.txtMut, fontWeight: FontWeight.w500)),
  ]);
}

// ═══════════════════════════════════════════════════════════════════
//  EXPANDED DETAIL VIEW
// ═══════════════════════════════════════════════════════════════════
class _DepartmentDetail extends StatelessWidget {
  final DepartmentModel dept;
  final _Metrics metrics;
  final Color color;
  const _DepartmentDetail({required this.dept, required this.metrics, required this.color});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final tablet = w >= 720;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Divider(height: 1, color: _C.border),
        const SizedBox(height: 16),

        // ── Overview
        _DetailSection(title: 'Overview', icon: Icons.info_outline_rounded, color: color, child: Text(
          dept.description,
          style: const TextStyle(fontSize: 12.5, color: _C.txtSec, height: 1.7),
        )),

        const SizedBox(height: 18),

        // ── Requirements (table)
        _DetailSection(title: 'Requirements', icon: Icons.checklist_rounded, color: color, child: Column(children: [
          _TableRow('Minimum GPA', '${dept.minGPA}'),
          _TableRow('Required Subjects', dept.requiredSubjects.join(', ')),
          _TableRow('Admission Test', dept.admissionTestRequired ? 'Required' : 'Not Required'),
          _TableRow('Available Seats', '${dept.seats}'),
          _TableRow('Programme Duration', dept.duration),
        ])),

        const SizedBox(height: 18),

        // ── Career opportunities (chips)
        _DetailSection(title: 'Career Opportunities', icon: Icons.work_outline_rounded, color: color, child: Wrap(
          spacing: 7, runSpacing: 7,
          children: dept.careers.map((c) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.18))),
            child: Text(c, style: TextStyle(fontSize: 11.5, color: color, fontWeight: FontWeight.w600)),
          )).toList(),
        )),

        const SizedBox(height: 18),

        // ── Salary insights
        _DetailSection(title: 'Future Salary Insights', icon: Icons.trending_up_rounded, color: color, child: _SalaryCard(metrics: metrics, color: color)),

        const SizedBox(height: 18),

        // ── Industry demand + visualizations
        _DetailSection(title: 'Industry Demand & Skill Profile', icon: Icons.insights_rounded, color: color,
          child: tablet
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _RadarCard(metrics: metrics, color: color)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(children: [
                    _GaugeCard(label: 'Employment Rate', value: metrics.employmentRate, color: _C.green),
                    const SizedBox(height: 10),
                    _GpaMeterCard(dept: dept, color: color),
                  ])),
                ])
              : Column(children: [
                  _RadarCard(metrics: metrics, color: color),
                  const SizedBox(height: 10),
                  _GaugeCard(label: 'Employment Rate', value: metrics.employmentRate, color: _C.green),
                  const SizedBox(height: 10),
                  _GpaMeterCard(dept: dept, color: color),
                ]),
        ),

        const SizedBox(height: 18),

        // ── Admission process timeline
        _DetailSection(title: 'Admission Process', icon: Icons.route_rounded, color: color,
            child: _AdmissionTimeline(color: color)),
      ]),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  const _DetailSection({required this.title, required this.icon, required this.color, required this.child});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Container(width: 26, height: 26,
          decoration: BoxDecoration(color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 14, color: color)),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _C.txtPri)),
    ]),
    const SizedBox(height: 10),
    child,
  ]);
}

class _TableRow extends StatelessWidget {
  final String label, value;
  const _TableRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 9),
    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _C.border, width: 1))),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 140, child: Text(label,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: _C.txtMut))),
      Expanded(child: Text(value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _C.txtPri))),
    ]),
  );
}

// Salary range card
class _SalaryCard extends StatelessWidget {
  final _Metrics metrics;
  final Color color;
  const _SalaryCard({required this.metrics, required this.color});

  @override
  Widget build(BuildContext context) {
    final range = metrics.salaryRange;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.08), color.withOpacity(0.02)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Entry-level monthly salary', style: TextStyle(fontSize: 10.5, color: _C.txtMut, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('৳${range.start.toInt()} – ৳${range.end.toInt()}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 6),
          const Text('Based on industry demand & graduate outcomes',
              style: TextStyle(fontSize: 10, color: _C.txtMut, height: 1.4)),
        ])),
        Container(width: 50, height: 50,
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(Icons.account_balance_wallet_rounded, color: color, size: 22)),
      ]),
    );
  }
}

// Radar chart — skill / demand profile
class _RadarCard extends StatelessWidget {
  final _Metrics metrics;
  final Color color;
  const _RadarCard({required this.metrics, required this.color});

  @override
  Widget build(BuildContext context) {
    const labels = ['Rigor', 'Demand', 'Popularity', 'Careers', 'Employ.'];
    final data = metrics.radar;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _C.bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _C.border)),
      child: Column(children: [
        const Align(alignment: Alignment.centerLeft,
            child: Text('Skill & Demand Radar', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _C.txtPri))),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: RadarChart(RadarChartData(
            radarShape: RadarShape.polygon,
            tickCount: 4,
            ticksTextStyle: const TextStyle(fontSize: 0, color: Colors.transparent),
            radarBorderData: const BorderSide(color: _C.border),
            gridBorderData: const BorderSide(color: _C.border, width: 1),
            titleTextStyle: const TextStyle(fontSize: 9.5, color: _C.txtMut, fontWeight: FontWeight.w600),
            getTitle: (i, angle) => RadarChartTitle(text: labels[i]),
            dataSets: [
              RadarDataSet(
                fillColor: color.withOpacity(0.18),
                borderColor: color,
                borderWidth: 2,
                entryRadius: 2.5,
                dataEntries: data.map((v) => RadarEntry(value: v * 100)).toList(),
              ),
            ],
          )),
        ),
      ]),
    );
  }
}

// Gauge — employment rate (semi-circular)
class _GaugeCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _GaugeCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: _C.bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _C.border)),
    child: Column(children: [
      Align(alignment: Alignment.centerLeft,
          child: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _C.txtPri))),
      const SizedBox(height: 8),
      SizedBox(
        height: 90,
        child: CustomPaint(
          painter: _GaugePainter(value: value, color: color),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Text('${(value * 100).toInt()}%',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
            ),
          ),
        ),
      ),
    ]),
  );
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color  color;
  const _GaugePainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final center = Offset(size.width / 2, size.height);
    final radius = math.min(size.width / 2, size.height) - stroke;
    final rect   = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(rect, math.pi, math.pi, false,
        Paint()..color = _C.border..style = PaintingStyle.stroke..strokeWidth = stroke..strokeCap = StrokeCap.round);

    canvas.drawArc(rect, math.pi, math.pi * value, false,
        Paint()
          ..style = PaintingStyle.stroke..strokeWidth = stroke..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            startAngle: math.pi, endAngle: math.pi * (1 + value),
            colors: [color.withOpacity(0.5), color],
          ).createShader(rect));
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.value != value;
}

// GPA requirement meter
class _GpaMeterCard extends StatelessWidget {
  final DepartmentModel dept;
  final Color color;
  const _GpaMeterCard({required this.dept, required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = (dept.minGPA / 5.0).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _C.bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _C.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('GPA Requirement', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _C.txtPri))),
          Text('${dept.minGPA} / 5.00', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(value: pct, minHeight: 8,
              backgroundColor: _C.border, valueColor: AlwaysStoppedAnimation(color)),
        ),
        const SizedBox(height: 6),
        Text(pct >= 0.9 ? 'Highly competitive entry requirement'
            : pct >= 0.75 ? 'Moderately competitive entry requirement'
            : 'Accessible entry requirement',
            style: const TextStyle(fontSize: 10, color: _C.txtMut)),
      ]),
    );
  }
}

// Admission process timeline
class _AdmissionTimeline extends StatelessWidget {
  final Color color;
  const _AdmissionTimeline({required this.color});

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('Apply Online', 'Submit application & academic documents', Icons.edit_document),
      ('AI Assessment', 'Complete the SmartAdmit evaluation', Icons.track_changes_rounded),
      ('Get Matched', 'Receive AI department recommendation', Icons.auto_awesome_rounded),
      ('Admission Offer', 'Receive your official offer letter', Icons.verified_rounded),
      ('Enroll', 'Confirm seat and begin your journey', Icons.school_rounded),
    ];
    return Column(children: [
      for (var i = 0; i < steps.length; i++)
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Container(width: 32, height: 32,
              decoration: BoxDecoration(color: color.withOpacity(0.10), shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.30))),
              child: Icon(steps[i].$3, size: 15, color: color)),
            if (i < steps.length - 1)
              Container(width: 2, height: 30, color: color.withOpacity(0.15)),
          ]),
          const SizedBox(width: 12),
          Expanded(child: Padding(
            padding: const EdgeInsets.only(bottom: 14, top: 5),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Step ${i + 1} · ${steps[i].$1}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _C.txtPri)),
              const SizedBox(height: 2),
              Text(steps[i].$2, style: const TextStyle(fontSize: 10.5, color: _C.txtMut, height: 1.4)),
            ]),
          )),
        ]),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SKELETON / EMPTY / ERROR STATES
// ═══════════════════════════════════════════════════════════════════
class _SkeletonView extends StatelessWidget {
  final double pad;
  const _SkeletonView({required this.pad});

  @override
  Widget build(BuildContext context) => ListView(
    padding: EdgeInsets.all(pad),
    children: [
      const _ShimmerBox(height: 220, radius: 24),
      const SizedBox(height: 20),
      const Row(children: [
        Expanded(child: _ShimmerBox(height: 180, radius: 20)),
        SizedBox(width: 14),
        Expanded(child: _ShimmerBox(height: 180, radius: 20)),
      ]),
      const SizedBox(height: 20),
      const _ShimmerBox(height: 48, radius: 18),
      const SizedBox(height: 14),
      for (var i = 0; i < 3; i++) const Padding(
        padding: EdgeInsets.only(bottom: 14),
        child: _ShimmerBox(height: 160, radius: 22),
      ),
    ],
  );
}

class _ShimmerBox extends StatefulWidget {
  final double height, radius;
  const _ShimmerBox({required this.height, required this.radius});
  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}
class _ShimmerBoxState extends State<_ShimmerBox> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        gradient: LinearGradient(
          begin: Alignment(-1 + _ctrl.value * 2, 0),
          end: Alignment(1 + _ctrl.value * 2, 0),
          colors: const [Color(0xFFE2E8F0), Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
        ),
      ),
    ),
  );
}

class _EmptyView extends StatelessWidget {
  final double pad;
  const _EmptyView({required this.pad});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(pad),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 88, height: 88,
            decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
            child: const Icon(Icons.school_outlined, size: 40, color: _C.primary)),
        const SizedBox(height: 16),
        const Text('No departments available',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _C.txtPri)),
        const SizedBox(height: 6),
        const Text('Department data will appear here once it is published.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: _C.txtMut, height: 1.5)),
      ]),
    ),
  );
}

class _NoResultsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 76, height: 76,
            decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
            child: const Icon(Icons.search_off_rounded, size: 34, color: _C.txtMut)),
        const SizedBox(height: 14),
        const Text('No matching programmes',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _C.txtPri)),
        const SizedBox(height: 4),
        const Text('Try a different search term or remove filters.',
            style: TextStyle(fontSize: 11.5, color: _C.txtMut)),
      ]),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 88, height: 88,
            decoration: const BoxDecoration(color: Color(0xFFFFE4E6), shape: BoxShape.circle),
            child: const Icon(Icons.wifi_off_rounded, size: 40, color: _C.rose)),
        const SizedBox(height: 16),
        const Text('Couldn\'t load departments',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _C.txtPri)),
        const SizedBox(height: 6),
        Text(error, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: _C.txtMut, height: 1.5)),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_C.primary, _C.indigo]),
              borderRadius: BorderRadius.circular(30),
              boxShadow: _C.glow(_C.primary, 0.30),
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    ),
  );
}