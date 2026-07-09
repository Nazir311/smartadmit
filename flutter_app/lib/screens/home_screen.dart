import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'departments_screen.dart';
import 'faq_screen.dart';
import 'recommend_screen.dart';
import 'student_profile_screen.dart';
import 'recommendation_screen.dart';
import 'report_screen.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _C {
  static const primary     = Color(0xFF2563EB);
  static const primaryDk   = Color(0xFF1D4ED8);
  static const accent      = Color(0xFF3B82F6);
  static const dark        = Color(0xFF0F172A);
  static const dark2       = Color(0xFF1E293B);
  static const dark3       = Color(0xFF334155);
  static const bg          = Color(0xFFF8FAFC);
  static const surface     = Colors.white;
  static const border      = Color(0xFFE2E8F0);
  static const txtPri      = Color(0xFF0F172A);
  static const txtSec      = Color(0xFF475569);
  static const txtMut      = Color(0xFF94A3B8);
  static const teal        = Color(0xFF0D9488);
  static const amber       = Color(0xFFF59E0B);
  static const rose        = Color(0xFFF43F5E);
  static const violet      = Color(0xFF7C3AED);
  static const green       = Color(0xFF16A34A);

  static const sidebarW   = 248.0;
  static const radiusLg   = 24.0;
  static const radiusMd   = 20.0;
  static const radiusSm   = 14.0;

  // Glass surface tokens
  static Color glassFill  = Colors.white.withOpacity(0.66);
  static Color glassBrd   = Colors.white.withOpacity(0.55);

  static List<BoxShadow> card = [
    const BoxShadow(color: Color(0x140F172A), blurRadius: 30, offset: Offset(0, 10)),
    const BoxShadow(color: Color(0x080F172A), blurRadius: 6,  offset: Offset(0, 1)),
  ];
  static List<BoxShadow> cardSoft = [
    const BoxShadow(color: Color(0x0D0F172A), blurRadius: 18, offset: Offset(0, 6)),
  ];
  static List<BoxShadow> glow(Color c, [double o = 0.28]) => [
    BoxShadow(color: c.withOpacity(o), blurRadius: 28, offset: const Offset(0, 10)),
  ];
  static List<BoxShadow> glowBtn(Color c) => [
    BoxShadow(color: c.withOpacity(0.45), blurRadius: 20, spreadRadius: -2, offset: const Offset(0, 8)),
  ];

  static const LinearGradient brandGrad = LinearGradient(
    colors: [primary, Color(0xFF6366F1), violet],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
}
class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final List<BoxShadow>? shadow;

  const _GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 20,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadow ?? _C.card,
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Colors.white.withOpacity(0.82), Colors.white.withOpacity(0.60)],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.2),
          ),
          child: child,
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────
//  NAV ITEM
// ─────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String   label;
  final Widget?  screen;
  const _NavItem(this.icon, this.label, [this.screen]);
}

