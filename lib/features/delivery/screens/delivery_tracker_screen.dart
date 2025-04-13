import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/delivery.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_widget.dart' as app_error;
import '../providers/delivery_provider.dart';
import '../../../routes.dart' as app_routes;

class DeliveryTrackerScreen extends StatefulWidget {
  const DeliveryTrackerScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryTrackerScreen> createState() => _DeliveryTrackerScreenState();
}

class _DeliveryTrackerScreenState extends State<DeliveryTrackerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // In a real app, get userId from auth provider
      Provider.of<DeliveryProvider>(context, listen: false).loadUserDeliveries('1');
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Tracker'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Delivered'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, app_routes.AppRoutes.addDelivery);
            },
          ),
        ],
      ),
      body: Consumer<DeliveryProvider>(
        builder: (context, deliveryProvider, child) {
          if (deliveryProvider.isLoading) {
            return const LoadingIndicator();
          }

          if (deliveryProvider.error != null) {
            return app_error.ErrorDisplayWidget(
              errorMessage: deliveryProvider.error!,
              onRetry: () {
                deliveryProvider.loadUserDeliveries('1');
              },
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildDeliveryList(deliveryProvider.pendingDeliveries),
              _buildDeliveryList(deliveryProvider.deliveredDeliveries),
              _buildDeliveryList(deliveryProvider.completedDeliveries),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDeliveryList(List<Delivery> deliveries) {
    if (deliveries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No deliveries found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: deliveries.length,
      itemBuilder: (context, index) {
        final delivery = deliveries[index];
        return _buildDeliveryCard(delivery);
      },
    );
  }

  Widget _buildDeliveryCard(Delivery delivery) {
    final deliveryProvider = Provider.of<DeliveryProvider>(context, listen: false);
    final statusColor = deliveryProvider.getStatusColor(delivery.status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          deliveryProvider.getDeliveryById(delivery.id);
          // TODO: Navigate to delivery detail screen
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(delivery.status),
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          deliveryProvider.formatDeliveryStatus(delivery.status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    delivery.courierName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.numbers, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tracking: ${delivery.trackingNumber}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Package: ${delivery.packageDescription ?? "N/A"}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.event, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Expected: ${_formatDate(delivery.expectedDeliveryDate)}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
              if (delivery.status == 'delivered')
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showCollectionDialog(delivery);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Mark as Collected'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time;
      case 'delivered':
        return Icons.inbox;
      case 'collected':
        return Icons.check_circle;
      case 'returned':
        return Icons.assignment_return;
      default:
        return Icons.local_shipping;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays == -1) {
      return 'Tomorrow';
    } else if (difference.inDays > 0 && difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 0 && difference.inDays > -7) {
      return 'In ${-difference.inDays} days';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showCollectionDialog(Delivery delivery) {
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Collection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter the name of the person collecting the package:'),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Collector Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                return;
              }
              
              Navigator.pop(context);
              
              final success = await Provider.of<DeliveryProvider>(context, listen: false)
                  .updateDeliveryStatus(
                    delivery.id,
                    'collected',
                    collectedBy: nameController.text.trim(),
                  );
                  
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Package marked as collected'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}