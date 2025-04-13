import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../core/models/invoice.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/helpers.dart';

class InvoiceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Invoice> _invoices = [];
  Invoice? _selectedInvoice;
  bool _isLoading = false;
  String? _error;
  
  List<Invoice> get invoices => _invoices;
  Invoice? get selectedInvoice => _selectedInvoice;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Invoice> get pendingInvoices => _invoices.where((invoice) => 
      invoice.status == 'pending' || invoice.status == 'overdue').toList();
  
  // Initialize with mock data for in-memory implementation
  InvoiceProvider() {
    _initializeSampleData();
  }
  
  void _initializeSampleData() {
    // Create sample invoices data
    final now = DateTime.now();
    
    _invoices = [
      Invoice(
        id: 'i1',
        userId: '1',
        amount: 300.0,
        dueDate: now.add(const Duration(days: 15)),
        issueDate: now.subtract(const Duration(days: 15)),
        status: 'pending',
        invoiceType: 'maintenance_fee',
        items: [
          InvoiceItem(
            id: 'ii1',
            description: 'Monthly Maintenance Fee',
            amount: 300.0,
            quantity: 1,
            totalAmount: 300.0,
          ),
        ],
      ),
      Invoice(
        id: 'i2',
        userId: '1',
        amount: 150.0,
        dueDate: now.subtract(const Duration(days: 10)),
        issueDate: now.subtract(const Duration(days: 40)),
        status: 'overdue',
        invoiceType: 'water_bill',
        items: [
          InvoiceItem(
            id: 'ii2',
            description: 'Water Consumption',
            amount: 150.0,
            quantity: 1,
            totalAmount: 150.0,
          ),
        ],
        notes: 'Please pay as soon as possible',
      ),
      Invoice(
        id: 'i3',
        userId: '1',
        amount: 200.0,
        dueDate: now.subtract(const Duration(days: 45)),
        issueDate: now.subtract(const Duration(days: 75)),
        status: 'paid',
        invoiceType: 'electricity_bill',
        paymentId: 'p2',
        items: [
          InvoiceItem(
            id: 'ii3',
            description: 'Electricity Consumption',
            amount: 200.0,
            quantity: 1,
            totalAmount: 200.0,
          ),
        ],
      ),
    ];
  }
  
  Future<void> loadUserInvoices(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
      
      // In a real app, we would fetch from an API
      // final response = await _apiService.get('invoices/user/$userId');
      // _invoices = (response['data'] as List).map((item) => Invoice.fromJson(item)).toList();
      
      // Filter existing invoices for this user
      _invoices = _invoices.where((invoice) => invoice.userId == userId).toList();
      
    } catch (e) {
      _error = 'Failed to load invoices: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> getInvoiceById(String invoiceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      // Find the invoice in our local data
      _selectedInvoice = _invoices.firstWhere(
        (invoice) => invoice.id == invoiceId,
        orElse: () => throw Exception('Invoice not found'),
      );
      
    } catch (e) {
      _error = 'Failed to get invoice details: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateInvoicePayment(String invoiceId, String paymentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Find the invoice
      final index = _invoices.indexWhere((invoice) => invoice.id == invoiceId);
      if (index == -1) {
        throw Exception('Invoice not found');
      }
      
      // Update the invoice
      final updatedInvoice = _invoices[index].copyWith(
        status: 'paid',
        paymentId: paymentId,
      );
      
      // In a real app, we would send to an API
      // await _apiService.put('invoices/$invoiceId', updatedInvoice.toJson());
      
      // Update our local data
      _invoices[index] = updatedInvoice;
      if (_selectedInvoice?.id == invoiceId) {
        _selectedInvoice = updatedInvoice;
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to update invoice payment: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearSelectedInvoice() {
    _selectedInvoice = null;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Format invoice type
  String formatInvoiceType(String type) {
    return type.split('_').map((word) => Helpers.capitalizeFirstLetter(word)).join(' ');
  }
}