// ═══════════════════════════════════════════════════════════════════
//  ROOT  –  HomeScreen
// ═══════════════════════════════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _sel = 0;
  final _key = GlobalKey<ScaffoldState>();

  static const _nav = [
    _NavItem(Icons.dashboard_rounded,         'Dashboard'),
    _NavItem(Icons.account_circle_rounded,    'My Profile',    StudentProfileScreen()),
    _NavItem(Icons.track_changes_rounded,     'Assessment',    RecommendScreen()),
    _NavItem(Icons.account_balance_rounded,   'Departments',   DepartmentsScreen()),
    _NavItem(Icons.workspace_premium_rounded, 'Scholarships',  RecommendationScreen()),
    _NavItem(Icons.route_rounded,             'Career Roadmap',RecommendationScreen()),
    _NavItem(Icons.picture_as_pdf_rounded,    'Reports',       ReportScreen()),
    _NavItem(Icons.help_outline_rounded,      'FAQ',           FAQScreen()),
  ];

  void _push(Widget s) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    final w    = MediaQuery.of(context).size.width;
    final wide = w >= 720;

    Widget body = _sel == 0
        ? _Body(onNav: _push)
        : (_nav[_sel].screen ?? const SizedBox());

    if (wide) {
      return Scaffold(
        backgroundColor: _C.bg,
        body: Row(children: [
          _Sidebar(nav: _nav, sel: _sel, onSel: (i) => setState(() => _sel = i)),
          Expanded(child: body),
        ]),
      );
    }

    return Scaffold(
      key: _key,
      backgroundColor: _C.bg,
      drawer: Drawer(
        width: _C.sidebarW,
        child: _Sidebar(
          nav: _nav, sel: _sel,
          onSel: (i) { Navigator.pop(context); setState(() => _sel = i); },
        ),
      ),
      body: SafeArea(child: Column(children: [
        _MobileBar(onMenu: () => _key.currentState?.openDrawer()),
        Expanded(child: body),
      ])),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SIDEBAR
// ═══════════════════════════════════════════════════════════════════
class _Sidebar extends StatelessWidget {
  final List<_NavItem> nav;
  final int sel;
  final ValueChanged<int> onSel;
  const _Sidebar({required this.nav, required this.sel, required this.onSel});

  @override
  Widget build(BuildContext context) => Container(
    width: _C.sidebarW,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [_C.dark, Color(0xFF0B1220)],
      ),
      border: const Border(right: BorderSide(color: Color(0xFF1E293B))),
      boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 30, offset: Offset(6, 0))],
    ),
    child: Stack(children: [
      // Ambient glow blob
      Positioned(top: -60, left: -60, child: Container(
        width: 200, height: 200,
        decoration: BoxDecoration(shape: BoxShape.circle,
          gradient: RadialGradient(colors: [_C.primary.withOpacity(0.22), Colors.transparent])),
      )),
      SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Logo ──────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 18, 30),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: _C.brandGrad,
                borderRadius: BorderRadius.circular(12),
                boxShadow: _C.glow(_C.primary, 0.40),
              ),
              child: const Center(child: Text('🎓', style: TextStyle(fontSize: 19))),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('SmartAdmit',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.4)),
              Text('DIU · AI Platform',
                  style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.40), letterSpacing: 0.2)),
            ]),
          ]),
        ),

        // ── Menu label ────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 20, 12),
          child: Text('NAVIGATION',
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.26), letterSpacing: 1.6)),
        ),

        // ── Nav items ─────────────────────────
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: nav.length,
          itemBuilder: (_, i) => _SidebarItem(
            item: nav[i], active: i == sel, onTap: () => onSel(i),
          ),
        )),

        // ── User chip ─────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155)),
              boxShadow: const [BoxShadow(color: Color(0x30000000), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: _C.brandGrad,
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Text('S',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15))),
              ),
              const SizedBox(width: 11),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Student', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                Text('Free Account', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
              ])),
              const Icon(Icons.settings_outlined, color: Color(0xFF475569), size: 16),
            ]),
          ),
        ),
      ])),
    ]),
  );
}

class _SidebarItem extends StatefulWidget {
  final _NavItem item;
  final bool     active;
  final VoidCallback onTap;
  const _SidebarItem({required this.item, required this.active, required this.onTap});
  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final on = widget.active || _hover;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit:  (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 3),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            gradient: widget.active
                ? LinearGradient(colors: [_C.primary.withOpacity(0.28), _C.violet.withOpacity(0.16)])
                : null,
            color: !widget.active && _hover ? const Color(0xFF1A2436) : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            border: widget.active
                ? Border.all(color: _C.primary.withOpacity(0.45))
                : null,
            boxShadow: widget.active ? _C.glow(_C.primary, 0.14) : null,
          ),
          child: Row(children: [
            Icon(widget.item.icon, size: 17,
                color: widget.active ? const Color(0xFF93C5FD)
                    : on ? Colors.white.withOpacity(0.70)
                    : const Color(0xFF64748B)),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.item.label,
                style: TextStyle(fontSize: 13,
                    fontWeight: widget.active ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: -0.1,
                    color: widget.active ? Colors.white
                        : on ? Colors.white.withOpacity(0.75)
                        : const Color(0xFF94A3B8)))),
            if (widget.active)
              Container(width: 6, height: 6,
                  decoration: BoxDecoration(color: _C.accent, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: _C.accent.withOpacity(0.7), blurRadius: 8)])),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE BAR
// ─────────────────────────────────────────────
class _MobileBar extends StatelessWidget {
  final VoidCallback onMenu;
  const _MobileBar({required this.onMenu});
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [_C.dark, Color(0xFF0B1220)],
      ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      GestureDetector(onTap: onMenu, child: const Icon(Icons.menu_rounded, color: Colors.white, size: 22)),
      const SizedBox(width: 12),
      Container(
        width: 30, height: 30,
        decoration: BoxDecoration(gradient: _C.brandGrad, borderRadius: BorderRadius.circular(9)),
        child: const Center(child: Text('🎓', style: TextStyle(fontSize: 15))),
      ),
      const SizedBox(width: 10),
      const Text('DIU SmartAdmit',
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
      const Spacer(),
      _AiLivePill(),
    ]),
  );
}

