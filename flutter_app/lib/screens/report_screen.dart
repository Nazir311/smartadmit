import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';
import '../providers/chat_provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/report_provider.dart';
import '../utils/app_theme.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Download Report',
            style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer3<ReportProvider, ChatProvider, RecommendationProvider>(
        builder: (_, reportP, chatP, recP, __) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _HeroCard(hasRecommendation: recP.hasRecommendation),
              const SizedBox(height: 20),
              if (reportP.generated && reportP.localFilePath != null)
                _SuccessCard(
                  filePath: reportP.localFilePath!,
                  onOpen: () => _openFile(context, reportP.localFilePath!),
                ),
              if (reportP.error != null) _ErrorCard(message: reportP.error!),
              _GenerateButton(
                loading: reportP.generating,
                enabled: recP.hasRecommendation && !reportP.generating,
                alreadyGenerated: reportP.generated,
                onTap: () => _generate(context, reportP, chatP),
              ),
              if (!recP.hasRecommendation) ...[
                const SizedBox(height: 10),
                _WarningBox(),
              ],
              const SizedBox(height: 24),
              _IncludesCard(),
            ],
          );
        },
      ),
    );
  }

  Future<void> _generate(
      BuildContext context, ReportProvider provider, ChatProvider chat) async {
    if (chat.sessionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'No session found. Complete the assessment first.')),
      );
      return;
    }
    await provider.generateReport(chat.sessionId);
  }

  void _openFile(BuildContext context, String path) async {
    final file = File(path);
    if (await file.exists()) {
      await OpenFile.open(path);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File not found on device.')),
        );
      }
    }
  }
}

class _HeroCard extends StatelessWidget {
  final bool hasRecommendation;
  const _HeroCard({required this.hasRecommendation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppTheme.primary, Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Text('📄', style: TextStyle(fontSize: 30)),
          SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SmartAdmit Report',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800)),
            Text('AI-Generated Admission Report',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Icon(
                hasRecommendation
                    ? Icons.check_circle_outline
                    : Icons.info_outline,
                color: Colors.white,
                size: 16),
            const SizedBox(width: 8),
            Text(
              hasRecommendation
                  ? 'Assessment complete — ready to generate'
                  : 'Complete the assessment first',
              style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _GenerateButton extends StatelessWidget {
  final bool loading;
  final bool enabled;
  final bool alreadyGenerated;
  final VoidCallback onTap;

  const _GenerateButton({
    required this.loading,
    required this.enabled,
    required this.alreadyGenerated,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child:
                    CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Icon(
                alreadyGenerated
                    ? Icons.refresh_rounded
                    : Icons.download_rounded,
                size: 20),
        label: Text(
          loading
              ? 'Generating…'
              : alreadyGenerated
                  ? 'Regenerate Report'
                  : 'Generate & Download Report',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        onPressed: enabled ? onTap : null,
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  final String filePath;
  final VoidCallback onOpen;

  const _SuccessCard({required this.filePath, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.check_circle_rounded, color: AppTheme.accent, size: 22),
          SizedBox(width: 10),
          Text('Report Generated!',
              style: TextStyle(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
        ]),
        const SizedBox(height: 6),
        Text(
          'Saved: ${filePath.split('/').last}',
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('Open Report'),
            onPressed: onOpen,
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
          ),
        ),
      ]),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.error_outline, color: AppTheme.error, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message,
              style: const TextStyle(fontSize: 13, color: AppTheme.error)),
        ),
      ]),
    );
  }
}

class _WarningBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
      ),
      child: const Row(children: [
        Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 16),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Go to Chat and type "Start Assessment" to complete your profile first.',
            style: TextStyle(fontSize: 12, color: AppTheme.warning),
          ),
        ),
      ]),
    );
  }
}

class _IncludesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      '📋  Complete student profile summary',
      '🎯  Top 3 department recommendations',
      '📊  Confidence scores with reasoning',
      '🗺️  4-year career roadmap',
      '👨‍👩‍👧  Parent summary in English',
      '💰  Tuition & scholarship information',
      '💼  Job roles and industry sectors',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('📄 Report Includes',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(item,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.4)),
            )),
      ]),
    );
  }
}
