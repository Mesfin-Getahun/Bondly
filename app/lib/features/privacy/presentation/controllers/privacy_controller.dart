import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/privacy_entity.dart';
import '../../domain/repositories/privacy_repository.dart';
import '../../domain/usecases/get_privacy_usecase.dart';
import '../../data/repositories/privacy_repository_impl.dart';

/// Feature: Privacy - Controller (ChangeNotifier)
class PrivacyController extends ChangeNotifier {
  final WatchPrivacySettingsUseCase _watchSettings;
  final UpdatePrivacySettingsUseCase _updateSettings;
  final ExportUserDataUseCase _exportData;
  final DeleteUserAccountUseCase _deleteAccount;

  PrivacyController({PrivacyRepository? repository})
      : _watchSettings = WatchPrivacySettingsUseCase(repository ?? PrivacyRepositoryImpl()),
        _updateSettings = UpdatePrivacySettingsUseCase(repository ?? PrivacyRepositoryImpl()),
        _exportData = ExportUserDataUseCase(repository ?? PrivacyRepositoryImpl()),
        _deleteAccount = DeleteUserAccountUseCase(repository ?? PrivacyRepositoryImpl());

  StreamSubscription<PrivacySettingsEntity>? _sub;
  String? _currentUserId;

  PrivacySettingsEntity? _settings;
  bool _isLoading = false;
  bool _isExporting = false;
  String? _exportedJson;
  String? _errorMessage;
  String? _successMessage;

  PrivacySettingsEntity? get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isExporting => _isExporting;
  String? get exportedJson => _exportedJson;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void init(String currentUserId) {
    if (_currentUserId == currentUserId && _sub != null) return;
    _currentUserId = currentUserId;

    _isLoading = true;
    notifyListeners();

    _sub?.cancel();
    _sub = _watchSettings(currentUserId).listen((s) {
      _settings = s;
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      _errorMessage = err.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updateToggle({
    bool? searchVisibility,
    bool? analyticsConsent,
    bool? personalizedRecommendations,
    bool? readReceipts,
    bool? lastActiveVisibility,
  }) async {
    if (_settings == null || _currentUserId == null) return;

    final updated = _settings!.copyWith(
      searchVisibility: searchVisibility,
      analyticsConsent: analyticsConsent,
      personalizedRecommendations: personalizedRecommendations,
      readReceipts: readReceipts,
      lastActiveVisibility: lastActiveVisibility,
      updatedAt: DateTime.now(),
    );

    try {
      await _updateSettings(updated);
      _settings = updated;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<String?> generateDataExport() async {
    if (_currentUserId == null) return null;

    _isExporting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final json = await _exportData(_currentUserId!);
      _exportedJson = json;
      _successMessage = 'Your data archive is ready for review or export!';
      return json;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount() async {
    if (_currentUserId == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _deleteAccount(_currentUserId!);
      _successMessage = 'Account and data permanently deleted.';
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
