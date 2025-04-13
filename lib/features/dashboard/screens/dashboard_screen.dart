import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/error_widget.dart';
import '../providers/dashboard_provider.dart';
import '../../../routes.dart' as app_routes;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    // Load dashboard data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).loadDashboardData();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final User? user = authProvider.currentUser;
    
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: LoadingIndicator(),
        ),
      );
    }
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: ErrorDisplayWidget(
            errorMessage: 'User not found. Please login again.',
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, app_routes.AppRoutes.profile);
            },
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: dashboardProvider.isLoading,
        child: _buildBody(dashboardProvider, user),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Invoices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Visitors',
          ),
        ],
      ),
    );
  }
  
  Widget _buildBody(DashboardProvider dashboardProvider, User user) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab(dashboardProvider, user);
      case 1:
        return _buildBookingsTab(dashboardProvider);
      case 2:
        return _buildInvoicesTab(dashboardProvider);
      case 3:
        return _buildVisitorsTab(dashboardProvider);
      default:
        return _buildHomeTab(dashboardProvider, user);
    }
  }
  
  Widget _buildHomeTab(DashboardProvider dashboardProvider, User user) {
    if (dashboardProvider.error != null) {
      return ErrorDisplayWidget(
        errorMessage: dashboardProvider.error!,
        onRetry: () => dashboardProvider.loadDashboardData(),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user.name}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unit: ${user.unitNumber}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildQuickActionCard(
                context,
                icon: Icons.calendar_today,
                title: 'Book Facility',
                onTap: () => Navigator.pushNamed(context, app_routes.AppRoutes.facilityList),
              ),
              _buildQuickActionCard(
                context,
                icon: Icons.payment,
                title: 'Make Payment',
                onTap: () => Navigator.pushNamed(context, app_routes.AppRoutes.payment),
              ),
              _buildQuickActionCard(
                context,
                icon: Icons.person_add,
                title: 'Add Visitor',
                onTap: () => Navigator.pushNamed(context, app_routes.AppRoutes.addVisitor),
              ),
              _buildQuickActionCard(
                context,
                icon: Icons.delivery_dining,
                title: 'Track Delivery',
                onTap: () => Navigator.pushNamed(context, app_routes.AppRoutes.deliveryTracker),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent activity
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          if (dashboardProvider.recentActivities.isEmpty)
            const EmptyStateWidget(
              message: 'No recent activities found',
              icon: Icons.history,
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dashboardProvider.recentActivities.length,
              itemBuilder: (context, index) {
                final activity = dashboardProvider.recentActivities[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(
                      _getActivityIcon(activity['type']),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: Text(activity['title']),
                  subtitle: Text(activity['description']),
                  trailing: Text(activity['time']),
                );
              },
            ),
        ],
      ),
    );
  }
  
  Widget _buildBookingsTab(DashboardProvider dashboardProvider) {
    if (dashboardProvider.error != null) {
      return ErrorDisplayWidget(
        errorMessage: dashboardProvider.error!,
        onRetry: () => dashboardProvider.loadDashboardData(),
      );
    }
    
    if (dashboardProvider.upcomingBookings.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          message: 'No upcoming bookings found',
          icon: Icons.calendar_today,
          actionLabel: 'Book Now',
          onAction: () => Navigator.pushNamed(context, app_routes.AppRoutes.facilityList),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: dashboardProvider.upcomingBookings.length,
      itemBuilder: (context, index) {
        final booking = dashboardProvider.upcomingBookings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.event,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(
              booking['facilityName'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Date: ${booking['date']}'),
                Text('Time: ${booking['time']}'),
                Text('Status: ${booking['status']}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                // Navigate to booking details
                Navigator.pushNamed(
                  context,
                  app_routes.AppRoutes.bookingConfirmation,
                  arguments: {'bookingId': booking['id']},
                );
              },
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildInvoicesTab(DashboardProvider dashboardProvider) {
    if (dashboardProvider.error != null) {
      return ErrorDisplayWidget(
        errorMessage: dashboardProvider.error!,
        onRetry: () => dashboardProvider.loadDashboardData(),
      );
    }
    
    if (dashboardProvider.pendingInvoices.isEmpty) {
      return const Center(
        child: EmptyStateWidget(
          message: 'No pending invoices found',
          icon: Icons.description,
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: dashboardProvider.pendingInvoices.length,
      itemBuilder: (context, index) {
        final invoice = dashboardProvider.pendingInvoices[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                invoice['status'] == 'overdue' ? Icons.warning : Icons.description,
                color: invoice['status'] == 'overdue' ? Colors.red : Theme.of(context).primaryColor,
              ),
            ),
            title: Text(
              invoice['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Amount: ${invoice['amount']}'),
                Text('Due: ${invoice['dueDate']}'),
                Text(
                  'Status: ${invoice['status']}',
                  style: TextStyle(
                    color: invoice['status'] == 'overdue' ? Colors.red : null,
                    fontWeight: invoice['status'] == 'overdue' ? FontWeight.bold : null,
                  ),
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () {
                // Navigate to payment screen
                Navigator.pushNamed(
                  context,
                  app_routes.AppRoutes.payment,
                  arguments: {
                    'amount': invoice['amountValue'],
                    'purpose': 'Invoice Payment',
                    'referenceId': invoice['id'],
                  },
                );
              },
              child: const Text('Pay'),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildVisitorsTab(DashboardProvider dashboardProvider) {
    if (dashboardProvider.error != null) {
      return ErrorDisplayWidget(
        errorMessage: dashboardProvider.error!,
        onRetry: () => dashboardProvider.loadDashboardData(),
      );
    }
    
    if (dashboardProvider.pendingVisitors.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          message: 'No pending visitors found',
          icon: Icons.people,
          actionLabel: 'Add Visitor',
          onAction: () => Navigator.pushNamed(context, app_routes.AppRoutes.addVisitor),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: dashboardProvider.pendingVisitors.length,
      itemBuilder: (context, index) {
        final visitor = dashboardProvider.pendingVisitors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(
              visitor['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Purpose: ${visitor['purpose']}'),
                Text('Expected: ${visitor['expectedArrival']}'),
                if (visitor['vehiclePlate'] != null)
                  Text('Vehicle: ${visitor['vehiclePlate']}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.qr_code),
              onPressed: () {
                // Show QR code for visitor
                _showVisitorQRCode(visitor);
              },
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'booking':
        return Icons.event;
      case 'payment':
        return Icons.payment;
      case 'visitor':
        return Icons.person;
      case 'delivery':
        return Icons.local_shipping;
      case 'invoice':
        return Icons.description;
      default:
        return Icons.notifications;
    }
  }
  
  void _showVisitorQRCode(Map<String, dynamic> visitor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR Code for ${visitor['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code,
                  size: 180,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Show this QR code at the entrance for quick check-in.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
