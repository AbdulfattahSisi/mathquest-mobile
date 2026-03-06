import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'api_service.dart';

/// Manages the current authenticated user state throughout the app.
class AuthService extends ChangeNotifier {
  final ApiService _api;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isGuest = false;

  AuthService(this._api);

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isGuest => _isGuest;
  bool get isLoggedIn => _currentUser != null;

  /// Try to restore session from stored token on app start.
  Future<bool> tryRestoreSession() async {
    final token = await _api.getToken();
    if (token == null) return false;
    try {
      _currentUser = await _api.getMe();
      notifyListeners();
      return true;
    } catch (_) {
      await _api.clearToken();
      return false;
    }
  }

  Future<void> login(String username, String password) async {
    _setLoading(true);
    try {
      final token = await _api.login(username, password);
      await _api.saveToken(token);
      _currentUser = await _api.getMe();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String username, String email, String password) async {
    _setLoading(true);
    try {
      final token = await _api.register(username, email, password);
      await _api.saveToken(token);
      _currentUser = await _api.getMe();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Log in without an account — local only, no API token.
  void loginAsGuest() {
    _isGuest = true;
    _currentUser = UserModel.guest();
    notifyListeners();
  }

  Future<void> logout() async {
    await _api.clearToken();
    _currentUser = null;
    _isGuest = false;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
