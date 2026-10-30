import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/insights_entity.dart';
import '../../domain/repositories/insights_repository.dart';
import '../../domain/usecases/get_insights_usecase.dart';
import '../../data/repositories/insights_repository_impl.dart';

/// Feature: Insights - Controller (ChangeNotifier)
class InsightsController extends ChangeNotifier {
  final WatchInsightsUseCase _watchInsights;
  final ComputeHealthSummaryUseCase _computeHealthSummary;
  final GenerateSmartInsightsUseCase _generateSmartInsights;
  final DismissInsightUseCase _dismissInsight;

  InsightsController({InsightsRepository? repository})
      : _watchInsights = WatchInsightsUseCase(repository ?? InsightsRepositoryImpl()),
        _computeHealthSummary = ComputeHealthSummaryUseCase(repository ?? InsightsRepositoryImpl()),
        _generateSmartInsights = GenerateSmartInsightsUseCase(repository ?? InsightsRepositoryImpl()),
        _dismissInsight = DismissInsightUseCase(repository ?? InsightsRepositoryImpl());

  StreamSubscription<List<InsightEntity>>? _sub;
  String? _currentUserId;

  List<InsightEntity> _insights = [];
  RelationshipHealthSummary? _healthSummary;
  bool _isLoading = false;
  String? _errorMessage;

  List<InsightEntity> get insights => _insights;
  RelationshipHealthSummary? get healthSummary => _healthSummary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void init(String currentUserId) async {
    if (_currentUserId == currentUserId && _sub != null) return;
    _currentUserId = currentUserId;

    _isLoading = true;
    notifyListeners();

    // 1. Compute summary and generate insights
    try {
      _healthSummary = await _computeHealthSummary(currentUserId);
      await _generateSmartInsights(currentUserId);
    } catch (e) {
      _errorMessage = e.toString();
    }

    // 2. Stream insights
    _sub?.cancel();
    _sub = _watchInsights(currentUserId).listen((list) {
      _insights = list;
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      _errorMessage = err.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> refresh() async {
    if (_currentUserId == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      _healthSummary = await _computeHealthSummary(_currentUserId!);
      await _generateSmartInsights(_currentUserId!);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> dismiss(String insightId) async {
    if (_currentUserId == null) return;
    try {
      await _dismissInsight(_currentUserId!, insightId);
      _insights.removeWhere((i) => i.id == insightId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
