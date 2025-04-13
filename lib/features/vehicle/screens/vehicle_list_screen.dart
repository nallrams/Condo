import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/vehicle_provider.dart';
import '../../../routes.dart' as app_routes;

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({Key? key}) : super(key: key);

  @override
  _VehicleListScreenState createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  @override
  void initState() {
    super.initState();
    // Load user's vehicles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<AuthProvider>(context, listen: false).currentUser!.id;
      Provider.of<VehicleProvider>(context, listen: false).loadUserVehicles(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'My Vehicles',
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, app_routes.AppRoutes.addVehicle);
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Vehicle',
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProvider, child) {
        if (vehicleProvider.isLoading) {
          return const LoadingIndicator();
        }

        if (vehicleProvider.error != null) {
          return ErrorDisplayWidget(
            errorMessage: vehicleProvider.error!,
            onRetry: () {
              final userId = Provider.of<AuthProvider>(context, listen: false).currentUser!.id;
              vehicleProvider.loadUserVehicles(userId);
            },
          );
        }

        final vehicles = vehicleProvider.vehicles;

        if (vehicles.isEmpty) {
          return Center(
            child: EmptyStateWidget(
              message: 'No vehicles registered',
              icon: Icons.directions_car,
              actionLabel: 'Add Vehicle',
              onAction: () {
                Navigator.pushNamed(context, app_routes.AppRoutes.addVehicle);
              },
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicles[index];
            return _buildVehicleCard(vehicle);
          },
        );
      },
    );
  }

  Widget _buildVehicleCard(vehicle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showVehicleOptions(vehicle),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Vehicle icon based on type
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    _getVehicleIcon(vehicle.type),
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Vehicle details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${vehicle.make} ${vehicle.model}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (vehicle.isPrimary)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Primary',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'License: ${vehicle.licensePlate}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Row(
                      children: [
                        Icon(
                          Icons.color_lens,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          vehicle.color,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.local_parking,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          vehicle.parkingSlot ?? 'N/A',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Chevron icon
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getVehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case 'motorcycle':
        return Icons.motorcycle;
      case 'truck':
        return Icons.local_shipping;
      case 'suv':
        return Icons.directions_car;
      case 'van':
        return Icons.airport_shuttle;
      default:
        return Icons.directions_car;
    }
  }
  
  void _showVehicleOptions(vehicle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${vehicle.make} ${vehicle.model}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'License: ${vehicle.licensePlate}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              
              // Actions
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Vehicle'),
                onTap: () {
                  Navigator.pop(context);
                  _editVehicle(vehicle);
                },
              ),
              
              if (!vehicle.isPrimary)
                ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text('Set as Primary'),
                  onTap: () {
                    Navigator.pop(context);
                    _setPrimaryVehicle(vehicle);
                  },
                ),
              
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Vehicle', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteVehicle(vehicle);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _editVehicle(vehicle) {
    // In a real app, navigate to edit screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Vehicle'),
        content: const Text('This feature is not implemented in this version.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _setPrimaryVehicle(vehicle) async {
    final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
    
    final success = await vehicleProvider.updateVehicle(
      vehicleId: vehicle.id,
      isPrimary: true,
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${vehicle.make} ${vehicle.model} set as primary vehicle'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  Future<void> _confirmDeleteVehicle(vehicle) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Are you sure you want to delete ${vehicle.make} ${vehicle.model}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
      
      final success = await vehicleProvider.deleteVehicle(vehicle.id);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${vehicle.make} ${vehicle.model} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
