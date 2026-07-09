import 'package:flutter/foundation.dart';
import '../models/recommendation_model.dart';
import '../services/api_service.dart';

class RecommendationProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  RecommendationModel? _recommendation;
  bool _loading = false;
  String? _error;

  RecommendationModel? get recommendation => _recommendation;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasRecommendation => _recommendation != null;
  List<DepartmentScoreModel> get topDepartments =>
      _recommendation?.topDepartments ?? [];

  Future<void> loadRecommendation(String sessionId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final raw = await _api.getRecommendationForSession(sessionId);
    if (raw != null) {
      _recommendation = RecommendationModel.fromJson(raw);
      _error = null;
    } else {
      _error = 'No recommendation found. Complete the assessment first.';
    }

    _loading = false;
    notifyListeners();
  }

  void setFromJson(Map<String, dynamic> json) {
    _recommendation = RecommendationModel.fromJson(json);
    _error = null;
    notifyListeners();
  }

  void clear() {
    _recommendation = null;
    _error = null;
    notifyListeners();
  }
}
