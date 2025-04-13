import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/utils/helpers.dart';
import '../providers/booking_provider.dart';
import '../providers/facility_provider.dart';
import '../../../routes.dart' as app_routes;

class BookingConfirmationScreen extends StatefulWidget {
  final String bookingId;

  const BookingConfirmationScreen({
    Key? key,
    required this.bookingId,
  }) : super(key: key);

  @override
  _BookingConfirmationScreenState createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    // Load booking details when screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      bookingProvider.getBookingById(widget.bookingId).then((_) {
        // Once booking is loaded, get facility details
        final booking = bookingProvider.selectedBooking;
        if (booking != null) {
          Provider.of<FacilityProvider>(context, listen: false)
              .getFacilityById(booking.facilityId);
        }
      });
    });
  }

  @override
  void dispose() {
    // Clear selected booking and facility when leaving the screen
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final facilityProvider = Provider.of<FacilityProvider>(context, listen: false);
    
    bookingProvider.clearSelectedBooking();
    facilityProvider.clearSelectedFacility();
    super.dispose();
  }

  void _makePayment() {
    final booking = Provider.of<BookingProvider>(context, listen: false).selectedBooking;
    if (booking != null) {
      Navigator.pushNamed(
        context,
        app_routes.AppRoutes.payment,
        arguments: {
          'amount': booking.totalAmount,
          'purpose': 'Facility Booking',
          'referenceId': booking.id,
        },
      );
    }
  }

  Future<void> _cancelBooking() async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
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
    
    if (confirm == true) {
      final success = await bookingProvider.cancelBooking(widget.bookingId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Booking Details',
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    return Consumer2<BookingProvider, FacilityProvider>(
      builder: (context, bookingProvider, facilityProvider, child) {
        if (bookingProvider.isLoading || facilityProvider.isLoading) {
          return const LoadingIndicator();
        }

        if (bookingProvider.error != null) {
          return ErrorDisplayWidget(
            errorMessage: bookingProvider.error!,
            onRetry: () => bookingProvider.getBookingById(widget.bookingId),
          );
        }

        final booking = bookingProvider.selectedBooking;
        if (booking == null) {
          return const EmptyStateWidget(
            message: 'Booking not found',
            icon: Icons.error_outline,
          );
        }

        final facility = facilityProvider.selectedFacility;
        if (facility == null) {
          return const EmptyStateWidget(
            message: 'Facility information not available',
            icon: Icons.error_outline,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Bar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Helpers.getStatusColor(booking.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Helpers.getStatusColor(booking.status),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      booking.status == 'cancelled'
                          ? Icons.cancel
                          : booking.status == 'confirmed'
                              ? Icons.check_circle
                              : Icons.pending,
                      color: Helpers.getStatusColor(booking.status),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Status: ${Helpers.getPrettyStatus(booking.status)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Helpers.getStatusColor(booking.status),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Booking Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Facility Image and Name
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              facility.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  facility.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Booking #${booking.id.substring(0, 8)}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 32),

                      // Date and Time
                      _buildInfoRow(
                        icon: Icons.calendar_today,
                        title: 'Date',
                        value: DateFormat('EEEE, MMMM d, yyyy').format(booking.startTime),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.access_time,
                        title: 'Time',
                        value: '${DateFormat('h:mm a').format(booking.startTime)} - '
                            '${DateFormat('h:mm a').format(booking.endTime)}',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.timelapse,
                        title: 'Duration',
                        value: '${booking.durationInHours} hour${booking.durationInHours > 1 ? 's' : ''}',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.people,
                        title: 'Guests',
                        value: '${booking.numberOfGuests ?? 1} person${(booking.numberOfGuests ?? 1) > 1 ? 's' : ''}',
                      ),

                      if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.note,
                          title: 'Notes',
                          value: booking.notes!,
                        ),
                      ],

                      const Divider(height: 32),

                      // Payment Information
                      _buildInfoRow(
                        icon: Icons.attach_money,
                        title: 'Amount',
                        value: Helpers.formatCurrency(booking.totalAmount),
                        valueStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.payment,
                        title: 'Payment Status',
                        value: booking.paymentId != null ? 'Paid' : 'Pending',
                        valueColor: booking.paymentId != null ? Colors.green : Colors.orange,
                      ),

                      if (booking.paymentId != null) ...[
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.receipt,
                          title: 'Transaction ID',
                          value: booking.paymentId!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Rules Reminder
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Facility Rules',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...facility.rules.map((rule) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(rule),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    TextStyle? valueStyle,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: valueStyle ??
                    TextStyle(
                      fontSize: 16,
                      color: valueColor,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        final booking = bookingProvider.selectedBooking;
        if (booking == null) {
          return const SizedBox.shrink();
        }

        // Don't show actions for cancelled or completed bookings
        if (booking.status == 'cancelled' || booking.status == 'completed') {
          return Container(
            padding: const EdgeInsets.all(16.0),
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
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Facilities'),
              ),
            ),
          );
        }

        // Show payment button for pending bookings without payment
        if (booking.paymentId == null) {
          return Container(
            padding: const EdgeInsets.all(16.0),
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
                    child: OutlinedButton(
                      onPressed: !bookingProvider.isLoading ? _cancelBooking : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: bookingProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                              ),
                            )
                          : const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _makePayment,
                      child: const Text('Pay Now'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Show cancel button for confirmed bookings
        return Container(
          padding: const EdgeInsets.all(16.0),
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
            child: ElevatedButton(
              onPressed: !bookingProvider.isLoading ? _cancelBooking : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: bookingProvider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Cancel Booking'),
            ),
          ),
        );
      },
    );
  }
}
