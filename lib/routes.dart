import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/facility_booking/screens/facility_list_screen.dart';
import 'features/facility_booking/screens/facility_detail_screen.dart';
import 'features/facility_booking/screens/booking_calendar_screen.dart';
import 'features/facility_booking/screens/booking_confirmation_screen.dart';
import 'features/payment/screens/payment_screen.dart';
import 'features/payment/screens/payment_history_screen.dart';
import 'features/invoice/screens/invoice_list_screen.dart';
import 'features/invoice/screens/invoice_detail_screen.dart';
import 'features/visitor/screens/visitor_management_screen.dart';
import 'features/visitor/screens/add_visitor_screen.dart';
import 'features/visitor/screens/visitor_history_screen.dart';
import 'features/vehicle/screens/vehicle_list_screen.dart';
import 'features/vehicle/screens/add_vehicle_screen.dart';
import 'features/delivery/screens/delivery_tracker_screen.dart';
import 'features/delivery/screens/add_delivery_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/edit_profile_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String facilityList = '/facilities';
  static const String facilityDetail = '/facility-detail';
  static const String bookingCalendar = '/booking-calendar';
  static const String bookingConfirmation = '/booking-confirmation';
  static const String payment = '/payment';
  static const String paymentHistory = '/payment-history';
  static const String invoiceList = '/invoices';
  static const String invoiceDetail = '/invoice-detail';
  static const String visitorManagement = '/visitor-management';
  static const String addVisitor = '/add-visitor';
  static const String visitorHistory = '/visitor-history';
  static const String vehicleList = '/vehicles';
  static const String addVehicle = '/add-vehicle';
  static const String deliveryTracker = '/delivery-tracker';
  static const String addDelivery = '/add-delivery';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case facilityList:
        return MaterialPageRoute(builder: (_) => const FacilityListScreen());
      case facilityDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => FacilityDetailScreen(facilityId: args['facilityId']),
        );
      case bookingCalendar:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BookingCalendarScreen(
            facilityId: args['facilityId'],
            facilityName: args['facilityName'],
          ),
        );
      case bookingConfirmation:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(bookingId: args['bookingId']),
        );
      case payment:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PaymentScreen(
            amount: args?['amount'],
            purpose: args?['purpose'],
            referenceId: args?['referenceId'],
          ),
        );
      case paymentHistory:
        return MaterialPageRoute(builder: (_) => const PaymentHistoryScreen());
      case invoiceList:
        return MaterialPageRoute(builder: (_) => const InvoiceListScreen());
      case invoiceDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => InvoiceDetailScreen(invoiceId: args['invoiceId']),
        );
      case visitorManagement:
        return MaterialPageRoute(builder: (_) => const VisitorManagementScreen());
      case addVisitor:
        return MaterialPageRoute(builder: (_) => const AddVisitorScreen());
      case visitorHistory:
        return MaterialPageRoute(builder: (_) => const VisitorHistoryScreen());
      case vehicleList:
        return MaterialPageRoute(builder: (_) => const VehicleListScreen());
      case addVehicle:
        return MaterialPageRoute(builder: (_) => const AddVehicleScreen());
      case deliveryTracker:
        return MaterialPageRoute(builder: (_) => const DeliveryTrackerScreen());
      case addDelivery:
        return MaterialPageRoute(builder: (_) => const AddDeliveryScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
