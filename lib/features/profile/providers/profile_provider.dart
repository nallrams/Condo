import 'package:flutter/foundation.dart';
import '../../../core/models/user.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadUserProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // In a real app, we would fetch from an API
      // final response = await _apiService.get('users/$userId');
      // _user = User.fromJson(response['data']);
      
      // For now, we'll use mock data
      _user = User(
        id: userId,
        email: 'user@example.com',
        name: 'John Doe',
        unitNumber: 'A-123',
        phone: '+1234567890',
        role: 'resident',
        joinDate: DateTime.now().subtract(const Duration(days: 180)),
      );
      
    } catch (e) {
      _error = 'Failed to load profile: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // In a real app, we would send to an API
      // final response = await _apiService.put('users/$userId', {
      //   if (name != null) 'name': name,
      //   if (phone != null) 'phone': phone,
      //   if (email != null) 'email': email,
      //   if (photoUrl != null) 'photoUrl': photoUrl,
      // });
      // _user = User.fromJson(response['data']);
      
      // For now, we'll update our mock data
      if (_user != null) {
        _user = _user!.copyWith(
          name: name ?? _user!.name,
          phone: phone ?? _user!.phone,
          email: email ?? _user!.email,
          profileImageUrl: photoUrl ?? _user!.profileImageUrl,
        );
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}