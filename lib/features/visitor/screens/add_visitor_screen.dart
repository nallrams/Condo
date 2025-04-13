import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/utils/validators.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/visitor_provider.dart';
import '../../../routes.dart' as app_routes;

class AddVisitorScreen extends StatefulWidget {
  const AddVisitorScreen({Key? key}) : super(key: key);

  @override
  _AddVisitorScreenState createState() => _AddVisitorScreenState();
}

class _AddVisitorScreenState extends State<AddVisitorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _purposeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _selectedTime = TimeOfDay.fromDateTime(
    DateTime.now().add(const Duration(hours: 1))
  );
  
  @override
  void dispose() {
    _nameController.dispose();
    _purposeController.dispose();
    _phoneController.dispose();
    _vehiclePlateController.dispose();
    _idNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }
  
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }
  
  Future<void> _saveVisitor() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final visitorProvider = Provider.of<VisitorProvider>(context, listen: false);
      
      final visitor = await visitorProvider.createVisitor(
        userId: authProvider.currentUser!.id,
        name: _nameController.text.trim(),
        purpose: _purposeController.text.trim(),
        expectedArrivalTime: _selectedDate,
        vehiclePlate: _vehiclePlateController.text.isEmpty 
            ? null 
            : _vehiclePlateController.text.trim(),
        idNumber: _idNumberController.text.isEmpty 
            ? null 
            : _idNumberController.text.trim(),
        phone: _phoneController.text.isEmpty 
            ? null 
            : _phoneController.text.trim(),
        notes: _notesController.text.isEmpty 
            ? null 
            : _notesController.text.trim(),
      );
      
      if (visitor != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visitor added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, app_routes.AppRoutes.visitorManagement);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Add Visitor',
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    return Consumer<VisitorProvider>(
      builder: (context, visitorProvider, child) {
        return LoadingOverlay(
          isLoading: visitorProvider.isLoading,
          message: 'Adding visitor...',
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _buildVisitorDetailsCard(),
                  const SizedBox(height: 24),
                  _buildArrivalDetailsCard(),
                  const SizedBox(height: 24),
                  _buildAdditionalDetailsCard(),
                  
                  // Error message if any
                  if (visitorProvider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          visitorProvider.error!,
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
                        onPressed: visitorProvider.isLoading ? null : _saveVisitor,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text('Add Visitor'),
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
                  'Visitor Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Add the details of your expected visitor. They will be able to use the QR code you\'ll receive for easy check-in at the building entrance.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVisitorDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visitor Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Visitor Name *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter visitor name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Purpose
            TextFormField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: 'Purpose of Visit *',
                prefixIcon: Icon(Icons.subject),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter purpose of visit';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Phone
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
                hintText: 'Optional',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.isNotEmpty && !Validators.isValidPhone(value)) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildArrivalDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expected Arrival',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Date Picker
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date *',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Time Picker
            InkWell(
              onTap: () => _selectTime(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Time *',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _selectedTime.format(context),
                ),
              ),
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
            
            // Vehicle Plate
            TextFormField(
              controller: _vehiclePlateController,
              decoration: const InputDecoration(
                labelText: 'Vehicle License Plate',
                prefixIcon: Icon(Icons.directions_car),
                border: OutlineInputBorder(),
                hintText: 'If arriving by car',
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value != null && value.isNotEmpty && !Validators.isValidLicensePlate(value)) {
                  return 'Please enter a valid license plate';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // ID Number
            TextFormField(
              controller: _idNumberController,
              decoration: const InputDecoration(
                labelText: 'ID Number',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
                hintText: 'Optional',
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
                hintText: 'Any special instructions',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
