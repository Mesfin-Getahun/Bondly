import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/users_entity.dart';
import '../../domain/repositories/users_repository.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../data/repositories/users_repository_impl.dart';

/// Feature: Users - Controller (ChangeNotifier)
class UsersController extends ChangeNotifier {
  final GetUserProfileUseCase _getUserProfile;
  final WatchUserProfileUseCase _watchUserProfile;
  final UpdateUserProfileUseCase _updateUserProfile;
  final UpdateUserSettingsUseCase _updateUserSettings;

  UsersController({UsersRepository? repository})
      : _getUserProfile = GetUserProfileUseCase(repository ?? UsersRepositoryImpl()),
        _watchUserProfile = WatchUserProfileUseCase(repository ?? UsersRepositoryImpl()),
        _updateUserProfile = UpdateUserProfileUseCase(repository ?? UsersRepositoryImpl()),
        _updateUserSettings = UpdateUserSettingsUseCase(repository ?? UsersRepositoryImpl());

  UserProfileEntity? _profile;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  StreamSubscription<UserProfileEntity?>? _sub;

  UserProfileEntity? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Fetch another user's profile by ID
  Future<UserProfileEntity?> getUserById(String userId) => _getUserProfile(userId);

  void init(String userId, {String? defaultEmail, String? defaultName}) async {
    _isLoading = true;
    notifyListeners();

    _sub?.cancel();
    _sub = _watchUserProfile(userId).listen((userProfile) async {
      if (userProfile == null) {
        // First-time profile creation from session data
        final initial = UserProfileEntity(
          id: userId,
          email: defaultEmail ?? '',
          displayName: defaultName ?? (defaultEmail?.split('@').first ?? 'Bondly Friend'),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _updateUserProfile(initial);
        _profile = initial;
      } else {
        _profile = userProfile;
      }
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      _errorMessage = err.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> updateProfileDetails({
    required String displayName,
    String? bio,
    String? phoneNumber,
  }) async {
    if (_profile == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = _profile!.copyWith(
        displayName: displayName.trim(),
        bio: bio?.trim().isNotEmpty == true ? bio!.trim() : null,
        phoneNumber: phoneNumber?.trim().isNotEmpty == true ? phoneNumber!.trim() : null,
      );
      await _updateUserProfile(updated);
      _profile = updated;
      _successMessage = 'Profile updated successfully!';
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDefaultCadence(int days) async {
    if (_profile == null) return;
    try {
      await _updateUserSettings(userId: _profile!.id, defaultCadenceDays: days);
      _profile = _profile!.copyWith(defaultCadenceDays: days);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> togglePushNotifications(bool enabled) async {
    if (_profile == null) return;
    try {
      await _updateUserSettings(userId: _profile!.id, pushNotifications: enabled);
      _profile = _profile!.copyWith(pushNotifications: enabled);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleEmailNotifications(bool enabled) async {
    if (_profile == null) return;
    try {
      await _updateUserSettings(userId: _profile!.id, emailNotifications: enabled);
      _profile = _profile!.copyWith(emailNotifications: enabled);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleIsPrivate(bool isPrivate) async {
    if (_profile == null) return;
    try {
      await _updateUserSettings(userId: _profile!.id, isPrivate: isPrivate);
      _profile = _profile!.copyWith(isPrivate: isPrivate);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
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
