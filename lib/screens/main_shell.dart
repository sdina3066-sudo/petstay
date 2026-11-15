import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/navigation/exit_confirmation.dart';
import '../core/routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import 'home/home_screen.dart';
import 'orders/orders_screen.dart';
import 'pets/my_pets_screen.dart';
import 'profile/profile_screen.dart';
import 'sitter/sitter_dashboard_screen.dart';
import 'sitter/sitter_reports_screen.dart';

/// Shell tab utama memakai IndexedStack agar state setiap tab tetap terjaga.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  bool _isConfirmingExit = false;

  Future<void> _confirmExit() async {
    if (_isConfirmingExit) return;
    _isConfirmingExit = true;
    final bool confirmed = await showExitConfirmation(context);
    _isConfirmingExit = false;
    if (!mounted || !confirmed) return;
    context.read<AuthProvider>().logout();
    context.read<NavigationProvider>().selectTab(0);
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isSitter =
        context.watch<AuthProvider>().role == UserRole.penitip;
    final NavigationProvider navigation = context.watch<NavigationProvider>();
    final List<Widget> pages = isSitter
        ? const [
            SitterDashboardScreen(),
            OrdersScreen(),
            SitterReportsScreen(),
            ProfileScreen(),
          ]
        : const [HomeScreen(), OrdersScreen(), MyPetsScreen(), ProfileScreen()];
    final List<NavigationDestination> destinations = isSitter
        ? const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Ringkasan',
            ),
            NavigationDestination(
              icon: Icon(Icons.inbox_outlined),
              selectedIcon: Icon(Icons.inbox),
              label: 'Permintaan',
            ),
            NavigationDestination(
              icon: Icon(Icons.feed_outlined),
              selectedIcon: Icon(Icons.feed),
              label: 'Laporan',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ]
        : const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Pesanan',
            ),
            NavigationDestination(
              icon: Icon(Icons.pets_outlined),
              selectedIcon: Icon(Icons.pets),
              label: 'Hewan Saya',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ];
    final int selectedIndex = navigation.selectedIndex.clamp(0, 3);

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(index: selectedIndex, children: pages),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: navigation.selectTab,
          destinations: destinations,
        ),
      ),
    );
  }
}
