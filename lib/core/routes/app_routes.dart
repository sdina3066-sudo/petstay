import 'package:flutter/material.dart';

import '../../screens/booking/booking_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/main_shell.dart';
import '../../screens/orders/order_detail_screen.dart';
import '../../screens/sitter_detail/sitter_detail_screen.dart';
import '../../screens/splash/splash_screen.dart';

/// Nama rute untuk navigasi bernama PetStay.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String main = '/main';
  static const String sitterDetail = '/sitter-detail';
  static const String booking = '/booking';
  static const String orderDetail = '/order-detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );
      case login:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case main:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MainShell(),
        );
      case sitterDetail:
        final String? sitterId = settings.arguments is String
            ? settings.arguments! as String
            : null;
        if (sitterId == null) return _invalidArguments(settings);
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => SitterDetailScreen(sitterId: sitterId),
        );
      case booking:
        final String? bookingSitterId = settings.arguments is String
            ? settings.arguments! as String
            : null;
        if (bookingSitterId == null) return _invalidArguments(settings);
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BookingScreen(sitterId: bookingSitterId),
        );
      case orderDetail:
        final String? bookingId = settings.arguments is String
            ? settings.arguments! as String
            : null;
        if (bookingId == null) return _invalidArguments(settings);
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => OrderDetailScreen(bookingId: bookingId),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) =>
              const _RoutePlaceholder(title: 'Halaman tidak ditemukan'),
        );
    }
  }

  static Route<dynamic> _invalidArguments(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) =>
          const _RoutePlaceholder(title: 'Data halaman tidak valid'),
    );
  }
}

class _RoutePlaceholder extends StatelessWidget {
  const _RoutePlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
