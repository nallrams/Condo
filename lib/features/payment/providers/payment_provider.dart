import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../core/models/payment.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/helpers.dart';

class PaymentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Payment> _payments = [];
  Payment? _selectedPayment;
  bool _isLoading = false;
  String? _error;
  
  List<Payment> get payments => _payments;
  Payment? get selectedPayment => _selectedPayment;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Initialize with mock data for in-memory implementation
  PaymentProvider() {
    _initializeSampleData();
  }
  
  void _initializeSampleData() {
    // Create sample payments data
    final now = DateTime.now();
    
    _payments = [
      Payment(
        id: 'p1',
        userId: '1',
        amount: 50.0,
        status: 'completed',
        paymentMethod: 'credit_card',
        paymentDate: now.subtract(const Duration(days: 15)),
        referenceId: 'f3', // Function Room
        referenceType: 'booking',
        paymentDetails: {
          'cardNumber': '**** **** **** 1234',
          'cardHolder': 'John Doe',
          'expiryDate': '12/24',
        },
      ),
      Payment(
        id: 'p2',
        userId: '1',
        amount: 300.0,
        status: 'completed',
        paymentMethod: 'bank_transfer',
        paymentDate: now.subtract(const Duration(days: 30)),
        referenceId: 'i1', // Invoice
        referenceType: 'invoice',
        notes: 'Monthly maintenance fee',
      ),
    ];
  }
  
  Future<void> loadUserPayments(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
      
      // In a real app, we would fetch from an API
      // final response = await _apiService.get('payments/user/$userId');
      // _payments = (response['data'] as List).map((item) => Payment.fromJson(item)).toList();
      
      // Filter existing payments for this user
      _payments = _payments.where((payment) => payment.userId == userId).toList();
      
    } catch (e) {
      _error = 'Failed to load payments: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> getPaymentById(String paymentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      // Find the payment in our local data
      _selectedPayment = _payments.firstWhere(
        (payment) => payment.id == paymentId,
        orElse: () => throw Exception('Payment not found'),
      );
      
    } catch (e) {
      _error = 'Failed to get payment details: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Payment?> processPayment({
    required String userId,
    required double amount,
    required String paymentMethod,
    required String referenceId,
    required String referenceType,
    Map<String, dynamic>? paymentDetails,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
      
      // Create a new payment
      final payment = Payment(
        id: Helpers.generateUuid(),
        userId: userId,
        amount: amount,
        status: 'completed', // Simulate successful payment
        paymentMethod: paymentMethod,
        paymentDate: DateTime.now(),
        referenceId: referenceId,
        referenceType: referenceType,
        paymentDetails: paymentDetails,
        notes: notes,
      );
      
      // In a real app, we would send to an API
      // final response = await _apiService.post('payments', payment.toJson());
      // final processedPayment = Payment.fromJson(response['data']);
      
      // Add to our local data
      _payments.add(payment);
      _selectedPayment = payment;
      
      return payment;
    } catch (e) {
      _error = 'Failed to process payment: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearSelectedPayment() {
    _selectedPayment = null;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
