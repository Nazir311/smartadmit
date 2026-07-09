import 'package:flutter/foundation.dart';
import '../models/student_profile_model.dart';
import '../services/api_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  StudentProfileModel? _profile;
  bool _loading = false;
  String? _error;

  StudentProfileModel? get profile => _profile;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasProfile => _profile != null;
  bool get isComplete => _profile?.profileComplete ?? false;

  Future<void> loadProfile(String sessionId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final raw = await _api.getProfile(sessionId);
    if (raw != null) {
      _profile = StudentProfileModel.fromJson(raw);
      _error = null;
    }

    _loading = false;
    notifyListeners();
  }

  void setFromJson(Map<String, dynamic> json) {
    _profile = StudentProfileModel.fromJson(json);
    _error = null;
    notifyListeners();
  }

  void clear() {
    _profile = null;
    _error = null;
    notifyListeners();
  }
}
