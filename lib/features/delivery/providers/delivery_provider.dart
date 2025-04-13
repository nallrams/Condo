import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/delivery.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/helpers.dart';

class DeliveryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Delivery> _deliveries = [];
  Delivery? _selectedDelivery;
  bool _isLoading = false;
  String? _error;
  
  List<Delivery> get deliveries => _deliveries;
  Delivery? get selectedDelivery => _selectedDelivery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Delivery> get pendingDeliveries => _deliveries.where((delivery) => 
      delivery.status == 'pending').toList();
  List<Delivery> get deliveredDeliveries => _deliveries.where((delivery) => 
      delivery.status == 'delivered' && delivery.collectionDate == null).toList();
  List<Delivery> get completedDeliveries => _deliveries.where((delivery) => 
      delivery.status == 'collected' || delivery.status == 'returned').toList();
  
  // Initialize with mock data for in-memory implementation
  DeliveryProvider() {
    _initializeSampleData();
  }
  
  void _initializeSampleData() {
    // Create sample deliveries data
    final now = DateTime.now();
    
    _deliveries = [
      Delivery(
        id: 'd1',
        userId: '1',
        trackingNumber: 'TRK12345678',
        courierName: 'FedEx',
        status: 'pending',
        expectedDeliveryDate: now.add(const Duration(days: 2)),
        packageSize: 'medium',
        packageDescription: 'Electronics',
        senderInfo: 'Amazon',
      ),
      Delivery(
        id: 'd2',
        userId: '1',
        trackingNumber: 'TRK87654321',
        courierName: 'UPS',
        status: 'delivered',
        expectedDeliveryDate: now.subtract(const Duration(days: 1)),
        actualDeliveryDate: now.subtract(const Duration(days: 1, hours: 2)),
        packageSize: 'small',
        packageDescription: 'Books',
        senderInfo: 'Barnes & Noble',
      ),
      Delivery(
        id: 'd3',
        userId: '1',
        trackingNumber: 'TRK98765432',
        courierName: 'USPS',
        status: 'collected',
        expectedDeliveryDate: now.subtract(const Duration(days: 5)),
        actualDeliveryDate: now.subtract(const Duration(days: 5, hours: 3)),
        collectionDate: now.subtract(const Duration(days: 4)),
        collectedBy: 'John Doe',
        packageSize: 'large',
        packageDescription: 'Furniture',
        senderInfo: 'IKEA',
      ),
    ];
  }
  
  Future<void> loadUserDeliveries(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
      
      // In a real app, we would fetch from an API
      // final response = await _apiService.get('deliveries/user/$userId');
      // _deliveries = (response['data'] as List).map((item) => Delivery.fromJson(item)).toList();
      
      // Filter existing deliveries for this user
      _deliveries = _deliveries.where((delivery) => delivery.userId == userId).toList();
      
    } catch (e) {
      _error = 'Failed to load deliveries: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> getDeliveryById(String deliveryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      // Find the delivery in our local data
      _selectedDelivery = _deliveries.firstWhere(
        (delivery) => delivery.id == deliveryId,
        orElse: () => throw Exception('Delivery not found'),
      );
      
    } catch (e) {
      _error = 'Failed to get delivery details: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Delivery?> createDelivery({
    required String userId,
    required String trackingNumber,
    required String courierName,
    required DateTime expectedDeliveryDate,
    String? packageSize,
    String? packageDescription,
    String? senderInfo,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Create a new delivery
      final delivery = Delivery(
        id: Helpers.generateUuid(),
        userId: userId,
        trackingNumber: trackingNumber,
        courierName: courierName,
        status: 'pending',
        expectedDeliveryDate: expectedDeliveryDate,
        packageSize: packageSize,
        packageDescription: packageDescription,
        senderInfo: senderInfo,
        notes: notes,
      );
      
      // In a real app, we would send to an API
      // final response = await _apiService.post('deliveries', delivery.toJson());
      // final createdDelivery = Delivery.fromJson(response['data']);
      
      // Add to our local data
      _deliveries.add(delivery);
      _selectedDelivery = delivery;
      
      return delivery;
    } catch (e) {
      _error = 'Failed to create delivery: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateDeliveryStatus(String deliveryId, String status, {String? collectedBy}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Find the delivery
      final index = _deliveries.indexWhere((delivery) => delivery.id == deliveryId);
      if (index == -1) {
        throw Exception('Delivery not found');
      }
      
      // Update delivery data based on status
      late Delivery updatedDelivery;
      
      if (status == 'delivered') {
        updatedDelivery = _deliveries[index].copyWith(
          status: status,
          actualDeliveryDate: DateTime.now(),
        );
      } else if (status == 'collected') {
        updatedDelivery = _deliveries[index].copyWith(
          status: status,
          collectionDate: DateTime.now(),
          collectedBy: collectedBy,
        );
      } else if (status == 'returned') {
        updatedDelivery = _deliveries[index].copyWith(
          status: status,
        );
      } else {
        updatedDelivery = _deliveries[index].copyWith(
          status: status,
        );
      }
      
      // In a real app, we would send to an API
      // await _apiService.put('deliveries/$deliveryId/status', {'status': status});
      
      // Update our local data
      _deliveries[index] = updatedDelivery;
      if (_selectedDelivery?.id == deliveryId) {
        _selectedDelivery = updatedDelivery;
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to update delivery status: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearSelectedDelivery() {
    _selectedDelivery = null;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Format delivery status
  String formatDeliveryStatus(String status) {
    return status.substring(0, 1).toUpperCase() + status.substring(1);
  }
  
  // Get estimated delivery time range for a given date
  String getEstimatedDeliveryTime(DateTime date) {
    // For simplicity, we'll return a standard time range
    return '8:00 AM - 6:00 PM';
  }
  
  // Get status color for delivery status
  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'delivered':
        return Colors.blue;
      case 'collected':
        return Colors.green;
      case 'returned':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