class _AiLivePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFF14532D),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.35)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 6, height: 6, decoration: BoxDecoration(color: const Color(0xFF4ADE80),
          shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF4ADE80).withOpacity(0.7), blurRadius: 6)])),
      const SizedBox(width: 6),
      const Text('AI Live', style: TextStyle(fontSize: 10, color: Color(0xFF4ADE80), fontWeight: FontWeight.w700, letterSpacing: 0.2)),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════
//  BODY
// ═══════════════════════════════════════════════════════════════════
class _Body extends StatelessWidget {
  final void Function(Widget) onNav;
  const _Body({required this.onNav});

  @override
  Widget build(BuildContext context) {
    final w        = MediaQuery.of(context).size.width;
    final tablet   = w >= 720;
    final desktop  = w >= 1100;
    final pad      = desktop ? 40.0 : tablet ? 26.0 : 16.0;

    return DecoratedBox(
      decoration: const BoxDecoration(color: _C.bg),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Desktop topbar
          if (tablet) SliverToBoxAdapter(child: _TopBar()),

          // ── 1. HERO
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, tablet ? 20 : 16, pad, 0),
              child: _Hero(
                onAssess: () => onNav(const ChatScreen(initialMessage: 'Start Assessment')),
                onDepts:  () => onNav(const DepartmentsScreen()),
                onChat:   () => onNav(const ChatScreen()),
              ),
            ),
          ),

          // ── 2. PROFILE + RECOMMENDATION
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, 24, pad, 0),
              child: tablet
                  ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(flex: 5, child: _RecommendCard()),
                      const SizedBox(width: 16),
                      Expanded(flex: 4, child: _ProfileCard(onEdit: () => onNav(const StudentProfileScreen()))),
                    ])
                  : Column(children: [
                      _RecommendCard(),
                      const SizedBox(height: 16),
                      _ProfileCard(onEdit: () => onNav(const StudentProfileScreen())),
                    ]),
            ),
          ),

          // ── 3. QUICK ACCESS
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, 28, pad, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const _SecHead('Quick Access', 'Jump into what matters'),
                const SizedBox(height: 16),
                _QuickAccess(
                  cols: desktop ? 4 : tablet ? 4 : 2,
                  onNav: onNav,
                ),
              ]),
            ),
          ),

          // ── 4. DIU INFO CENTER
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, 32, pad, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const _SecHead('DIU Information Center', 'University at a glance'),
                const SizedBox(height: 16),
                _InfoCenter(),
              ]),
            ),
          ),

          // ── 5. CAREER OPPORTUNITIES
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, 32, pad, 0),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _SecHead('Career Opportunities', 'Top paths for DIU graduates'),
                SizedBox(height: 16),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 228,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.fromLTRB(pad, 0, pad, 6),
                children: const [
                  _CareerCard(
                    icon: '💻', title: 'Software Engineer',
                    salary: '\$60k – \$140k',
                    skills: ['Flutter', 'Java', 'DSA'],
                    path:   'CSE → SWE roles',
                    grad: LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)]),
                  ),
                  _CareerCard(
                    icon: '🤖', title: 'AI / ML Engineer',
                    salary: '\$80k – \$180k',
                    skills: ['Python', 'TensorFlow', 'Math'],
                    path:   'CSE → ML specialisation',
                    grad: LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF7C3AED)]),
                  ),
                  _CareerCard(
                    icon: '📊', title: 'Data Scientist',
                    salary: '\$70k – \$150k',
                    skills: ['SQL', 'Python', 'Stats'],
                    path:   'CSE / EEE → Data track',
                    grad: LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF14B8A6)]),
                  ),
                  _CareerCard(
                    icon: '🔐', title: 'Cyber Security',
                    salary: '\$65k – \$160k',
                    skills: ['Networking', 'Linux', 'CEH'],
                    path:   'CSE / EEE → Sec speciality',
                    grad: LinearGradient(colors: [Color(0xFFBE123C), Color(0xFFF43F5E)]),
                  ),
                ],
              ),
            ),
          ),

          // ── 6. ADMISSION JOURNEY
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, 32, pad, 0),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _SecHead('Admission Journey', 'Your 5-step path to DIU'),
                SizedBox(height: 18),
                _Timeline(),
              ]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 52)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TOP BAR (desktop)
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: _C.surface,
      border: const Border(bottom: BorderSide(color: _C.border)),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    child: Row(children: [
      const Text('Dashboard',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: _C.txtPri, letterSpacing: -0.5)),
      const Spacer(),
      _AiLivePill(),
      const SizedBox(width: 16),
      Container(
        width: 220, height: 37,
        decoration: BoxDecoration(color: _C.bg, borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _C.border)),
        child: const Row(children: [
          SizedBox(width: 14),
          Icon(Icons.search_rounded, size: 15, color: _C.txtMut),
          SizedBox(width: 8),
          Text('Ask anything...', style: TextStyle(fontSize: 12, color: _C.txtMut)),
        ]),
      ),
    ]),
  );
}

