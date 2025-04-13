import 'package:flutter/foundation.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/helpers.dart';

class DashboardProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  List<Map<String, dynamic>> _recentActivities = [];
  List<Map<String, dynamic>> _upcomingBookings = [];
  List<Map<String, dynamic>> _pendingInvoices = [];
  List<Map<String, dynamic>> _pendingVisitors = [];
  bool _isLoading = false;
  String? _error;
  
  List<Map<String, dynamic>> get recentActivities => _recentActivities;
  List<Map<String, dynamic>> get upcomingBookings => _upcomingBookings;
  List<Map<String, dynamic>> get pendingInvoices => _pendingInvoices;
  List<Map<String, dynamic>> get pendingVisitors => _pendingVisitors;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // In a real app, we would fetch this data from an API
      // For now, we'll create some sample data for demonstration
      _recentActivities = _createSampleRecentActivities();
      _upcomingBookings = _createSampleUpcomingBookings();
      _pendingInvoices = _createSamplePendingInvoices();
      _pendingVisitors = _createSamplePendingVisitors();
      
      // Store in local storage for persistence
      await _storageService.saveData('recent_activities', _recentActivities);
      await _storageService.saveData('upcoming_bookings', _upcomingBookings);
      await _storageService.saveData('pending_invoices', _pendingInvoices);
      await _storageService.saveData('pending_visitors', _pendingVisitors);
    } catch (e) {
      _error = 'Failed to load dashboard data: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Sample data generators
  List<Map<String, dynamic>> _createSampleRecentActivities() {
    // In a real app, this would come from an API
    return [];
  }
  
  List<Map<String, dynamic>> _createSampleUpcomingBookings() {
    // In a real app, this would come from an API
    return [];
  }
  
  List<Map<String, dynamic>> _createSamplePendingInvoices() {
    // In a real app, this would come from an API
    return [];
  }
  
  List<Map<String, dynamic>> _createSamplePendingVisitors() {
    // In a real app, this would come from an API
    return [];
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
