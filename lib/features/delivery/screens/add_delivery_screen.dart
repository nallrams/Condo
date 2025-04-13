import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../providers/delivery_provider.dart';
import '../../../core/utils/validators.dart';

class AddDeliveryScreen extends StatefulWidget {
  const AddDeliveryScreen({Key? key}) : super(key: key);

  @override
  State<AddDeliveryScreen> createState() => _AddDeliveryScreenState();
}

class _AddDeliveryScreenState extends State<AddDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _trackingNumberController = TextEditingController();
  final TextEditingController _courierNameController = TextEditingController();
  final TextEditingController _expectedDateController = TextEditingController();
  final TextEditingController _packageDescriptionController = TextEditingController();
  final TextEditingController _senderInfoController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  DateTime? _selectedDate;
  String _packageSize = 'medium';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 3));
    _expectedDateController.text = DateFormat('MMM dd, yyyy').format(_selectedDate!);
  }

  @override
  void dispose() {
    _trackingNumberController.dispose();
    _courierNameController.dispose();
    _expectedDateController.dispose();
    _packageDescriptionController.dispose();
    _senderInfoController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _expectedDateController.text = DateFormat('MMM dd, yyyy').format(picked);
      });
    }
  }

  Future<void> _saveDelivery() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final deliveryProvider = Provider.of<DeliveryProvider>(context, listen: false);
      final delivery = await deliveryProvider.createDelivery(
        userId: '1', // In a real app, get from auth provider
        trackingNumber: _trackingNumberController.text,
        courierName: _courierNameController.text,
        expectedDeliveryDate: _selectedDate!,
        packageSize: _packageSize,
        packageDescription: _packageDescriptionController.text.isEmpty 
            ? null 
            : _packageDescriptionController.text,
        senderInfo: _senderInfoController.text.isEmpty 
            ? null 
            : _senderInfoController.text,
        notes: _notesController.text.isEmpty 
            ? null 
            : _notesController.text,
      );

      if (delivery != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery tracking added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(deliveryProvider.error ?? 'Failed to add delivery tracking'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Delivery'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Package Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Tracking Number
              TextFormField(
                controller: _trackingNumberController,
                decoration: const InputDecoration(
                  labelText: 'Tracking Number *',
                  prefixIcon: Icon(Icons.numbers),
                  hintText: 'Enter the tracking number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tracking number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Courier Name
              TextFormField(
                controller: _courierNameController,
                decoration: const InputDecoration(
                  labelText: 'Courier/Service Provider *',
                  prefixIcon: Icon(Icons.local_shipping),
                  hintText: 'Enter the courier name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Courier name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Expected Delivery Date
              TextFormField(
                controller: _expectedDateController,
                decoration: const InputDecoration(
                  labelText: 'Expected Delivery Date *',
                  prefixIcon: Icon(Icons.event),
                  hintText: 'Select expected delivery date',
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Expected delivery date is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Package Size
              Text(
                'Package Size',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildSizeOption('Small', 'small'),
                  const SizedBox(width: 12),
                  _buildSizeOption('Medium', 'medium'),
                  const SizedBox(width: 12),
                  _buildSizeOption('Large', 'large'),
                ],
              ),
              const SizedBox(height: 24),
              
              // Package Description
              TextFormField(
                controller: _packageDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Package Description (Optional)',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                  hintText: 'What is in the package?',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              // Sender Info
              TextFormField(
                controller: _senderInfoController,
                decoration: const InputDecoration(
                  labelText: 'Sender Info (Optional)',
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: 'Who sent the package?',
                ),
              ),
              const SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  prefixIcon: Icon(Icons.note_outlined),
                  hintText: 'Any special instructions?',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              
              // Submit Button
              _isLoading
                  ? const Center(child: LoadingIndicator())
                  : ElevatedButton(
                      onPressed: _saveDelivery,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Add Delivery Tracking'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeOption(String label, String value) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _packageSize = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _packageSize == value
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _packageSize == value
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: _packageSize == value ? FontWeight.bold : FontWeight.normal,
                color: _packageSize == value
                    ? Theme.of(context).primaryColor
                    : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}