// ─────────────────────────────────────────────
//  SECTION HEADER
// ─────────────────────────────────────────────
class _SecHead extends StatelessWidget {
  final String t, s;
  const _SecHead(this.t, this.s);
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
    Container(width: 4, height: 22,
      decoration: BoxDecoration(gradient: _C.brandGrad, borderRadius: BorderRadius.circular(4))),
    const SizedBox(width: 10),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _C.txtPri, letterSpacing: -0.4)),
      const SizedBox(height: 2),
      Text(s, style: const TextStyle(fontSize: 11.5, color: _C.txtMut)),
    ]),
  ]);
}

// ═══════════════════════════════════════════════════════════════════
//  1. HERO
// ═══════════════════════════════════════════════════════════════════
class _Hero extends StatelessWidget {
  final VoidCallback onAssess, onDepts, onChat;
  const _Hero({required this.onAssess, required this.onDepts, required this.onChat});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.width >= 720 ? 460.0 : 340.0;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_C.radiusLg + 4),
        boxShadow: _C.glow(_C.primary, 0.16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_C.radiusLg + 4),
        child: SizedBox(
          height: h,
          child: Stack(fit: StackFit.expand, children: [
            // Campus image
            Image.asset('assets/images/diu_campus.jpg', fit: BoxFit.cover),

            // Multi-layer gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  stops: [0.0, 0.42, 1.0],
                  colors: [Color(0x0A000000), Color(0xA6000000), Color(0xE6000000)],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.55, 1.0],
                  colors: [Color(0x33000000), Color(0x00000000), Color(0x73000000)],
                ),
              ),
            ),
            // Subtle brand tint wash
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft, end: Alignment.topRight,
                  colors: [_C.primary.withOpacity(0.18), Colors.transparent],
                ),
              ),
            ),

            // Floating particles
            const _HeroParticles(),

            // Content
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Eyebrow — glass pill
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.25)),
                        ),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.auto_awesome_rounded, color: Color(0xFF93C5FD), size: 13),
                          SizedBox(width: 7),
                          Text('Powered by Claude AI',
                              style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Headline
                  Text('WELCOME TO SMARTADMIT AI',
                      style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12.5, fontWeight: FontWeight.w700, letterSpacing: 1.6)),
                  const SizedBox(height: 8),
                  ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      colors: [Colors.white, Color(0xFFDBEAFE)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ).createShader(rect),
                    child: const Text('Daffodil\nInternational\nUniversity',
                        style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900,
                            height: 1.06, letterSpacing: -1.4)),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Your Personal Admission & Career Guidance Assistant.\n'
                    'Personalised department recommendations, scholarships,\n'
                    'career roadmaps, and admission guidance — all powered by AI.',
                    style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 13, height: 1.65),
                  ),
                  const SizedBox(height: 26),

                  // CTAs
                  Wrap(spacing: 12, runSpacing: 10, children: [
                    _AnimBtn(
                      label: 'Start Assessment',
                      icon: Icons.track_changes_rounded,
                      gradient: _C.brandGrad,
                      onTap: onAssess,
                    ),
                    _AnimBtn(
                      label: 'Explore Departments',
                      icon: Icons.account_balance_rounded,
                      gradient: LinearGradient(colors: [Colors.white.withOpacity(0.10), Colors.white.withOpacity(0.05)]),
                      border: true,
                      onTap: onDepts,
                    ),
                  ]),
                ],
              ),
            ),

            // Ask AI chip (top-right)
            Positioned(top: 22, right: 22,
              child: _GlassBtn(label: '💬  Ask AI', onTap: onChat)),
          ]),
        ),
      ),
    );
  }
}

