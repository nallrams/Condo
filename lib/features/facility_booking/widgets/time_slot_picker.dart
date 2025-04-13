import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TimeSlotPicker extends StatelessWidget {
  final List<Map<String, String>> timeSlots;
  final Map<String, String>? selectedTimeSlot;
  final Function(Map<String, String>) onTimeSlotSelected;

  const TimeSlotPicker({
    Key? key,
    required this.timeSlots,
    this.selectedTimeSlot,
    required this.onTimeSlotSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (timeSlots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.event_busy,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'No available time slots for this date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please select a different date',
                style: TextStyle(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Available Time Slots',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GridView.builder(
            padding: const EdgeInsets.all(16.0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: timeSlots.length,
            itemBuilder: (context, index) {
              final timeSlot = timeSlots[index];
              final isSelected = selectedTimeSlot != null &&
                  selectedTimeSlot!['startTime'] == timeSlot['startTime'] &&
                  selectedTimeSlot!['endTime'] == timeSlot['endTime'];

              return _buildTimeSlotItem(context, timeSlot, isSelected);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotItem(
    BuildContext context,
    Map<String, String> timeSlot,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () => onTimeSlotSelected(timeSlot),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${timeSlot['startTime']} - ${timeSlot['endTime']}',
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryColor : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
