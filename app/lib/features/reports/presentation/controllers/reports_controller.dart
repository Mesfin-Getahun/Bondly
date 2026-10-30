import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/reports_entity.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/usecases/get_reports_usecase.dart';
import '../../data/repositories/reports_repository_impl.dart';

/// Feature: Reports - Controller (ChangeNotifier)
class ReportsController extends ChangeNotifier {
  final WatchReportsUseCase _watchReports;
  final SubmitReportUseCase _submitReport;

  ReportsController({ReportsRepository? repository})
      : _watchReports = WatchReportsUseCase(repository ?? ReportsRepositoryImpl()),
        _submitReport = SubmitReportUseCase(repository ?? ReportsRepositoryImpl());

  StreamSubscription<List<ReportEntity>>? _sub;
  String? _currentUserId;

  List<ReportEntity> _reports = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  List<ReportEntity> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void init(String currentUserId) {
    if (_currentUserId == currentUserId && _sub != null) return;
    _currentUserId = currentUserId;

    _isLoading = true;
    notifyListeners();

    _sub?.cancel();
    _sub = _watchReports(currentUserId).listen((list) {
      _reports = list;
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      _errorMessage = err.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> createReport({
    required String reporterId,
    required String reporterName,
    String? targetUserId,
    String? targetUserName,
    String targetType = 'user',
    required String reason,
    required String description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _submitReport(
        reporterId: reporterId,
        reporterName: reporterName,
        targetUserId: targetUserId,
        targetUserName: targetUserName,
        targetType: targetType,
        reason: reason,
        description: description,
      );
      _successMessage = 'Your report has been submitted. Our team will review it promptly.';
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
