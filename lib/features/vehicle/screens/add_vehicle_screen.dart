import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/vehicle_provider.dart';
import '../../../routes.dart' as app_routes;

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({Key? key}) : super(key: key);

  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _licensePlateController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _parkingSlotController = TextEditingController();
  
  bool _isPrimary = false;
  String _selectedType = 'car';
  
  final List<Map<String, dynamic>> _vehicleTypes = [
    {'value': 'car', 'label': 'Car', 'icon': Icons.directions_car},
    {'value': 'motorcycle', 'label': 'Motorcycle', 'icon': Icons.motorcycle},
    {'value': 'suv', 'label': 'SUV', 'icon': Icons.directions_car},
    {'value': 'truck', 'label': 'Truck', 'icon': Icons.local_shipping},
    {'value': 'van', 'label': 'Van', 'icon': Icons.airport_shuttle},
  ];
  
  @override
  void dispose() {
    _licensePlateController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _parkingSlotController.dispose();
    super.dispose();
  }
  
  Future<void> _saveVehicle() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
      
      final vehicle = await vehicleProvider.createVehicle(
        userId: authProvider.currentUser!.id,
        licensePlate: _licensePlateController.text.trim().toUpperCase(),
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        color: _colorController.text.trim(),
        type: _selectedType,
        isPrimary: _isPrimary,
        parkingSlot: _parkingSlotController.text.isEmpty 
            ? null 
            : _parkingSlotController.text.trim(),
      );
      
      if (vehicle != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, app_routes.AppRoutes.vehicleList);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Add Vehicle',
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProvider, child) {
        return LoadingOverlay(
          isLoading: vehicleProvider.isLoading,
          message: 'Adding vehicle...',
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _buildVehicleDetailsCard(),
                  const SizedBox(height: 24),
                  _buildAdditionalDetailsCard(),
                  
                  // Error message if any
                  if (vehicleProvider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          vehicleProvider.error!,
                          style: TextStyle(
                            color: Colors.red.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  
                  // Save Button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: vehicleProvider.isLoading ? null : _saveVehicle,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text('Add Vehicle'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Vehicle Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Register your vehicle to get access to the parking facilities. Your license plate will be recognized by the automated entry system.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVehicleDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // License Plate
            TextFormField(
              controller: _licensePlateController,
              decoration: const InputDecoration(
                labelText: 'License Plate *',
                prefixIcon: Icon(Icons.directions_car),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter license plate';
                }
                if (!Validators.isValidLicensePlate(value)) {
                  return 'Please enter a valid license plate';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Vehicle Type
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Vehicle Type *',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              value: _selectedType,
              items: _vehicleTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type['value'],
                  child: Row(
                    children: [
                      Icon(type['icon'], size: 16),
                      const SizedBox(width: 8),
                      Text(type['label']),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Make
            TextFormField(
              controller: _makeController,
              decoration: const InputDecoration(
                labelText: 'Make (Brand) *',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
                hintText: 'e.g. Toyota, Honda, Ford',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter vehicle make';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Model
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model *',
                prefixIcon: Icon(Icons.model_training),
                border: OutlineInputBorder(),
                hintText: 'e.g. Camry, Civic, F-150',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter vehicle model';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Color
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Color *',
                prefixIcon: Icon(Icons.color_lens),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter vehicle color';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAdditionalDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Parking Slot
            TextFormField(
              controller: _parkingSlotController,
              decoration: const InputDecoration(
                labelText: 'Parking Slot',
                prefixIcon: Icon(Icons.local_parking),
                border: OutlineInputBorder(),
                hintText: 'Optional',
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Is Primary Vehicle
            SwitchListTile(
              title: const Text('Set as Primary Vehicle'),
              subtitle: const Text('This will be your default vehicle'),
              value: _isPrimary,
              onChanged: (value) {
                setState(() {
                  _isPrimary = value;
                });
              },
              secondary: Icon(
                Icons.star,
                color: _isPrimary ? Colors.amber : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
