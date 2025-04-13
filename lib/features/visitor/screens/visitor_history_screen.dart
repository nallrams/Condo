import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/visitor_provider.dart';

class VisitorHistoryScreen extends StatefulWidget {
  const VisitorHistoryScreen({Key? key}) : super(key: key);

  @override
  _VisitorHistoryScreenState createState() => _VisitorHistoryScreenState();
}

class _VisitorHistoryScreenState extends State<VisitorHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load user's visitors if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final visitorProvider = Provider.of<VisitorProvider>(context, listen: false);
      if (visitorProvider.visitors.isEmpty) {
        final userId = Provider.of<AuthProvider>(context, listen: false).currentUser!.id;
        visitorProvider.loadUserVisitors(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Visitor History',
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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

        final historyVisitors = visitorProvider.historyVisitors;

        if (historyVisitors.isEmpty) {
          return const EmptyStateWidget(
            message: 'No visitor history found',
            icon: Icons.history,
          );
        }

        // Sort by date, most recent first
        historyVisitors.sort((a, b) {
          final aTime = a.departureTime ?? a.actualArrivalTime ?? a.expectedArrivalTime;
          final bTime = b.departureTime ?? b.actualArrivalTime ?? b.expectedArrivalTime;
          return bTime.compareTo(aTime);
        });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: historyVisitors.length,
          itemBuilder: (context, index) {
            final visitor = historyVisitors[index];
            return _buildHistoryVisitorCard(visitor);
          },
        );
      },
    );
  }

  Widget _buildHistoryVisitorCard(visitor) {
    final isDeparted = visitor.status == 'departed';
    final isCancelled = visitor.status == 'cancelled';
    
    // Choose the appropriate status color
    Color statusColor;
    if (isDeparted) {
      statusColor = Colors.green;
    } else if (isCancelled) {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.orange;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visitor name and status
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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _capitalizeStatus(visitor.status),
                    style: TextStyle(
                      color: statusColor,
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
            
            // Expected arrival
            Row(
              children: [
                const Icon(
                  Icons.schedule,
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
            
            if (visitor.actualArrivalTime != null) ...[
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
            
            if (visitor.departureTime != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.logout,
                    size: 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Departed: ${DateFormat('MMM dd, yyyy - h:mm a').format(visitor.departureTime!)}',
                    style: const TextStyle(
                      color: Colors.blue,
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
            
            if (visitor.notes != null && visitor.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.note,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Notes: ${visitor.notes}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            // Show duration if visitor both arrived and departed
            if (visitor.actualArrivalTime != null && visitor.departureTime != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.timelapse,
                    size: 16,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Duration: ${_formatDuration(visitor.departureTime!.difference(visitor.actualArrivalTime!))}',
                    style: const TextStyle(
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  String _capitalizeStatus(String status) {
    return status.substring(0, 1).toUpperCase() + status.substring(1);
  }
  
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours} hr ${duration.inMinutes.remainder(60)} min';
    } else {
      return '${duration.inMinutes} minutes';
    }
  }
}
