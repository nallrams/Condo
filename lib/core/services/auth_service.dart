import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  // Key for storing the auth token in SharedPreferences
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  // Mock in-memory user storage
  final Map<String, User> _users = {};

  // Mock validate credentials
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Simulate network request
    await Future.delayed(const Duration(seconds: 1));
    
    // Create a mock user for demonstration purposes
    // In a real app, you would validate against a backend
    final user = User(
      id: '1',
      name: 'John Doe',
      email: email,
      unitNumber: 'A-123',
      phone: '+1234567890',
      role: 'resident',
    );
    
    // Store the user in memory
    _users[user.id] = user;
    
    // Generate a mock token
    final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    
    // Store auth token in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
  
  // Register a new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String unitNumber,
    required String phone,
  }) async {
    // Simulate network request
    await Future.delayed(const Duration(seconds: 1));
    
    // Generate a new user ID
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    
    // Create a new user
    final user = User(
      id: userId,
      name: name,
      email: email,
      unitNumber: unitNumber,
      phone: phone,
      role: 'resident',
    );
    
    // Store the user in memory
    _users[user.id] = user;
    
    // Generate a mock token
    final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    
    // Store auth token in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
  
  // Check if the user is authenticated
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }
  
  // Get the current user
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    
    return null;
  }
  
  // Get the auth token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  // Logout the user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
  
  // Update user profile
  Future<User> updateProfile(User updatedUser) async {
    // Simulate network request
    await Future.delayed(const Duration(seconds: 1));
    
    // Update user in memory
    _users[updatedUser.id] = updatedUser;
    
    // Update user in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(updatedUser.toJson()));
    
    return updatedUser;
  }
}
