import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/models/visitor.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/helpers.dart';

class VisitorProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Visitor> _visitors = [];
  Visitor? _selectedVisitor;
  bool _isLoading = false;
  String? _error;
  
  List<Visitor> get visitors => _visitors;
  Visitor? get selectedVisitor => _selectedVisitor;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Visitor> get pendingVisitors => _visitors.where((visitor) => 
      visitor.status == 'pending').toList();
  List<Visitor> get historyVisitors => _visitors.where((visitor) => 
      visitor.status != 'pending').toList();
  
  // Initialize with mock data for in-memory implementation
  VisitorProvider() {
    _initializeSampleData();
  }
  
  void _initializeSampleData() {
    // Create sample visitors data
    final now = DateTime.now();
    
    _visitors = [
      Visitor(
        id: 'v1',
        userId: '1',
        name: 'Alice Johnson',
        purpose: 'Family Visit',
        expectedArrivalTime: now.add(const Duration(days: 2, hours: 3)),
        status: 'pending',
        phone: '+1234567890',
        qrCode: 'visitor-qr-code-v1',
      ),
      Visitor(
        id: 'v2',
        userId: '1',
        name: 'Bob Smith',
        purpose: 'Maintenance',
        expectedArrivalTime: now.add(const Duration(hours: 5)),
        status: 'pending',
        vehiclePlate: 'ABC123',
        phone: '+1987654321',
        qrCode: 'visitor-qr-code-v2',
      ),
      Visitor(
        id: 'v3',
        userId: '1',
        name: 'Carol Davis',
        purpose: 'Delivery',
        expectedArrivalTime: now.subtract(const Duration(days: 1)),
        actualArrivalTime: now.subtract(const Duration(days: 1, hours: 1)),
        departureTime: now.subtract(const Duration(days: 1)),
        status: 'departed',
        notes: 'Package delivery',
        qrCode: 'visitor-qr-code-v3',
      ),
    ];
  }
  
  Future<void> loadUserVisitors(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
      
      // In a real app, we would fetch from an API
      // final response = await _apiService.get('visitors/user/$userId');
      // _visitors = (response['data'] as List).map((item) => Visitor.fromJson(item)).toList();
      
      // Filter existing visitors for this user
      _visitors = _visitors.where((visitor) => visitor.userId == userId).toList();
      
    } catch (e) {
      _error = 'Failed to load visitors: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> getVisitorById(String visitorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      // Find the visitor in our local data
      _selectedVisitor = _visitors.firstWhere(
        (visitor) => visitor.id == visitorId,
        orElse: () => throw Exception('Visitor not found'),
      );
      
    } catch (e) {
      _error = 'Failed to get visitor details: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Visitor?> createVisitor({
    required String userId,
    required String name,
    required String purpose,
    required DateTime expectedArrivalTime,
    String? vehiclePlate,
    String? idNumber,
    String? phone,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Generate QR code
      final qrCode = 'visitor-qr-${Helpers.generateUuid()}';
      
      // Create a new visitor
      final visitor = Visitor(
        id: Helpers.generateUuid(),
        userId: userId,
        name: name,
        purpose: purpose,
        expectedArrivalTime: expectedArrivalTime,
        status: 'pending',
        vehiclePlate: vehiclePlate,
        idNumber: idNumber,
        phone: phone,
        notes: notes,
        qrCode: qrCode,
      );
      
      // In a real app, we would send to an API
      // final response = await _apiService.post('visitors', visitor.toJson());
      // final createdVisitor = Visitor.fromJson(response['data']);
      
      // Add to our local data
      _visitors.add(visitor);
      _selectedVisitor = visitor;
      
      return visitor;
    } catch (e) {
      _error = 'Failed to create visitor: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateVisitorStatus(String visitorId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Find the visitor
      final index = _visitors.indexWhere((visitor) => visitor.id == visitorId);
      if (index == -1) {
        throw Exception('Visitor not found');
      }
      
      // Update visitor data based on status
      late Visitor updatedVisitor;
      
      if (status == 'arrived') {
        updatedVisitor = _visitors[index].copyWith(
          status: status,
          actualArrivalTime: DateTime.now(),
        );
      } else if (status == 'departed') {
        updatedVisitor = _visitors[index].copyWith(
          status: status,
          departureTime: DateTime.now(),
        );
      } else if (status == 'cancelled') {
        updatedVisitor = _visitors[index].copyWith(
          status: status,
        );
      } else {
        updatedVisitor = _visitors[index].copyWith(
          status: status,
        );
      }
      
      // In a real app, we would send to an API
      // await _apiService.put('visitors/$visitorId/status', {'status': status});
      
      // Update our local data
      _visitors[index] = updatedVisitor;
      if (_selectedVisitor?.id == visitorId) {
        _selectedVisitor = updatedVisitor;
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to update visitor status: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearSelectedVisitor() {
    _selectedVisitor = null;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Generate visitor QR code data
  String generateVisitorQRData(Visitor visitor) {
    final data = {
      'id': visitor.id,
      'name': visitor.name,
      'purpose': visitor.purpose,
      'expectedArrival': DateFormat('yyyy-MM-dd HH:mm').format(visitor.expectedArrivalTime),
      'vehiclePlate': visitor.vehiclePlate,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    return data.toString();
  }
}
