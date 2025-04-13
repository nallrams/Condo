import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/user_provider.dart';
import 'features/facility_booking/providers/facility_provider.dart';
import 'features/facility_booking/providers/booking_provider.dart';
import 'features/payment/providers/payment_provider.dart';
import 'features/invoice/providers/invoice_provider.dart';
import 'features/visitor/providers/visitor_provider.dart';
import 'features/vehicle/providers/vehicle_provider.dart';
import 'features/delivery/providers/delivery_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/dashboard/providers/dashboard_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FacilityProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => VisitorProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => DeliveryProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: const CondoManagementApp(),
    ),
  );
}
