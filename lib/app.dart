import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/pet_stay_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/pet_provider.dart';
import 'providers/sitter_provider.dart';

/// Menyiapkan repository, seluruh state provider, dan konfigurasi aplikasi.
class PetStayApp extends StatelessWidget {
  const PetStayApp({super.key});

  @override
  Widget build(BuildContext context) {
    const PetStayRepository repository = PetStayRepository();
    return MultiProvider(
      providers: [
        Provider<PetStayRepository>.value(value: repository),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<SitterProvider>(
          create: (_) => SitterProvider(repository),
        ),
        ChangeNotifierProvider<PetProvider>(
          create: (_) => PetProvider(repository),
        ),
        ChangeNotifierProvider<NavigationProvider>(
          create: (_) => NavigationProvider(),
        ),
        ChangeNotifierProxyProvider<SitterProvider, BookingProvider>(
          create: (_) => BookingProvider(repository),
          update: (_, SitterProvider sitters, BookingProvider? bookings) =>
              bookings!..connectSitterProvider(sitters),
        ),
      ],
      child: MaterialApp(
        title: 'PetStay',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('id', 'ID'),
        supportedLocales: const [Locale('id', 'ID')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