// Animated CTA button with hover scale + glow
class _AnimBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final bool border;
  final VoidCallback onTap;
  const _AnimBtn({
    required this.label, required this.icon,
    required this.gradient, this.border = false, required this.onTap,
  });
  @override State<_AnimBtn> createState() => _AnimBtnState();
}
class _AnimBtnState extends State<_AnimBtn> {
  double _scale = 1.0;
  bool   _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() { _hover = true; _scale = 1.05; }),
      onExit:  (_) => setState(() { _hover = false; _scale = 1.0; }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.96),
        onTapUp:   (_) { setState(() => _scale = 1.04); Future.delayed(const Duration(milliseconds: 120), () { if (mounted) setState(() => _scale = 1.0); }); },
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(34),
              border: widget.border ? Border.all(color: Colors.white.withOpacity(0.32)) : null,
              boxShadow: _hover ? _C.glowBtn(_C.primary) : _C.cardSoft,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(widget.icon, color: Colors.white, size: 16),
              const SizedBox(width: 9),
              Text(widget.label,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: -0.1)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _GlassBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _GlassBtn({required this.label, required this.onTap});
  @override State<_GlassBtn> createState() => _GlassBtnState();
}
class _GlassBtnState extends State<_GlassBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
            decoration: BoxDecoration(
              color: _h ? Colors.white.withOpacity(0.24) : Colors.white.withOpacity(0.13),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.32)),
            ),
            child: Text(widget.label,
                style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    ),
  );
}

// Subtle floating particles overlay
class _HeroParticles extends StatelessWidget {
  const _HeroParticles();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _ParticlePainter());
}
class _ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(0.09);
    final r = math.Random(77);
    for (var i = 0; i < 30; i++) {
      canvas.drawCircle(
        Offset(r.nextDouble() * size.width, r.nextDouble() * size.height),
        r.nextDouble() * 3 + 1, p,
      );
    }
  }
  @override bool shouldRepaint(_) => false;
}

// ═══════════════════════════════════════════════════════════════════
//  2a. RECOMMENDATION CARD
// ═══════════════════════════════════════════════════════════════════
class _RecommendCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const depts = [
      _DepRec('🖥️', 'Computer Science & Eng.',  0.94, _C.primary),
      _DepRec('⚙️', 'Software Engineering',       0.89, Color(0xFF4F46E5)),
      _DepRec('⚡', 'Electrical & Electronics',   0.76, _C.teal),
      _DepRec('💼', 'Business Administration',    0.68, _C.amber),
    ];
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _C.surface, borderRadius: BorderRadius.circular(_C.radiusMd),
        border: Border.all(color: _C.border), boxShadow: _C.card,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(width: 38, height: 38,
            decoration: BoxDecoration(
              gradient: _C.brandGrad,
              borderRadius: BorderRadius.circular(11),
              boxShadow: _C.glow(_C.primary, 0.20),
            ),
            child: const Center(child: Text('🏆', style: TextStyle(fontSize: 17)))),
          const SizedBox(width: 11),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Recommendations', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: _C.txtPri, letterSpacing: -0.2)),
            Text('Match scores based on your profile', style: TextStyle(fontSize: 10.5, color: _C.txtMut)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDBEAFE))),
            child: const Text('Updated', style: TextStyle(fontSize: 10, color: _C.primary, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 20),
        for (final d in depts) _DepRow(d: d),
      ]),
    );
  }
}

class _DepRec {
  final String emoji, label;
  final double match;
  final Color  color;
  const _DepRec(this.emoji, this.label, this.match, this.color);
}

class _DepRow extends StatelessWidget {
  final _DepRec d;
  const _DepRow({required this.d});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(color: d.color.withOpacity(0.10), borderRadius: BorderRadius.circular(9)),
          child: Center(child: Text(d.emoji, style: const TextStyle(fontSize: 15))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(d.label,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _C.txtPri))),
        Text('${(d.match * 100).toInt()}%',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: d.color)),
      ]),
      const SizedBox(height: 7),
      Stack(children: [
        Container(height: 6, decoration: BoxDecoration(
            color: _C.border, borderRadius: BorderRadius.circular(10))),
        FractionallySizedBox(
          widthFactor: d.match,
          child: Container(height: 6,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [d.color.withOpacity(0.7), d.color]),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: d.color.withOpacity(0.35), blurRadius: 6, offset: const Offset(0, 2))],
            ),
          ),
        ),
      ]),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════
