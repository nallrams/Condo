import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/facility_provider.dart';
import '../providers/booking_provider.dart';
import '../widgets/time_slot_picker.dart';
import '../../../routes.dart' as app_routes;

class BookingCalendarScreen extends StatefulWidget {
  final String facilityId;
  final String facilityName;

  const BookingCalendarScreen({
    Key? key,
    required this.facilityId,
    required this.facilityName,
  }) : super(key: key);

  @override
  _BookingCalendarScreenState createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends State<BookingCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<String, String>? _selectedTimeSlot;
  final _guestController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load facility details and availability for today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final facilityProvider = Provider.of<FacilityProvider>(context, listen: false);
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      
      // Get facility details
      facilityProvider.getFacilityById(widget.facilityId);
      
      // Load availability for today
      bookingProvider.loadFacilityAvailability(widget.facilityId, _selectedDay);
    });
  }

  @override
  void dispose() {
    _guestController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedTimeSlot = null;
      });
      
      // Load availability for the selected day
      Provider.of<BookingProvider>(context, listen: false)
          .loadFacilityAvailability(widget.facilityId, selectedDay);
    }
  }

  void _onTimeSlotSelected(Map<String, String> timeSlot) {
    setState(() {
      _selectedTimeSlot = timeSlot;
    });
  }

  Future<void> _createBooking() async {
    if (_formKey.currentState!.validate() && _selectedTimeSlot != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final facilityProvider = Provider.of<FacilityProvider>(context, listen: false);
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      
      // Set booking details
      bookingProvider.setSelectedDate(_selectedDay);
      bookingProvider.setSelectedTimeSlot(_selectedTimeSlot!['startTime']!, _selectedTimeSlot!['endTime']!);
      bookingProvider.setGuestCount(int.parse(_guestController.text));
      bookingProvider.setNotes(_notesController.text);
      
      // Create booking
      final facility = facilityProvider.selectedFacility!;
      final userId = authProvider.currentUser!.id;
      final booking = await bookingProvider.createBooking(userId, facility);
      
      if (booking != null && mounted) {
        Navigator.pushNamed(
          context,
          app_routes.AppRoutes.bookingConfirmation,
          arguments: {'bookingId': booking.id},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Book ${widget.facilityName}',
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Section
            _buildCalendar(),
            
            // Time Slots Section
            _buildTimeSlots(),
            
            // Guest Count & Notes Section
            _buildGuestAndNotes(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Select Date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 60)),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Consumer2<FacilityProvider, BookingProvider>(
      builder: (context, facilityProvider, bookingProvider, child) {
        if (facilityProvider.isLoading || bookingProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (facilityProvider.error != null) {
          return ErrorDisplayWidget(
            errorMessage: facilityProvider.error!,
            onRetry: () => facilityProvider.getFacilityById(widget.facilityId),
          );
        }

        if (bookingProvider.error != null) {
          return ErrorDisplayWidget(
            errorMessage: bookingProvider.error!,
            onRetry: () => bookingProvider.loadFacilityAvailability(
              widget.facilityId, 
              _selectedDay,
            ),
          );
        }

        final facility = facilityProvider.selectedFacility;
        if (facility == null) {
          return const EmptyStateWidget(
            message: 'Facility not found',
            icon: Icons.error_outline,
          );
        }

        final availableTimeSlots = bookingProvider.getAvailableTimeSlots(facility, _selectedDay);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TimeSlotPicker(
            timeSlots: availableTimeSlots,
            selectedTimeSlot: _selectedTimeSlot,
            onTimeSlotSelected: _onTimeSlotSelected,
          ),
        );
      },
    );
  }

  Widget _buildGuestAndNotes() {
    return Card(
      margin: const EdgeInsets.all(16.0),
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
            
            // Guest Count
            TextFormField(
              controller: _guestController,
              decoration: const InputDecoration(
                labelText: 'Number of Guests',
                prefixIcon: Icon(Icons.people),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter number of guests';
                }
                final number = int.tryParse(value);
                if (number == null || number < 1) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Special Requests / Notes',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Date: ${DateFormat('MMM dd, yyyy').format(_selectedDay)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_selectedTimeSlot != null)
                        Text(
                          'Time: ${_selectedTimeSlot!['startTime']} - ${_selectedTimeSlot!['endTime']}',
                        ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectedTimeSlot != null && !bookingProvider.isLoading
                      ? _createBooking
                      : null,
                  child: bookingProvider.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Proceed'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
