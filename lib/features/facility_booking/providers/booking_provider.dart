import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../core/models/booking.dart';
import '../../../core/models/facility.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/helpers.dart';

class BookingProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Booking> _bookings = [];
  List<DateTime> _unavailableDates = [];
  List<String> _unavailableTimeSlots = [];
  Booking? _selectedBooking;
  DateTime _selectedDate = DateTime.now();
  String _selectedStartTime = '';
  String _selectedEndTime = '';
  int _guestCount = 1;
  String? _notes;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Booking> get bookings => _bookings;
  List<DateTime> get unavailableDates => _unavailableDates;
  List<String> get unavailableTimeSlots => _unavailableTimeSlots;
  Booking? get selectedBooking => _selectedBooking;
  DateTime get selectedDate => _selectedDate;
  String get selectedStartTime => _selectedStartTime;
  String get selectedEndTime => _selectedEndTime;
  int get guestCount => _guestCount;
  String? get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Initialize with mock data for in-memory implementation
  BookingProvider() {
    _initializeSampleData();
  }
  
  void _initializeSampleData() {
    // Create sample bookings data
    final now = DateTime.now();
    
    _bookings = [
      Booking(
        id: 'b1',
        facilityId: 'f1', // Swimming Pool
        userId: '1',
        startTime: DateTime(now.year, now.month, now.day + 2, 10, 0),
        endTime: DateTime(now.year, now.month, now.day + 2, 12, 0),
        status: 'confirmed',
        totalAmount: 20.0, // 2 hours * $10/hour
        paymentId: 'p1',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        numberOfGuests: 2,
      ),
      Booking(
        id: 'b2',
        facilityId: 'f3', // Function Room
        userId: '1',
        startTime: DateTime(now.year, now.month, now.day + 5, 14, 0),
        endTime: DateTime(now.year, now.month, now.day + 5, 18, 0),
        status: 'pending',
        totalAmount: 200.0, // 4 hours * $50/hour
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        notes: 'Birthday party',
        numberOfGuests: 30,
      ),
    ];
  }
  
  Future<void> loadUserBookings(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
      
      // In a real app, we would fetch from an API
      // final response = await _apiService.get('bookings/user/$userId');
      // _bookings = (response['data'] as List).map((item) => Booking.fromJson(item)).toList();
      
      // Filter existing bookings for this user
      _bookings = _bookings.where((booking) => booking.userId == userId).toList();
      
    } catch (e) {
      _error = 'Failed to load bookings: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> getBookingById(String bookingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      // Find the booking in our local data
      _selectedBooking = _bookings.firstWhere(
        (booking) => booking.id == bookingId,
        orElse: () => throw Exception('Booking not found'),
      );
      
    } catch (e) {
      _error = 'Failed to get booking details: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadFacilityAvailability(String facilityId, DateTime date) async {
    _isLoading = true;
    _error = null;
    _selectedDate = date;
    _unavailableTimeSlots = [];
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
      
      // In a real app, we would fetch from an API
      // final response = await _apiService.get('facilities/$facilityId/availability?date=${date.toIso8601String()}');
      // _unavailableTimeSlots = List<String>.from(response['unavailableTimeSlots']);
      
      // Create some unavailable time slots for demonstration
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      
      // Check if we have existing bookings for this facility on this date
      final bookingsOnDate = _bookings.where((booking) => 
        booking.facilityId == facilityId && 
        DateFormat('yyyy-MM-dd').format(booking.startTime) == dateString
      ).toList();
      
      // Mark those times as unavailable
      for (var booking in bookingsOnDate) {
        final startHour = booking.startTime.hour;
        final endHour = booking.endTime.hour;
        
        for (var hour = startHour; hour < endHour; hour++) {
          _unavailableTimeSlots.add('$hour:00');
        }
      }
      
    } catch (e) {
      _error = 'Failed to load availability: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _selectedStartTime = '';
    _selectedEndTime = '';
    notifyListeners();
  }
  
  void setSelectedTimeSlot(String startTime, String endTime) {
    _selectedStartTime = startTime;
    _selectedEndTime = endTime;
    notifyListeners();
  }
  
  void setGuestCount(int count) {
    _guestCount = count;
    notifyListeners();
  }
  
  void setNotes(String? notes) {
    _notes = notes;
    notifyListeners();
  }
  
  Future<Booking?> createBooking(String userId, Facility facility) async {
    if (_selectedDate == null || _selectedStartTime.isEmpty || _selectedEndTime.isEmpty) {
      _error = 'Please select a date and time slot';
      notifyListeners();
      return null;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Parse times
      final startTimeParts = _selectedStartTime.split(':');
      final endTimeParts = _selectedEndTime.split(':');
      final startTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        int.parse(startTimeParts[0]),
        int.parse(startTimeParts[1]),
      );
      final endTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        int.parse(endTimeParts[0]),
        int.parse(endTimeParts[1]),
      );
      
      // Calculate duration in hours
      final durationInHours = endTime.difference(startTime).inHours;
      
      // Calculate total amount
      final totalAmount = durationInHours * facility.hourlyRate;
      
      // Create booking
      final newBooking = Booking(
        id: Helpers.generateUuid(),
        facilityId: facility.id,
        userId: userId,
        startTime: startTime,
        endTime: endTime,
        status: 'pending',
        totalAmount: totalAmount,
        createdAt: DateTime.now(),
        notes: _notes,
        numberOfGuests: _guestCount,
      );
      
      // In a real app, we would send to an API
      // final response = await _apiService.post('bookings', newBooking.toJson());
      // final createdBooking = Booking.fromJson(response['data']);
      
      // Add to our local data
      _bookings.add(newBooking);
      _selectedBooking = newBooking;
      
      return newBooking;
    } catch (e) {
      _error = 'Failed to create booking: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> cancelBooking(String bookingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Find the booking
      final index = _bookings.indexWhere((booking) => booking.id == bookingId);
      if (index == -1) {
        throw Exception('Booking not found');
      }
      
      // Update the status
      final updatedBooking = _bookings[index].copyWith(status: 'cancelled');
      
      // In a real app, we would send to an API
      // await _apiService.put('bookings/$bookingId/cancel', {});
      
      // Update our local data
      _bookings[index] = updatedBooking;
      if (_selectedBooking?.id == bookingId) {
        _selectedBooking = updatedBooking;
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to cancel booking: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearSelectedBooking() {
    _selectedBooking = null;
    notifyListeners();
  }
  
  void clearBookingForm() {
    _selectedDate = DateTime.now();
    _selectedStartTime = '';
    _selectedEndTime = '';
    _guestCount = 1;
    _notes = null;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Get list of available time slots for a given facility and date
  List<Map<String, String>> getAvailableTimeSlots(Facility facility, DateTime date) {
    // Get the operating hours for this day of the week
    final dayOfWeek = DateFormat('EEEE').format(date).toLowerCase();
    final operatingHours = facility.operatingHours?[dayOfWeek];
    
    if (operatingHours == null) {
      return [];
    }
    
    final openTime = operatingHours['open']!;
    final closeTime = operatingHours['close']!;
    
    final openHour = int.parse(openTime.split(':')[0]);
    final closeHour = int.parse(closeTime.split(':')[0]);
    
    final List<Map<String, String>> timeSlots = [];
    
    // Generate hourly time slots
    for (var hour = openHour; hour < closeHour; hour++) {
      final startTime = '$hour:00';
      final endTime = '${hour + 1}:00';
      
      // Check if this time slot is available
      final isAvailable = !_unavailableTimeSlots.contains(startTime);
      
      if (isAvailable) {
        timeSlots.add({
          'startTime': startTime,
          'endTime': endTime,
        });
      }
    }
    
    return timeSlots;
  }
}