//  2b. PROFILE CARD
// ═══════════════════════════════════════════════════════════════════
class _ProfileCard extends StatelessWidget {
  final VoidCallback onEdit;
  const _ProfileCard({required this.onEdit});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: _C.surface, borderRadius: BorderRadius.circular(_C.radiusMd),
      border: Border.all(color: _C.border), boxShadow: _C.card,
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Avatar row
      Row(children: [
        Container(
          width: 54, height: 54,
          decoration: BoxDecoration(
            gradient: _C.brandGrad,
            shape: BoxShape.circle,
            boxShadow: _C.glow(_C.primary, 0.28),
          ),
          child: const Center(child: Text('S',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(width: 13),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Student', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: _C.txtPri, letterSpacing: -0.2)),
          Text('DIU Applicant · Free', style: TextStyle(fontSize: 10.5, color: _C.txtMut)),
        ])),
      ]),
      const SizedBox(height: 20),

      // Stats grid
      const Row(children: [
        _MiniStat('SSC GPA', '5.00', _C.primary),
        SizedBox(width: 10),
        _MiniStat('HSC GPA', '4.80', _C.teal),
        SizedBox(width: 10),
        _MiniStat('Group', 'Science', _C.violet),
      ]),
      const SizedBox(height: 16),

      // Info rows
      const _InfoRow(Icons.interests_rounded,    'Interests',   'Technology, AI & Robotics', _C.amber),
      const SizedBox(height: 9),
      const _InfoRow(Icons.work_outline_rounded, 'Career Goal', 'Software Engineer',         _C.green),
      const SizedBox(height: 9),
      const _InfoRow(Icons.school_rounded,       'Target',      'CSE Department',            _C.primary),
      const SizedBox(height: 18),

      // Edit button
      SizedBox(
        width: double.infinity,
        child: _SmallBtn(label: 'Edit Profile', icon: Icons.edit_rounded, onTap: onEdit),
      ),
    ]),
  );
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color  color;
  const _MiniStat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [color.withOpacity(0.10), color.withOpacity(0.04)]),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 9.5, color: _C.txtMut, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
      ]),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   label, value;
  final Color    color;
  const _InfoRow(this.icon, this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 32, height: 32,
      decoration: BoxDecoration(color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(9)),
      child: Icon(icon, size: 14, color: color)),
    const SizedBox(width: 11),
    Text('$label: ', style: const TextStyle(fontSize: 11.5, color: _C.txtMut)),
    Expanded(child: Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _C.txtPri), overflow: TextOverflow.ellipsis)),
  ]);
}

class _SmallBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _SmallBtn({required this.label, required this.icon, required this.onTap});
  @override State<_SmallBtn> createState() => _SmallBtnState();
}
class _SmallBtnState extends State<_SmallBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          gradient: _h ? _C.brandGrad : null,
          color: _h ? null : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(24),
          boxShadow: _h ? _C.glow(_C.primary, 0.24) : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(widget.icon, size: 14, color: _h ? Colors.white : _C.primary),
          const SizedBox(width: 7),
          Text(widget.label,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700,
                  color: _h ? Colors.white : _C.primary)),
        ]),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════
//  3. QUICK ACCESS (gradient cards with hover lift)
// ═══════════════════════════════════════════════════════════════════
class _QuickAccess extends StatelessWidget {
  final int  cols;
  final void Function(Widget) onNav;
  const _QuickAccess({required this.cols, required this.onNav});

  @override
  Widget build(BuildContext context) {
    final cards = [
      const _QADef('🏛️', 'Departments',
          'Explore all 11 faculties & their programmes',
          LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
          DepartmentsScreen()),
      const _QADef('🎓', 'Scholarships',
          'Merit, need-based & talent scholarships',
          LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF14B8A6)]),
          RecommendationScreen()),
      const _QADef('🛣️', 'Career Roadmap',
          'Roles, salaries & learning paths',
          LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFF97316)]),
          RecommendationScreen()),
      const _QADef('🎯', 'AI Assessment',
          'Personalised GPA & interest analysis',
          LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
          ChatScreen(initialMessage: 'Start Assessment')),
    ];

    final rows = <Widget>[];
    for (var i = 0; i < cards.length; i += cols) {
      final end   = (i + cols).clamp(0, cards.length);
      final chunk = cards.sublist(i, end);
      rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var j = 0; j < cols; j++) ...[
          if (j > 0) const SizedBox(width: 14),
          j < chunk.length
              ? Expanded(child: _QACard(d: chunk[j], onTap: () => onNav(chunk[j].screen)))
              : const Expanded(child: SizedBox()),
        ],
      ]));
      if (end < cards.length) rows.add(const SizedBox(height: 14));
    }
    return Column(children: rows);
  }
}

class _QADef {
  final String   emoji, title, desc;
  final Gradient grad;
  final Widget   screen;
  const _QADef(this.emoji, this.title, this.desc, this.grad, this.screen);
}

