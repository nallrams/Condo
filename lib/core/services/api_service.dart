import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // For in-memory storage, we'll mock API responses
  // In a real app, this would connect to a backend server

  // Mock API response delay for simulating network requests
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? headers}) async {
    await _simulateNetworkDelay();
    
    // In a real app, you would have code like this:
    // final response = await http.get(
    //   Uri.parse('$baseUrl/$endpoint'),
    //   headers: headers,
    // );
    // if (response.statusCode == 200) {
    //   return jsonDecode(response.body);
    // } else {
    //   throw Exception('Failed to load data: ${response.statusCode}');
    // }
    
    // For now, we'll return mock success
    return {'success': true, 'message': 'Data retrieved successfully'};
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(
    String endpoint, 
    dynamic data, 
    {Map<String, String>? headers}
  ) async {
    await _simulateNetworkDelay();
    
    // In a real app, you would have code like this:
    // final response = await http.post(
    //   Uri.parse('$baseUrl/$endpoint'),
    //   headers: headers ?? {'Content-Type': 'application/json'},
    //   body: jsonEncode(data),
    // );
    // if (response.statusCode == 200 || response.statusCode == 201) {
    //   return jsonDecode(response.body);
    // } else {
    //   throw Exception('Failed to post data: ${response.statusCode}');
    // }
    
    // For now, we'll return mock success
    return {
      'success': true, 
      'message': 'Data submitted successfully',
      'data': data
    };
  }

  // Generic PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, 
    dynamic data, 
    {Map<String, String>? headers}
  ) async {
    await _simulateNetworkDelay();
    
    // In a real app, you would have code like this:
    // final response = await http.put(
    //   Uri.parse('$baseUrl/$endpoint'),
    //   headers: headers ?? {'Content-Type': 'application/json'},
    //   body: jsonEncode(data),
    // );
    // if (response.statusCode == 200) {
    //   return jsonDecode(response.body);
    // } else {
    //   throw Exception('Failed to update data: ${response.statusCode}');
    // }
    
    // For now, we'll return mock success
    return {
      'success': true, 
      'message': 'Data updated successfully',
      'data': data
    };
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, 
    {Map<String, String>? headers}
  ) async {
    await _simulateNetworkDelay();
    
    // In a real app, you would have code like this:
    // final response = await http.delete(
    //   Uri.parse('$baseUrl/$endpoint'),
    //   headers: headers,
    // );
    // if (response.statusCode == 200 || response.statusCode == 204) {
    //   return {'success': true};
    // } else {
    //   throw Exception('Failed to delete data: ${response.statusCode}');
    // }
    
    // For now, we'll return mock success
    return {'success': true, 'message': 'Data deleted successfully'};
  }
}
