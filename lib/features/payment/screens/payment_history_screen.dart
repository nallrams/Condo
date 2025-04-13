import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/payment_provider.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({Key? key}) : super(key: key);

  @override
  _PaymentHistoryScreenState createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load user's payments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<AuthProvider>(context, listen: false).currentUser!.id;
      Provider.of<PaymentProvider>(context, listen: false).loadUserPayments(userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onFilterChanged(String status) {
    setState(() {
      _filterStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Payment History',
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Payments'),
            Tab(text: 'Recent Transactions'),
          ],
        ),
        bottomHeight: 48,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPaymentsTab(),
          _buildRecentTransactionsTab(),
        ],
      ),
    );
  }

  Widget _buildPaymentsTab() {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, child) {
        if (paymentProvider.isLoading) {
          return const LoadingIndicator();
        }

        if (paymentProvider.error != null) {
          return ErrorDisplayWidget(
            errorMessage: paymentProvider.error!,
            onRetry: () {
              final userId = Provider.of<AuthProvider>(context, listen: false).currentUser!.id;
              paymentProvider.loadUserPayments(userId);
            },
          );
        }

        if (paymentProvider.payments.isEmpty) {
          return const EmptyStateWidget(
            message: 'No payment history found',
            icon: Icons.payment,
          );
        }

        return Column(
          children: [
            _buildFilterChips(),
            Expanded(
              child: _buildPaymentsList(paymentProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Theme.of(context).cardColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', 'All'),
            const SizedBox(width: 8),
            _buildFilterChip('completed', 'Completed'),
            const SizedBox(width: 8),
            _buildFilterChip('pending', 'Pending'),
            const SizedBox(width: 8),
            _buildFilterChip('failed', 'Failed'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String status, String label) {
    final isSelected = _filterStatus == status;
    
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) => _onFilterChanged(status),
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : null,
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
    );
  }

  Widget _buildPaymentsList(PaymentProvider paymentProvider) {
    final filteredPayments = _filterStatus == 'all'
        ? paymentProvider.payments
        : paymentProvider.payments.where((p) => p.status == _filterStatus).toList();
    
    if (filteredPayments.isEmpty) {
      return Center(
        child: Text(
          'No $_filterStatus payments found',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPayments.length,
      itemBuilder: (context, index) {
        final payment = filteredPayments[index];
        return _buildPaymentCard(payment);
      },
    );
  }

  Widget _buildPaymentCard(payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showPaymentDetails(payment),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Amount
                  Text(
                    Helpers.formatCurrency(payment.amount),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Helpers.getStatusColor(payment.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      Helpers.getPrettyStatus(payment.status),
                      style: TextStyle(
                        color: Helpers.getStatusColor(payment.status),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Payment date
              Row(
                children: [
                  const Icon(
                    Icons.date_range,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy - h:mm a').format(payment.paymentDate),
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Payment method
              Row(
                children: [
                  const Icon(
                    Icons.payment,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Method: ${_formatPaymentMethod(payment.paymentMethod)}',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Payment type/purpose
              if (payment.notes != null && payment.notes.isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        payment.notes,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              // Reference ID
              Row(
                children: [
                  const Icon(
                    Icons.receipt,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ref: ${payment.referenceId}',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsTab() {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, child) {
        if (paymentProvider.isLoading) {
          return const LoadingIndicator();
        }

        if (paymentProvider.error != null) {
          return ErrorDisplayWidget(
            errorMessage: paymentProvider.error!,
            onRetry: () {
              final userId = Provider.of<AuthProvider>(context, listen: false).currentUser!.id;
              paymentProvider.loadUserPayments(userId);
            },
          );
        }

        // Get the last 5 payments
        final recentPayments = paymentProvider.payments.take(5).toList();

        if (recentPayments.isEmpty) {
          return const EmptyStateWidget(
            message: 'No recent transactions found',
            icon: Icons.history,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: recentPayments.length,
          itemBuilder: (context, index) {
            final payment = recentPayments[index];
            return _buildTransactionItem(payment);
          },
        );
      },
    );
  }

  Widget _buildTransactionItem(payment) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Helpers.getStatusColor(payment.status).withOpacity(0.2),
        child: Icon(
          payment.status == 'completed' 
              ? Icons.check 
              : payment.status == 'pending' 
                  ? Icons.access_time 
                  : Icons.error_outline,
          color: Helpers.getStatusColor(payment.status),
        ),
      ),
      title: Text(Helpers.formatCurrency(payment.amount)),
      subtitle: Text(
        '${_formatReferenceType(payment.referenceType)} • ${DateFormat('MMM dd').format(payment.paymentDate)}',
      ),
      trailing: Text(
        Helpers.getPrettyStatus(payment.status),
        style: TextStyle(
          color: Helpers.getStatusColor(payment.status),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () => _showPaymentDetails(payment),
    );
  }
  
  void _showPaymentDetails(payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                
                // Payment Amount and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Amount',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Helpers.formatCurrency(payment.amount),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Helpers.getStatusColor(payment.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        Helpers.getPrettyStatus(payment.status),
                        style: TextStyle(
                          color: Helpers.getStatusColor(payment.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Payment Details
                _buildDetailRow('Date', DateFormat('MMM dd, yyyy - h:mm a').format(payment.paymentDate)),
                _buildDetailRow('Payment Method', _formatPaymentMethod(payment.paymentMethod)),
                _buildDetailRow('Reference Type', _formatReferenceType(payment.referenceType)),
                _buildDetailRow('Reference ID', payment.referenceId),
                if (payment.paymentId != null) 
                  _buildDetailRow('Transaction ID', payment.paymentId!),
                
                const SizedBox(height: 16),
                const Divider(),
                
                // Payment Notes
                if (payment.notes != null && payment.notes.isNotEmpty) ...[
                  const Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(payment.notes),
                  const SizedBox(height: 16),
                  const Divider(),
                ],
                
                // Payment Details
                if (payment.paymentDetails != null && payment.paymentDetails.isNotEmpty) ...[
                  const Text(
                    'Payment Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...payment.paymentDetails.entries.map((entry) {
                    // Skip sensitive info like card numbers 
                    if (entry.key == 'cardNumber') {
                      final masked = entry.value.toString().replaceRange(
                        0, 
                        entry.value.toString().length - 4, 
                        '*' * (entry.value.toString().length - 4)
                      );
                      return _buildDetailRow(
                        Helpers.capitalizeFirstLetter(entry.key), 
                        masked
                      );
                    }
                    return _buildDetailRow(
                      Helpers.capitalizeFirstLetter(entry.key), 
                      entry.value.toString()
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatPaymentMethod(String method) {
    return Helpers.getPrettyStatus(method);
  }
  
  String _formatReferenceType(String type) {
    return Helpers.getPrettyStatus(type);
  }
}