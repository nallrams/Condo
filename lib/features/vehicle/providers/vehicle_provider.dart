import 'package:flutter/foundation.dart';
import '../../../core/models/vehicle.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/helpers.dart';

class VehicleProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;
  bool _isLoading = false;
  String? _error;
  
  List<Vehicle> get vehicles => _vehicles;
  Vehicle? get selectedVehicle => _selectedVehicle;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Initialize with mock data for in-memory implementation
  VehicleProvider() {
    _initializeSampleData();
  }
  
  void _initializeSampleData() {
    // Create sample vehicles data
    _vehicles = [
      Vehicle(
        id: 'v1',
        userId: '1',
        licensePlate: 'ABC123',
        make: 'Toyota',
        model: 'Camry',
        color: 'Silver',
        type: 'car',
        isPrimary: true,
        isRegistered: true,
        parkingSlot: 'A-101',
        registrationDate: DateTime.now().subtract(const Duration(days: 90)),
      ),
      Vehicle(
        id: 'v2',
        userId: '1',
        licensePlate: 'XYZ789',
        make: 'Honda',
        model: 'Civic',
        color: 'Blue',
        type: 'car',
        isPrimary: false,
        isRegistered: true,
        parkingSlot: 'A-102',
        registrationDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
  }
  
  Future<void> loadUserVehicles(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
      
      // In a real app, we would fetch from an API
      // final response = await _apiService.get('vehicles/user/$userId');
      // _vehicles = (response['data'] as List).map((item) => Vehicle.fromJson(item)).toList();
      
      // Filter existing vehicles for this user
      _vehicles = _vehicles.where((vehicle) => vehicle.userId == userId).toList();
      
    } catch (e) {
      _error = 'Failed to load vehicles: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> getVehicleById(String vehicleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      // Find the vehicle in our local data
      _selectedVehicle = _vehicles.firstWhere(
        (vehicle) => vehicle.id == vehicleId,
        orElse: () => throw Exception('Vehicle not found'),
      );
      
    } catch (e) {
      _error = 'Failed to get vehicle details: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Vehicle?> createVehicle({
    required String userId,
    required String licensePlate,
    required String make,
    required String model,
    required String color,
    required String type,
    required bool isPrimary,
    String? parkingSlot,
    Map<String, dynamic>? additionalInfo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // If setting this vehicle as primary, update all other vehicles
      if (isPrimary) {
        for (var i = 0; i < _vehicles.length; i++) {
          if (_vehicles[i].userId == userId && _vehicles[i].isPrimary) {
            _vehicles[i] = _vehicles[i].copyWith(isPrimary: false);
          }
        }
      }
      
      // Create a new vehicle
      final vehicle = Vehicle(
        id: Helpers.generateUuid(),
        userId: userId,
        licensePlate: licensePlate,
        make: make,
        model: model,
        color: color,
        type: type,
        isPrimary: isPrimary,
        isRegistered: true,
        parkingSlot: parkingSlot,
        registrationDate: DateTime.now(),
        additionalInfo: additionalInfo,
      );
      
      // In a real app, we would send to an API
      // final response = await _apiService.post('vehicles', vehicle.toJson());
      // final createdVehicle = Vehicle.fromJson(response['data']);
      
      // Add to our local data
      _vehicles.add(vehicle);
      _selectedVehicle = vehicle;
      
      return vehicle;
    } catch (e) {
      _error = 'Failed to create vehicle: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateVehicle({
    required String vehicleId,
    String? licensePlate,
    String? make,
    String? model,
    String? color,
    String? type,
    bool? isPrimary,
    String? parkingSlot,
    Map<String, dynamic>? additionalInfo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Find the vehicle
      final index = _vehicles.indexWhere((vehicle) => vehicle.id == vehicleId);
      if (index == -1) {
        throw Exception('Vehicle not found');
      }
      
      final currentVehicle = _vehicles[index];
      
      // If setting this vehicle as primary, update all other vehicles
      if (isPrimary == true && !currentVehicle.isPrimary) {
        for (var i = 0; i < _vehicles.length; i++) {
          if (_vehicles[i].userId == currentVehicle.userId && _vehicles[i].isPrimary) {
            _vehicles[i] = _vehicles[i].copyWith(isPrimary: false);
          }
        }
      }
      
      // Update the vehicle
      final updatedVehicle = currentVehicle.copyWith(
        licensePlate: licensePlate,
        make: make,
        model: model,
        color: color,
        type: type,
        isPrimary: isPrimary,
        parkingSlot: parkingSlot,
        additionalInfo: additionalInfo,
      );
      
      // In a real app, we would send to an API
      // await _apiService.put('vehicles/$vehicleId', updatedVehicle.toJson());
      
      // Update our local data
      _vehicles[index] = updatedVehicle;
      if (_selectedVehicle?.id == vehicleId) {
        _selectedVehicle = updatedVehicle;
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to update vehicle: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> deleteVehicle(String vehicleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // In a real app, we would send to an API
      // await _apiService.delete('vehicles/$vehicleId');
      
      // Remove from our local data
      _vehicles.removeWhere((vehicle) => vehicle.id == vehicleId);
      if (_selectedVehicle?.id == vehicleId) {
        _selectedVehicle = null;
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to delete vehicle: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearSelectedVehicle() {
    _selectedVehicle = null;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Format vehicle type
  String formatVehicleType(String type) {
    return Helpers.capitalizeFirstLetter(type);
  }
}
