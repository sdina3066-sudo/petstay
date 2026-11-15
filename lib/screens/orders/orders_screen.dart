import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../data/models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/sitter_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/order_card.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isSitter =
        context.watch<AuthProvider>().role == UserRole.penitip;
    final List<Booking> bookings = context.watch<BookingProvider>().bookings;
    final pets = context.watch<PetProvider>();
    final sitters = context.watch<SitterProvider>();
    if (bookings.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isSitter ? 'Permintaan Penitipan' : 'Pesanan Saya'),
        ),
        body: EmptyState(
          title: isSitter ? 'Belum ada permintaan' : 'Belum ada pesanan',
          message: isSitter
              ? 'Permintaan penitipan dari pemilik akan muncul di sini.'
              : 'Pesanan penitipan yang Anda buat akan muncul di sini.',
          icon: isSitter ? Icons.inbox_outlined : Icons.receipt_long_outlined,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isSitter ? 'Permintaan Penitipan' : 'Pesanan Saya'),
      ),
      body: Column(
        children: [
          if (isSitter)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tinjau permintaan, lalu perbarui status dan kirim laporan.',
                ),
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: bookings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                final Booking booking = bookings[index];
                final String petName =
                    pets.findById(booking.petId)?.name ?? 'Hewan';
                final String sitterName =
                    sitters.findById(booking.sitterId)?.name ?? 'Penitip';
                return OrderCard(
                  booking: booking,
                  petName: petName,
                  sitterName: sitterName,
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRoutes.orderDetail, arguments: booking.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
