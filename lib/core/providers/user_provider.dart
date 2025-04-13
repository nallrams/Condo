import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  UserProvider() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _user = await _authService.getCurrentUser();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateProfile({
    required String name,
    required String email,
    required String unitNumber,
    required String phone,
    String? profileImageUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      if (_user == null) {
        throw Exception('User not logged in');
      }
      
      final updatedUser = _user!.copyWith(
        name: name,
        email: email,
        unitNumber: unitNumber,
        phone: phone,
        profileImageUrl: profileImageUrl,
      );
      
      final user = await _authService.updateProfile(updatedUser);
      _user = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  Future<void> refreshUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _user = await _authService.getCurrentUser();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
