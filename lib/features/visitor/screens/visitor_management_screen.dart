import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/visitor_provider.dart';
import '../../../routes.dart' as app_routes;

class VisitorManagementScreen extends StatefulWidget {
  const VisitorManagementScreen({Key? key}) : super(key: key);

  @override
  _VisitorManagementScreenState createState() => _VisitorManagementScreenState();
}

class _VisitorManagementScreenState extends State<VisitorManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load user's visitors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<AuthProvider>(context, listen: false).currentUser!.id;
      Provider.of<VisitorProvider>(context, listen: false).loadUserVisitors(userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Visitor Management',
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, app_routes.AppRoutes.visitorHistory);
            },
            tooltip: 'History',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, app_routes.AppRoutes.addVisitor);
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Visitor',
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Theme.of(context).cardColor,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Upcoming'),
          Tab(text: 'Arrived'),
        ],
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        // Upcoming Visitors
        _buildUpcomingVisitors(),
        
        // Arrived Visitors
        _buildArrivedVisitors(),
      ],
    );
  }

  Widget _buildUpcomingVisitors() {
    return Consumer<VisitorProvider>(
      builder: (context, visitorProvider, child) {
        if (visitorProvider.isLoading) {
          return const LoadingIndicator();
        }

        if (visitorProvider.error != null) {
          return ErrorDisplayWidget(
            errorMessage: visitorProvider.error!,
            onRetry: () {
              final userId = Provider.of<AuthProvider>(context, listen: false).currentUser!.id;
              visitorProvider.loadUserVisitors(userId);
            },
          );
        }

        final pendingVisitors = visitorProvider.pendingVisitors;

        if (pendingVisitors.isEmpty) {
          return Center(
            child: EmptyStateWidget(
              message: 'No upcoming visitors',
              icon: Icons.people,
              actionLabel: 'Add Visitor',
              onAction: () {
                Navigator.pushNamed(context, app_routes.AppRoutes.addVisitor);
              },
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pendingVisitors.length,
          itemBuilder: (context, index) {
            final visitor = pendingVisitors[index];
            return _buildVisitorCard(visitor);
          },
        );
      },
    );
  }

  Widget _buildArrivedVisitors() {
    return Consumer<VisitorProvider>(
      builder: (context, visitorProvider, child) {
        if (visitorProvider.isLoading) {
          return const LoadingIndicator();
        }

        if (visitorProvider.error != null) {
          return ErrorDisplayWidget(
            errorMessage: visitorProvider.error!,
            onRetry: () {
              final userId = Provider.of<AuthProvider>(context, listen: false).currentUser!.id;
              visitorProvider.loadUserVisitors(userId);
            },
          );
        }

        final arrivedVisitors = visitorProvider.visitors.where(
          (visitor) => visitor.status == 'arrived'
        ).toList();

        if (arrivedVisitors.isEmpty) {
          return const EmptyStateWidget(
            message: 'No visitors currently on premises',
            icon: Icons.location_off,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: arrivedVisitors.length,
          itemBuilder: (context, index) {
            final visitor = arrivedVisitors[index];
            return _buildVisitorCard(visitor, showDepartureAction: true);
          },
        );
      },
    );
  }

  Widget _buildVisitorCard(visitor, {bool showDepartureAction = false}) {
    final isPending = visitor.status == 'pending';
    final isArrived = visitor.status == 'arrived';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visitor name and arrival time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    visitor.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isArrived ? Colors.green : Colors.blue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isArrived ? 'Arrived' : 'Expected',
                    style: TextStyle(
                      color: isArrived ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Purpose
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Purpose: ${visitor.purpose}',
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Expected arrival
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Expected: ${DateFormat('MMM dd, yyyy - h:mm a').format(visitor.expectedArrivalTime)}',
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            
            if (isArrived && visitor.actualArrivalTime != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.login,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Arrived: ${DateFormat('MMM dd, yyyy - h:mm a').format(visitor.actualArrivalTime!)}',
                    style: const TextStyle(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
            
            if (visitor.vehiclePlate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.directions_car,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Vehicle: ${visitor.vehiclePlate}',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],

            if (visitor.phone != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.phone,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Phone: ${visitor.phone}',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isPending)
                  OutlinedButton.icon(
                    onPressed: () => _showVisitorQRCode(visitor),
                    icon: const Icon(Icons.qr_code),
                    label: const Text('QR Code'),
                  ),
                const SizedBox(width: 8),
                if (isPending)
                  OutlinedButton.icon(
                    onPressed: () => _confirmCancelVisitor(visitor.id),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                if (showDepartureAction)
                  ElevatedButton.icon(
                    onPressed: () => _confirmDepartureVisitor(visitor.id),
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Mark Departure'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showVisitorQRCode(visitor) {
    final visitorProvider = Provider.of<VisitorProvider>(context, listen: false);
    final qrData = visitorProvider.generateVisitorQRData(visitor);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR Code for ${visitor.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Show this QR code at the entrance or security desk for easy check-in.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
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
  
  Future<void> _confirmCancelVisitor(String visitorId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Visitor'),
        content: const Text('Are you sure you want to cancel this visitor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      final visitorProvider = Provider.of<VisitorProvider>(context, listen: false);
      final success = await visitorProvider.updateVisitorStatus(visitorId, 'cancelled');
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visitor canceled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
  
  Future<void> _confirmDepartureVisitor(String visitorId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Departure'),
        content: const Text('Are you sure this visitor is departing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      final visitorProvider = Provider.of<VisitorProvider>(context, listen: false);
      final success = await visitorProvider.updateVisitorStatus(visitorId, 'departed');
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visitor departure recorded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
