import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/recommendation_model.dart';
import '../utils/app_theme.dart';

class ParentModeScreen extends StatefulWidget {
  final RecommendationModel recommendation;
  const ParentModeScreen({super.key, required this.recommendation});

  @override
  State<ParentModeScreen> createState() => _ParentModeScreenState();
}

class _ParentModeScreenState extends State<ParentModeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
        backgroundColor: AppTheme.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rec = widget.recommendation;
    final top = rec.topDepartments.isNotEmpty ? rec.topDepartments.first : null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Parent Mode', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: '🇬🇧  English'),
            Tab(text: '🇧🇩  বাংলা'),
          ],
        ),
      ),
      body: Column(children: [
        if (top != null) _TopBanner(dept: top),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _SummaryPane(
                content: rec.parentSummaryEn.isNotEmpty
                    ? rec.parentSummaryEn
                    : '⚠️ Parent summary not available. Please complete the assessment first.',
                isBangla: false,
                onCopy: () => _copy(rec.parentSummaryEn),
              ),
              _SummaryPane(
                content: rec.parentSummaryBn.isNotEmpty
                    ? rec.parentSummaryBn
                    : '⚠️ বাংলা সারসংক্ষেপ পাওয়া যায়নি। প্রথমে মূল্যায়ন সম্পন্ন করুন।',
                isBangla: true,
                onCopy: () => _copy(rec.parentSummaryBn),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _TopBanner extends StatelessWidget {
  final DepartmentScoreModel dept;
  const _TopBanner({required this.dept});

  String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF166534), Color(0xFF15803D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        const Text('👨‍👩‍👧', style: TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Parent Summary',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            Text('Top Match: ${dept.name} (${dept.confidenceScore}%)',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8)),
          child: Text(
            'BDT ${_fmt(dept.tuitionPerSemester)}/sem',
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
      ]),
    );
  }
}

class _SummaryPane extends StatelessWidget {
  final String content;
  final bool isBangla;
  final VoidCallback onCopy;

  const _SummaryPane({
    required this.content,
    required this.isBangla,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.divider),
            ),
            child: isBangla
                ? SelectableText(
                    content,
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        height: 1.8),
                  )
                : MarkdownBody(
                    data: content,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                          height: 1.6),
                      strong: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary),
                      h2: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary),
                      h3: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary),
                      listBullet: const TextStyle(
                          fontSize: 14, color: AppTheme.primary),
                    ),
                  ),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(
            16, 8, 16, MediaQuery.of(context).padding.bottom + 12),
        child: Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copy'),
              onPressed: onCopy,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.share_rounded, size: 16),
              label: const Text('Share'),
              onPressed: onCopy,
            ),
          ),
        ]),
      ),
    ]);
  }
}