class _QACard extends StatefulWidget {
  final _QADef d;
  final VoidCallback onTap;
  const _QACard({required this.d, required this.onTap});
  @override State<_QACard> createState() => _QACardState();
}
class _QACardState extends State<_QACard> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _h ? -7 : 0, 0),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          gradient: widget.d.grad,
          borderRadius: BorderRadius.circular(_C.radiusMd),
          border: Border.all(color: Colors.white.withOpacity(_h ? 0.28 : 0.10)),
          boxShadow: _h
              ? [BoxShadow(color: Colors.black.withOpacity(0.24), blurRadius: 28, offset: const Offset(0, 14))]
              : _C.card,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(widget.d.emoji, style: const TextStyle(fontSize: 22))),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              transform: Matrix4.translationValues(_h ? 4 : 0, 0, 0),
              child: Container(
                width: 26, height: 26,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 15),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Text(widget.d.title,
              style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
          const SizedBox(height: 5),
          Text(widget.d.desc,
              style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11.5, height: 1.4)),
        ]),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════
//  4. DIU INFO CENTER
// ═══════════════════════════════════════════════════════════════════
class _InfoCenter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const tiles = [
      _InfoTile('🏛️', '11', 'Total Departments',   _C.primary),
      _InfoTile('🎓', '30+','Scholarships',          _C.teal),
      _InfoTile('✅', 'Open','Admission Status',      _C.green),
      _InfoTile('📅', 'Jan', 'Academic Calendar',    _C.amber),
      _InfoTile('🗓️', '3',  'Upcoming Events',       _C.violet),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.surface, borderRadius: BorderRadius.circular(_C.radiusMd),
        border: Border.all(color: _C.border), boxShadow: _C.card,
      ),
      child: Row(children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) Container(width: 1, height: 58, color: _C.border),
          Expanded(child: _InfoTileWidget(t: tiles[i])),
        ],
      ]),
    );
  }
}

class _InfoTile {
  final String emoji, value, label;
  final Color  color;
  const _InfoTile(this.emoji, this.value, this.label, this.color);
}

class _InfoTileWidget extends StatelessWidget {
  final _InfoTile t;
  const _InfoTileWidget({required this.t});
  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      width: 38, height: 38,
      decoration: BoxDecoration(color: t.color.withOpacity(0.10), borderRadius: BorderRadius.circular(11)),
      child: Center(child: Text(t.emoji, style: const TextStyle(fontSize: 18))),
    ),
    const SizedBox(height: 8),
    Text(t.value, style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900, color: t.color)),
    const SizedBox(height: 3),
    Text(t.label, style: const TextStyle(fontSize: 9.5, color: _C.txtMut, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
  ]);
}

// ═══════════════════════════════════════════════════════════════════
//  5. CAREER CARD  (horizontal scroll)
// ═══════════════════════════════════════════════════════════════════
class _CareerCard extends StatefulWidget {
  final String       icon, title, salary, path;
  final List<String> skills;
  final Gradient     grad;
  const _CareerCard({
    required this.icon, required this.title, required this.salary,
    required this.skills, required this.path, required this.grad,
  });
  @override State<_CareerCard> createState() => _CareerCardState();
}
class _CareerCardState extends State<_CareerCard> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: 216,
      margin: const EdgeInsets.only(right: 14, bottom: 4),
      transform: Matrix4.translationValues(0, _h ? -6 : 0, 0),
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: widget.grad,
        borderRadius: BorderRadius.circular(_C.radiusMd),
        border: Border.all(color: Colors.white.withOpacity(_h ? 0.24 : 0.08)),
        boxShadow: _h
            ? [BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 26, offset: const Offset(0, 12))]
            : _C.card,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), borderRadius: BorderRadius.circular(13)),
          child: Center(child: Text(widget.icon, style: const TextStyle(fontSize: 24))),
        ),
        const SizedBox(height: 12),
        Text(widget.title,
            style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.2)),
        const SizedBox(height: 6),
        Text(widget.salary,
            style: TextStyle(color: Colors.white.withOpacity(0.82), fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 11),
        Wrap(spacing: 5, runSpacing: 5,
          children: widget.skills.map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w600)),
          )).toList(),
        ),
        const SizedBox(height: 11),
        Text(widget.path,
            style: TextStyle(color: Colors.white.withOpacity(0.68), fontSize: 10.5, height: 1.4)),
      ]),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════
//  6. ADMISSION TIMELINE
// ═══════════════════════════════════════════════════════════════════
class _Timeline extends StatelessWidget {
  const _Timeline();

