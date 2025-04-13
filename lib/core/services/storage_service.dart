import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Get data from SharedPreferences
  Future<dynamic> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (!prefs.containsKey(key)) {
      return null;
    }
    
    return jsonDecode(prefs.getString(key)!);
  }
  
  // Save data to SharedPreferences
  Future<void> saveData(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }
  
  // Remove data from SharedPreferences
  Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
  
  // Clear all data from SharedPreferences
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  
  // Check if a key exists in SharedPreferences
  Future<bool> hasKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }
}
