import 'package:flutter/material.dart';
import '../models/faq_model.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final ApiService _api = ApiService();
  List<FAQModel> _faqs = [];
  bool _loading = true;
  String? _error;

  static const Map<String, String> _catEmoji = {
    'deadline': '📅',
    'documents': '📄',
    'test': '📝',
    'fees': '💰',
    'scholarship': '🎓',
    'process': '📋',
    'eligibility': '✅',
    'general': '❓',
  };

  @override
  void initState() {
    super.initState();
    _loadFAQs();
  }

  Future<void> _loadFAQs() async {
    setState(() { _loading = true; _error = null; });
    final raw = await _api.getFAQs();
    if (mounted) {
      setState(() {
        if (raw.isNotEmpty) {
          _faqs = raw.map((f) => FAQModel.fromJson(f)).toList();
        } else {
          _error = 'Failed to load FAQs. Make sure the server is running.';
        }
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Frequently Asked Questions', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.wifi_off_rounded, size: 48, color: AppTheme.textHint),
                  const SizedBox(height: 12),
                  Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadFAQs, child: const Text('Retry')),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _faqs.length,
                  itemBuilder: (ctx, i) {
                    final faq = _faqs[i];
                    final emoji = _catEmoji[faq.category] ?? '❓';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Theme(
                        data: Theme.of(ctx).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                          leading: Text(emoji, style: const TextStyle(fontSize: 22)),
                          title: Text(faq.question, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 10),
                            Text(faq.answer, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.6)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
