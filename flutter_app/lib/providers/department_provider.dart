import 'package:flutter/foundation.dart';
import '../models/department_model.dart';
import '../services/api_service.dart';

class DepartmentProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<DepartmentModel> _departments = [];
  List<DepartmentModel> _filteredDepartments = [];
  bool _loading = false;
  String _searchQuery = '';
  String? _error;

  List<DepartmentModel> get departments => _filteredDepartments;
  bool get loading => _loading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  Future<void> loadDepartments() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final raw = await _api.getDepartments();
    if (raw.isNotEmpty) {
      _departments = raw.map((d) => DepartmentModel.fromJson(d)).toList();
      _applyFilter();
    } else {
      _error = 'Failed to load departments. Make sure the server is running.';
    }

    _loading = false;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredDepartments = List.from(_departments);
      return;
    }
    final q = _searchQuery.toLowerCase();
    _filteredDepartments = _departments.where((d) =>
      d.name.toLowerCase().contains(q) ||
      d.code.toLowerCase().contains(q) ||
      d.faculty.toLowerCase().contains(q) ||
      d.careers.any((c) => c.toLowerCase().contains(q))
    ).toList();
  }
}