  @override
  Widget build(BuildContext context) {
    const steps = [
      _TStep('📝', 'Application',     'Submit online form & documents',   _C.primary,  true),
      _TStep('🎯', 'Assessment',      'Complete AI-guided evaluation',     _C.teal,     true),
      _TStep('🤖', 'Recommendation',  'Receive AI department match',       _C.violet,   false),
      _TStep('✅', 'Admission',       'Official acceptance & offer letter',_C.amber,    false),
      _TStep('🎓', 'Enrollment',      'Register and start your journey',   _C.green,    false),
    ];

    final isTablet = MediaQuery.of(context).size.width >= 720;

    return isTablet ? const _TimelineHorizontal(steps: steps) : const _TimelineVertical(steps: steps);
  }
}

class _TStep {
  final String emoji, title, desc;
  final Color  color;
  final bool   done;
  const _TStep(this.emoji, this.title, this.desc, this.color, this.done);
}

class _TimelineHorizontal extends StatelessWidget {
  final List<_TStep> steps;
  const _TimelineHorizontal({required this.steps});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: _C.surface, borderRadius: BorderRadius.circular(_C.radiusMd),
      border: Border.all(color: _C.border), boxShadow: _C.card,
    ),
    child: Column(children: [
      // Connector line
      Row(children: [
        for (var i = 0; i < steps.length; i++) ...[
          // Circle
          Expanded(child: Column(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: steps[i].done ? steps[i].color : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: steps[i].done ? steps[i].color : _C.border, width: 2.4),
                boxShadow: steps[i].done ? _C.glow(steps[i].color, 0.28) : null,
              ),
              child: Center(child: Text(steps[i].emoji, style: const TextStyle(fontSize: 19))),
            ),
          ])),
          // Connector
          if (i < steps.length - 1)
            Expanded(child: Container(
              height: 3,
              margin: const EdgeInsets.only(bottom: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: LinearGradient(colors: [
                  steps[i].done ? steps[i].color : _C.border,
                  steps[i + 1].done ? steps[i + 1].color : _C.border,
                ]),
              ),
            )),
        ],
      ]),
      const SizedBox(height: 18),
      // Labels
      Row(children: [
        for (var i = 0; i < steps.length; i++) ...[
          Expanded(child: Column(children: [
            Text('0${i + 1}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                color: steps[i].done ? steps[i].color : _C.txtMut)),
            const SizedBox(height: 4),
            Text(steps[i].title,
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700,
                    color: steps[i].done ? _C.txtPri : _C.txtMut),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(steps[i].desc,
                style: const TextStyle(fontSize: 9.5, color: _C.txtMut, height: 1.3),
                textAlign: TextAlign.center),
          ])),
          if (i < steps.length - 1) const Expanded(child: SizedBox()),
        ],
      ]),
    ]),
  );
}

class _TimelineVertical extends StatelessWidget {
  final List<_TStep> steps;
  const _TimelineVertical({required this.steps});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _C.surface, borderRadius: BorderRadius.circular(_C.radiusMd),
      border: Border.all(color: _C.border), boxShadow: _C.card,
    ),
    child: Column(children: [
      for (var i = 0; i < steps.length; i++) ...[
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: steps[i].done ? steps[i].color : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: steps[i].done ? steps[i].color : _C.border, width: 2.2),
                boxShadow: steps[i].done ? _C.glow(steps[i].color, 0.24) : null,
              ),
              child: Center(child: Text(steps[i].emoji, style: const TextStyle(fontSize: 18))),
            ),
            if (i < steps.length - 1)
              Container(
                width: 2, height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [steps[i].done ? steps[i].color : _C.border, _C.border],
                  ),
                ),
              ),
          ]),
          const SizedBox(width: 15),
          Expanded(child: Padding(
            padding: const EdgeInsets.only(top: 9),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Step ${i + 1} · ${steps[i].title}',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700,
                      color: steps[i].done ? _C.txtPri : _C.txtMut)),
              const SizedBox(height: 3),
              Text(steps[i].desc,
                  style: const TextStyle(fontSize: 11, color: _C.txtMut, height: 1.4)),
            ]),
          )),
          if (steps[i].done)
            Padding(
              padding: const EdgeInsets.only(top: 9),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: steps[i].color.withOpacity(0.10), borderRadius: BorderRadius.circular(20)),
                child: Text('Done', style: TextStyle(fontSize: 9.5, color: steps[i].color, fontWeight: FontWeight.w700)),
              ),
            ),
        ]),
      ],
    ]),
  );
}