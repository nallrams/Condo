import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/facility_provider.dart';
import '../widgets/facility_card.dart';
import '../../../routes.dart' as app_routes;

class FacilityListScreen extends StatefulWidget {
  const FacilityListScreen({Key? key}) : super(key: key);

  @override
  _FacilityListScreenState createState() => _FacilityListScreenState();
}

class _FacilityListScreenState extends State<FacilityListScreen> {
  @override
  void initState() {
    super.initState();
    // Load facilities when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FacilityProvider>(context, listen: false).loadFacilities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Facilities',
      ),
      body: _buildBody(),
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
            onRetry: () => facilityProvider.loadFacilities(),
          );
        }

        if (facilityProvider.facilities.isEmpty) {
          return const EmptyStateWidget(
            message: 'No facilities available at the moment',
            icon: Icons.meeting_room,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: facilityProvider.facilities.length,
          itemBuilder: (context, index) {
            final facility = facilityProvider.facilities[index];
            return FacilityCard(
              facility: facility,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  app_routes.AppRoutes.facilityDetail,
                  arguments: {'facilityId': facility.id},
                );
              },
            );
          },
        );
      },
    );
  }
}
