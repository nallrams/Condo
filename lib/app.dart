import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/theme/app_theme.dart';
import 'routes.dart' as app_routes;
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

class CondoManagementApp extends StatelessWidget {
  const CondoManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return MaterialApp(
          title: 'Condo Management',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          initialRoute: authProvider.isAuthenticated ? app_routes.AppRoutes.dashboard : app_routes.AppRoutes.login,
          routes: {
            app_routes.AppRoutes.login: (context) => const LoginScreen(),
            app_routes.AppRoutes.dashboard: (context) => const DashboardScreen(),
          },
          onGenerateRoute: app_routes.AppRoutes.generateRoute,
        );
      },
    );
  }
}
