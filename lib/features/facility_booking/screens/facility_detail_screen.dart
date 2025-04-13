import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/utils/helpers.dart';
import '../providers/facility_provider.dart';
import '../../../routes.dart' as app_routes;

class FacilityDetailScreen extends StatefulWidget {
  final String facilityId;

  const FacilityDetailScreen({
    Key? key,
    required this.facilityId,
  }) : super(key: key);

  @override
  _FacilityDetailScreenState createState() => _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends State<FacilityDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load facility details when screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FacilityProvider>(context, listen: false)
          .getFacilityById(widget.facilityId);
    });
  }

  @override
  void dispose() {
    // Clear selected facility when leaving the screen
    Provider.of<FacilityProvider>(context, listen: false).clearSelectedFacility();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Facility Details',
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    return Consumer<FacilityProvider>(
      builder: (context, facilityProvider, child) {
        if (facilityProvider.isLoading) {
          return const LoadingIndicator();
        }

        if (facilityProvider.error != null) {
          return ErrorDisplayWidget(
            errorMessage: facilityProvider.error!,
            onRetry: () => facilityProvider.getFacilityById(widget.facilityId),
          );
        }

        final facility = facilityProvider.selectedFacility;
        if (facility == null) {
          return const EmptyStateWidget(
            message: 'Facility not found',
            icon: Icons.error_outline,
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Facility Image
              Stack(
                children: [
                  Image.network(
                    facility.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  // Hourly rate badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${Helpers.formatCurrency(facility.hourlyRate)}/hour',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Facility Details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and capacity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            facility.name,
                            style: const TextStyle(
                              fontSize: 24,
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
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.people,
                                size: 16,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Max ${facility.maxCapacity}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      facility.description,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Amenities
                    const Text(
                      'Amenities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: facility.amenities.map((amenity) {
                        return Chip(
                          label: Text(amenity),
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Rules
                    const Text(
                      'Rules',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: facility.rules.map((rule) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  rule,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Operating Hours
                    const Text(
                      'Operating Hours',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildOperatingHours(facility.operatingHours),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOperatingHours(Map<String, dynamic>? operatingHours) {
    if (operatingHours == null) {
      return const Text(
        'Operating hours not available',
        style: TextStyle(
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final List<Widget> hourWidgets = [];
    final daysOfWeek = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    for (final day in daysOfWeek) {
      final hours = operatingHours[day];
      if (hours != null) {
        final openTime = hours['open'];
        final closeTime = hours['close'];

        hourWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Helpers.capitalizeFirstLetter(day),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text('$openTime - $closeTime'),
              ],
            ),
          ),
        );
      }
    }

    return Column(children: hourWidgets);
  }

  Widget _buildBottomBar() {
    return Consumer<FacilityProvider>(
      builder: (context, facilityProvider, child) {
        final facility = facilityProvider.selectedFacility;
        if (facility == null) {
          return const SizedBox.shrink();
        }

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
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  app_routes.AppRoutes.bookingCalendar,
                  arguments: {
                    'facilityId': facility.id,
                    'facilityName': facility.name,
                  },
                );
              },
              child: const Text('Book Now'),
            ),
          ),
        );
      },
    );
  }
}
