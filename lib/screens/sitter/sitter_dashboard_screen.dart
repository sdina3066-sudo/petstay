import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../data/models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/sitter_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/order_card.dart';

/// Beranda khusus penitip: ringkasan pekerjaan dan permintaan terbaru.
class SitterDashboardScreen extends StatelessWidget {
  const SitterDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Booking> bookings = context.watch<BookingProvider>().bookings;
    final pending = bookings
        .where((Booking booking) => booking.status == BookingStatus.menunggu)
        .length;
    final active = bookings
        .where(
          (Booking booking) =>
              booking.status == BookingStatus.diterima ||
              booking.status == BookingStatus.sedangDititip,
        )
        .length;
    final reports = bookings.fold<int>(
      0,
      (int count, Booking booking) => count + booking.dailyReports.length,
    );
    final pets = context.watch<PetProvider>();
    final sitters = context.watch<SitterProvider>();
    final List<Booking> recent = bookings.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Penitip'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.home_work_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text(
            'Halo, Penitip!',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text('Kelola permintaan dan kabari pemilik tentang hewan.'),
          const SizedBox(height: 18),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mode demo penitip: pesanan yang tampil menggunakan data dummy.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double itemWidth = (constraints.maxWidth - 24) / 3;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _SummaryTile(
                    width: itemWidth,
                    icon: Icons.mark_email_unread_outlined,
                    label: 'Menunggu',
                    value: '$pending',
                  ),
                  _SummaryTile(
                    width: itemWidth,
                    icon: Icons.pets_outlined,
                    label: 'Ditangani',
                    value: '$active',
                  ),
                  _SummaryTile(
                    width: itemWidth,
                    icon: Icons.feed_outlined,
                    label: 'Laporan',
                    value: '$reports',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Permintaan terbaru',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.read<NavigationProvider>().selectTab(1),
                child: const Text('Lihat semua'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (recent.isEmpty)
            const EmptyState(
              title: 'Belum ada permintaan',
              message: 'Permintaan penitipan baru akan muncul di sini.',
              icon: Icons.inbox_outlined,
            )
          else
            ...recent.map((Booking booking) {
              final String petName =
                  pets.findById(booking.petId)?.name ?? 'Hewan';
              final String sitterName =
                  sitters.findById(booking.sitterId)?.name ?? 'Anda';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OrderCard(
                  booking: booking,
                  petName: petName,
                  sitterName: sitterName,
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRoutes.orderDetail, arguments: booking.id),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(height: 10),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
