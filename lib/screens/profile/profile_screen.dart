import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/exit_confirmation.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/sitter_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    if (!await showExitConfirmation(context) || !context.mounted) return;
    context.read<AuthProvider>().logout();
    context.read<NavigationProvider>().selectTab(0);
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    final SitterProvider sitters = context.watch<SitterProvider>();
    final bool isSitter = auth.role == UserRole.penitip;
    final String displayName = auth.email.isEmpty
        ? 'Pengguna PetStay'
        : auth.email.split('@').first;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : 'P',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 3),
                        Text(auth.email),
                        const SizedBox(height: 3),
                        Text('Peran: ${auth.role.label}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: Icon(
                isSitter ? Icons.home_work_outlined : Icons.pets_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                isSitter ? 'Mode kerja penitip' : 'Mode pemilik hewan',
              ),
              subtitle: Text(
                isSitter
                    ? 'Kelola permintaan, ubah status penitipan, dan kirim laporan harian kepada pemilik.'
                    : 'Cari penitip, buat pesanan, kelola profil hewan, dan beri ulasan setelah penitipan.',
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: SwitchListTile(
              title: const Text('Simulasi Offline'),
              subtitle: Text(
                sitters.isOffline
                    ? 'Koneksi disimulasikan terputus di Beranda.'
                    : 'Daftar penitip dapat dimuat seperti biasa.',
              ),
              secondary: Icon(sitters.isOffline ? Icons.wifi_off : Icons.wifi),
              value: sitters.isOffline,
              onChanged: (bool value) async {
                await context.read<SitterProvider>().setOffline(value);
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Tentang PetStay'),
              subtitle: Text(
                'Demo aplikasi penitipan hewan dengan data lokal.',
              ),
            ),
          ),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
