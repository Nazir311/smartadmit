import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../services/api_service.dart';

class ReportProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _generating = false;
  bool _generated = false;
  String? _error;
  String? _localFilePath;

  bool get generating => _generating;
  bool get generated => _generated;
  String? get error => _error;
  String? get localFilePath => _localFilePath;

  Future<void> generateReport(String sessionId) async {
    _generating = true;
    _error = null;
    _generated = false;
    notifyListeners();

    final result = await _api.generateReport(sessionId);

    if (result['success'] == true) {
      final base64Data = result['pdfBase64'] as String? ?? '';
      if (base64Data.isNotEmpty) {
        await _saveToDevice(base64Data, sessionId);
      }
      _generated = true;
    } else {
      _error = (result['message'] as String?) ?? 'Failed to generate report.';
    }

    _generating = false;
    notifyListeners();
  }

  Future<void> _saveToDevice(String base64Data, String sessionId) async {
    try {
      final bytes = base64Decode(base64Data);
      final dir = await getApplicationDocumentsDirectory();
      final safeId = sessionId.length >= 8 ? sessionId.substring(0, 8) : sessionId;
      final fileName = 'smartadmit_report_$safeId.html';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      _localFilePath = file.path;
    } catch (_) {
      _localFilePath = null;
    }
  }

  void clear() {
    _generating = false;
    _generated = false;
    _error = null;
    _localFilePath = null;
    notifyListeners();
  }
}
