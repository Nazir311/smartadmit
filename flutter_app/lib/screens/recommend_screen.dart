import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

class RecommendScreen extends StatefulWidget {
  const RecommendScreen({super.key});

  @override
  State<RecommendScreen> createState() => _RecommendScreenState();
}

class _RecommendScreenState extends State<RecommendScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _gpaCtrl = TextEditingController();
  final List<String> _allInterests = ['programming', 'business', 'electronics', 'construction', 'health', 'design', 'textile', 'communication', 'language'];
  final List<String> _selectedInterests = [];
  Map<String, dynamic>? _result;
  bool _loading = false;
  String? _error;

  Future<void> _getRecommendations() async {
    final gpa = double.tryParse(_gpaCtrl.text.trim());
    if (gpa == null || gpa < 0 || gpa > 5) {
      setState(() => _error = 'Please enter a valid GPA between 0.0 and 5.0');
      return;
    }
    setState(() { _loading = true; _error = null; _result = null; });
    final res = await _api.getRecommendations(gpa: gpa, interests: _selectedInterests);
    setState(() {
      _loading = false;
      if (res['success'] == true) {
        _result = res;
      } else {
        _error = (res['message'] as String?) ?? 'Failed to get recommendations';
      }
    });
  }

  @override
  void dispose() {
    _gpaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('GPA Recommendation', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enter Your GPA', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('Use your SSC or HSC GPA (whichever is lower)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _gpaCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(hintText: 'e.g. 4.50', prefixIcon: Icon(Icons.grade_outlined, color: AppTheme.primary)),
                  ),
                  const SizedBox(height: 16),
                  const Text('Interests (optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _allInterests.map((interest) {
                      final selected = _selectedInterests.contains(interest);
                      return GestureDetector(
                        onTap: () => setState(() => selected ? _selectedInterests.remove(interest) : _selectedInterests.add(interest)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected ? AppTheme.primary : AppTheme.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider),
                          ),
                          child: Text(interest, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.w500)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                      child: Text(_error!, style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _getRecommendations,
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Get Recommendations', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 20),
              _buildResults(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final gpa = _result!['gpa'];
    final tier = _result!['tier'] as String;
    final total = _result!['totalEligible'] as int;
    final recs = List<Map<String, dynamic>>.from(_result!['recommendations'] as List);

    final tierColor = tier == 'Excellent' ? AppTheme.accent : tier == 'Good' ? AppTheme.primary : AppTheme.warning;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tierColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: tierColor.withOpacity(0.3)),
          ),
          child: Row(children: [
            Text(tier == 'Excellent' ? '🌟' : tier == 'Good' ? '✅' : '👍', style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('GPA $gpa — $tier', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: tierColor)),
              Text('You qualify for $total department${total != 1 ? 's' : ''}', style: TextStyle(fontSize: 13, color: tierColor.withOpacity(0.8))),
            ])),
          ]),
        ),
        const SizedBox(height: 16),
        const Text('Recommended Departments', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 10),
        ...recs.map((r) => _RecommendCard(rec: r)),
      ],
    );
  }
}

class _RecommendCard extends StatelessWidget {
  final Map<String, dynamic> rec;
  const _RecommendCard({required this.rec});

  Color get _strengthColor {
    final s = rec['matchStrength'] as String;
    if (s == 'Strong Match') return AppTheme.accent;
    if (s == 'Good Match') return AppTheme.primary;
    return AppTheme.warning;
  }

  @override
  Widget build(BuildContext context) {
    final careers = List<String>.from(rec['careers'] as List? ?? []);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text('${rec['code']} — ${rec['name']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: _strengthColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(rec['matchStrength'] as String, style: TextStyle(fontSize: 10, color: _strengthColor, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            _Tag('Min GPA: ${rec['minGPA']}'),
            const SizedBox(width: 6),
            _Tag('${rec['seats']} seats'),
            const SizedBox(width: 6),
            _Tag('BDT ${rec['tuitionPerSemester']}/sem'),
          ]),
          const SizedBox(height: 8),
          Text(rec['reason'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5)),
          if (careers.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Careers: ${careers.take(3).join(', ')}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ],
          if (rec['interestMatch'] == true) ...[
            const SizedBox(height: 6),
            const Row(children: [
              Icon(Icons.favorite, size: 12, color: AppTheme.accent),
              SizedBox(width: 4),
              Text('Matches your interests', style: TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w600)),
            ]),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
    );
  }
}
