import 'package:flutter/foundation.dart';
import '../../../core/models/facility.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/helpers.dart';

class FacilityProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Facility> _facilities = [];
  Facility? _selectedFacility;
  bool _isLoading = false;
  String? _error;
  
  List<Facility> get facilities => _facilities;
  Facility? get selectedFacility => _selectedFacility;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Initialize with mock data for in-memory implementation
  FacilityProvider() {
    _initializeSampleData();
  }
  
  void _initializeSampleData() {
    // Create sample facilities data
    _facilities = [
      Facility(
        id: 'f1',
        name: 'Swimming Pool',
        description: 'Olympic-sized swimming pool with lifeguard services. Perfect for relaxation and exercise.',
        imageUrl: 'https://source.unsplash.com/random/?swimmingpool',
        hourlyRate: 10.0,
        maxCapacity: 30,
        amenities: ['Shower', 'Locker Room', 'Towel Service', 'Sun Loungers'],
        rules: ['No diving', 'No food or drinks', 'Children must be supervised', 'Shower before entering'],
        operatingHours: {
          'monday': {'open': '06:00', 'close': '22:00'},
          'tuesday': {'open': '06:00', 'close': '22:00'},
          'wednesday': {'open': '06:00', 'close': '22:00'},
          'thursday': {'open': '06:00', 'close': '22:00'},
          'friday': {'open': '06:00', 'close': '22:00'},
          'saturday': {'open': '08:00', 'close': '20:00'},
          'sunday': {'open': '08:00', 'close': '20:00'},
        },
      ),
      Facility(
        id: 'f2',
        name: 'Gym',
        description: 'Fully-equipped fitness center with cardio machines, weights, and personal training services.',
        imageUrl: 'https://source.unsplash.com/random/?gym',
        hourlyRate: 5.0,
        maxCapacity: 20,
        amenities: ['Treadmills', 'Weight Machines', 'Free Weights', 'Yoga Mats', 'Water Dispenser'],
        rules: ['Proper gym attire required', 'Wipe equipment after use', 'No food', 'Return weights to rack'],
        operatingHours: {
          'monday': {'open': '05:00', 'close': '23:00'},
          'tuesday': {'open': '05:00', 'close': '23:00'},
          'wednesday': {'open': '05:00', 'close': '23:00'},
          'thursday': {'open': '05:00', 'close': '23:00'},
          'friday': {'open': '05:00', 'close': '23:00'},
          'saturday': {'open': '07:00', 'close': '22:00'},
          'sunday': {'open': '07:00', 'close': '22:00'},
        },
      ),
      Facility(
        id: 'f3',
        name: 'Function Room',
        description: 'Elegant multipurpose room ideal for private parties, meetings, and special occasions.',
        imageUrl: 'https://source.unsplash.com/random/?eventroom',
        hourlyRate: 50.0,
        maxCapacity: 100,
        amenities: ['Tables & Chairs', 'Sound System', 'Projector', 'Kitchenette', 'Air-Conditioning'],
        rules: ['No smoking', 'Clean up after use', 'No loud music after 10 PM', 'Security deposit required'],
        operatingHours: {
          'monday': {'open': '09:00', 'close': '22:00'},
          'tuesday': {'open': '09:00', 'close': '22:00'},
          'wednesday': {'open': '09:00', 'close': '22:00'},
          'thursday': {'open': '09:00', 'close': '22:00'},
          'friday': {'open': '09:00', 'close': '23:00'},
          'saturday': {'open': '09:00', 'close': '23:00'},
          'sunday': {'open': '09:00', 'close': '22:00'},
        },
      ),
      Facility(
        id: 'f4',
        name: 'Tennis Court',
        description: 'Professional-grade tennis court with night lighting and optional coaching services.',
        imageUrl: 'https://source.unsplash.com/random/?tenniscourt',
        hourlyRate: 15.0,
        maxCapacity: 4,
        amenities: ['Net', 'Court Lights', 'Rest Area', 'Water Dispenser'],
        rules: ['Proper tennis shoes required', 'Maximum 2 hours per booking', 'No food on court', 'Cancel 24 hours in advance'],
        operatingHours: {
          'monday': {'open': '07:00', 'close': '21:00'},
          'tuesday': {'open': '07:00', 'close': '21:00'},
          'wednesday': {'open': '07:00', 'close': '21:00'},
          'thursday': {'open': '07:00', 'close': '21:00'},
          'friday': {'open': '07:00', 'close': '21:00'},
          'saturday': {'open': '08:00', 'close': '20:00'},
          'sunday': {'open': '08:00', 'close': '20:00'},
        },
      ),
      Facility(
        id: 'f5',
        name: 'BBQ Area',
        description: 'Outdoor barbecue area with grills, tables, and beautiful garden views.',
        imageUrl: 'https://source.unsplash.com/random/?bbq',
        hourlyRate: 20.0,
        maxCapacity: 15,
        amenities: ['Gas Grills', 'Seating Area', 'Sink', 'Waste Disposal'],
        rules: ['Clean grills after use', 'No loud noise after 10 PM', 'Bring your own utensils', 'Book at least 48 hours in advance'],
        operatingHours: {
          'monday': {'open': '10:00', 'close': '22:00'},
          'tuesday': {'open': '10:00', 'close': '22:00'},
          'wednesday': {'open': '10:00', 'close': '22:00'},
          'thursday': {'open': '10:00', 'close': '22:00'},
          'friday': {'open': '10:00', 'close': '22:00'},
          'saturday': {'open': '10:00', 'close': '22:00'},
          'sunday': {'open': '10:00', 'close': '22:00'},
        },
      ),
    ];
  }
  
  Future<void> loadFacilities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
      
      // In a real app, we would fetch from an API
      // final response = await _apiService.get('facilities');
      // _facilities = (response['data'] as List).map((item) => Facility.fromJson(item)).toList();
      
      // We already have our sample data, so nothing to do here
      
    } catch (e) {
      _error = 'Failed to load facilities: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> getFacilityById(String facilityId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      // Find the facility in our local data
      _selectedFacility = _facilities.firstWhere(
        (facility) => facility.id == facilityId,
        orElse: () => throw Exception('Facility not found'),
      );
      
    } catch (e) {
      _error = 'Failed to get facility details: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearSelectedFacility() {
    _selectedFacility = null;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
