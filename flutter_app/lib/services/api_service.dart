import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static final ApiService _i = ApiService._();
  factory ApiService() => _i;
  ApiService._();

  static const Map<String, String> _h = {'Content-Type': 'application/json', 'Accept': 'application/json'};

  Future<Map<String, dynamic>> sendChatMessage({required String message, required String sessionId, String mode = 'free'}) async {
    try {
      final res = await http.post(Uri.parse('${AppConstants.baseUrl}${AppConstants.chatEndpoint}'),
          headers: _h, body: jsonEncode({'message': message, 'sessionId': sessionId, 'mode': mode}))
          .timeout(AppConstants.timeout);
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'response': data['response'], 'intent': data['intent']};
      }
      return {'success': false, 'response': (data['message'] as String?) ?? 'Server error.'};
    } catch (e) {
      return {'success': false, 'response': '⚠️ Cannot connect to server. Make sure the backend is running.\n\nError: $e'};
    }
  }

  Future<List<Map<String, dynamic>>> getDepartments({double? minGPA}) async {
    try {
      String url = '${AppConstants.baseUrl}${AppConstants.departmentsEndpoint}';
      if (minGPA != null) url += '?minGPA=$minGPA';
      final res = await http.get(Uri.parse(url), headers: _h).timeout(AppConstants.timeout);
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['success'] == true) return List<Map<String, dynamic>>.from(data['data'] as List);
      return [];
    } catch (_) { return []; }
  }

  Future<Map<String, dynamic>> getRecommendations({required double gpa, List<String> interests = const []}) async {
    try {
      final res = await http.post(Uri.parse('${AppConstants.baseUrl}${AppConstants.recommendEndpoint}'),
          headers: _h, body: jsonEncode({'gpa': gpa, 'interests': interests}))
          .timeout(AppConstants.timeout);
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) { return {'success': false, 'message': 'Recommendation unavailable: $e'}; }
  }

  Future<List<Map<String, dynamic>>> getFAQs({String? category}) async {
    try {
      String url = '${AppConstants.baseUrl}${AppConstants.faqEndpoint}';
      if (category != null) url += '?category=$category';
      final res = await http.get(Uri.parse(url), headers: _h).timeout(AppConstants.timeout);
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['success'] == true) return List<Map<String, dynamic>>.from(data['data'] as List);
      return [];
    } catch (_) { return []; }
  }

  Future<Map<String, dynamic>?> getProfile(String sessionId) async {
    try {
      final res = await http.get(Uri.parse('${AppConstants.baseUrl}${AppConstants.profileEndpoint}/$sessionId'), headers: _h).timeout(AppConstants.timeout);
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['success'] == true) return data['data'] as Map<String, dynamic>;
      return null;
    } catch (_) { return null; }
  }

  Future<Map<String, dynamic>?> getRecommendationForSession(String sessionId) async {
    try {
      final res = await http.get(Uri.parse('${AppConstants.baseUrl}${AppConstants.profileEndpoint}/$sessionId/recommendation'), headers: _h).timeout(AppConstants.timeout);
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['success'] == true) return data['data'] as Map<String, dynamic>;
      return null;
    } catch (_) { return null; }
  }

  Future<Map<String, dynamic>> generateReport(String sessionId) async {
    try {
      final res = await http.post(Uri.parse('${AppConstants.baseUrl}${AppConstants.reportEndpoint}'),
          headers: _h, body: jsonEncode({'sessionId': sessionId}))
          .timeout(const Duration(seconds: 40));
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) { return {'success': false, 'message': 'Report generation failed: $e'}; }
  }

  Future<bool> healthCheck() async {
    try {
      final res = await http.get(Uri.parse(AppConstants.baseUrl.replaceAll('/api', ''))).timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) { return false; }
  }
}
