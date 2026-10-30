import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/usecases/get_auth_usecase.dart';

/// Feature: Auth - Presentation State Controller
class AuthController extends ChangeNotifier {
  final AuthUseCases _useCases;

  bool _isLoading = false;
  String? _errorMessage;
  AuthEntity? _currentUser;

  AuthController({AuthUseCases? useCases})
      : _useCases = useCases ?? AuthUseCases(AuthRepositoryImpl()) {
    _currentUser = _useCases.currentUser;
    _useCases.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthEntity? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && _currentUser!.isAuthenticated;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _currentUser = await _useCases.signInWithEmail(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _currentUser = await _useCases.signUpWithEmail(
        email,
        password,
        displayName: displayName,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInAnonymously() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _currentUser = await _useCases.signInAnonymously();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _useCases.signOut();
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _useCases.sendPasswordReset(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _cleanErrorMessage(String raw) {
    if (raw.startsWith('Exception: ')) {
      return raw.substring(11);
    }
    return raw;
  }
}
