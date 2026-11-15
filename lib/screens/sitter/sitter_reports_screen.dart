import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../data/models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../providers/pet_provider.dart';
import '../../widgets/empty_state.dart';

/// Daftar aktivitas laporan yang dibuat penitip untuk pemilik hewan.
class SitterReportsScreen extends StatelessWidget {
  const SitterReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Booking> bookings = context
        .watch<BookingProvider>()
        .bookings
        .where((Booking booking) => booking.dailyReports.isNotEmpty)
        .toList();
    final pets = context.watch<PetProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Harian')),
      body: bookings.isEmpty
          ? const EmptyState(
              title: 'Belum ada laporan',
              message: 'Buka permintaan penitipan untuk mengirim kabar harian kepada pemilik.',
              icon: Icons.feed_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: bookings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                final Booking booking = bookings[index];
                final String petName =
                    pets.findById(booking.petId)?.name ?? 'Hewan';
                final String latestReport = booking.dailyReports.last.message;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      child: const Icon(Icons.pets),
                    ),
                    title: Text('Laporan $petName'),
                    subtitle: Text(
                      latestReport,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.orderDetail, arguments: booking.id),
                  ),
                );
              },
            ),
    );
  }
}
