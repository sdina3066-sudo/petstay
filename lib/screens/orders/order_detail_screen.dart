import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/sitter_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({required this.bookingId, super.key});

  final String bookingId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final GlobalKey<FormState> _reviewFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _reportFormKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _reportController = TextEditingController();
  double _rating = 0;
  static final DateFormat _dateFormat = DateFormat('d MMMM y, HH:mm', 'id_ID');

  @override
  void dispose() {
    _commentController.dispose();
    _reportController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final BookingProvider provider = context.watch<BookingProvider>();
    final bool isSitter =
        context.watch<AuthProvider>().role == UserRole.penitip;
    final Booking? booking = provider.findById(widget.bookingId);
    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pesanan')),
        body: const Center(child: Text('Pesanan tidak ditemukan.')),
      );
    }
    final String petName =
        context.watch<PetProvider>().findById(booking.petId)?.name ?? 'Hewan';
    final String sitterName =
        context.watch<SitterProvider>().findById(booking.sitterId)?.name ??
        'Penitip';

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$petName bersama $sitterName',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('Status: ${booking.status.label}'),
                  if (booking.notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Catatan: ${booking.notes}'),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Laporan harian',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  if (booking.dailyReports.isEmpty)
                    Text(
                      isSitter
                          ? 'Belum ada laporan. Kirim kabar terbaru untuk pemilik.'
                          : 'Belum ada laporan harian dari penitip.',
                    )
                  else
                    ...booking.dailyReports.map(
                      (DailyReport report) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                Container(
                                  width: 2,
                                  height: 48,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(report.message),
                                  const SizedBox(height: 4),
                                  Text(
                                    _dateFormat.format(report.date),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (isSitter && booking.status != BookingStatus.selesai) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final String? error = context
                              .read<BookingProvider>()
                              .updateStatus(booking.id);
                          if (error != null) _showMessage(error);
                        },
                        icon: const Icon(Icons.autorenew),
                        label: Text(
                          'Ubah Status ke ${BookingStatus.values[booking.status.index + 1].label}',
                        ),
                      ),
                    ),
                  ],
                  if (isSitter &&
                      (booking.status == BookingStatus.diterima ||
                          booking.status == BookingStatus.sedangDititip)) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Kirim laporan kepada pemilik',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Form(
                      key: _reportFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _reportController,
                            minLines: 2,
                            maxLines: 4,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Kabar hewan hari ini',
                              hintText: 'Contoh: Mimi sudah makan dan bermain',
                              alignLabelWithHint: true,
                            ),
                            validator: (String? value) =>
                                value == null || value.trim().isEmpty
                                ? 'Laporan tidak boleh kosong.'
                                : null,
                          ),
                          const SizedBox(height: 10),
                          FilledButton.icon(
                            onPressed: () {
                              if (!_reportFormKey.currentState!.validate()) {
                                return;
                              }
                              final String? error = context
                                  .read<BookingProvider>()
                                  .addDailyReport(
                                    booking.id,
                                    _reportController.text,
                                  );
                              if (error != null) {
                                _showMessage(error);
                              } else {
                                _reportController.clear();
                                _showMessage(
                                  'Laporan harian berhasil dikirim.',
                                );
                              }
                            },
                            icon: const Icon(Icons.send_outlined),
                            label: const Text('Kirim Laporan'),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (!isSitter && booking.status == BookingStatus.selesai) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Beri ulasan',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (booking.hasReview)
                      const Text(
                        'Terima kasih, ulasan untuk pesanan ini sudah dikirim.',
                      )
                    else
                      Form(
                        key: _reviewFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pilih rating bintang'),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 2,
                              children: List<Widget>.generate(5, (int index) {
                                final int star = index + 1;
                                return IconButton(
                                  tooltip: 'Beri $star bintang',
                                  onPressed: () =>
                                      setState(() => _rating = star.toDouble()),
                                  icon: Icon(
                                    star <= _rating
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary,
                                  ),
                                );
                              }),
                            ),
                            if (_rating == 0)
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Text(
                                  'Rating wajib dipilih.',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _commentController,
                              minLines: 3,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                labelText: 'Komentar ulasan',
                                alignLabelWithHint: true,
                              ),
                              validator: (String? value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'Komentar tidak boleh kosong.'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () {
                                  if (_rating == 0) {
                                    setState(() {});
                                    return;
                                  }
                                  if (!_reviewFormKey.currentState!
                                      .validate()) {
                                    return;
                                  }
                                  final String? error = context
                                      .read<BookingProvider>()
                                      .addReview(
                                        bookingId: booking.id,
                                        rating: _rating,
                                        comment: _commentController.text,
                                        ownerName: context
                                            .read<AuthProvider>()
                                            .email
                                            .split('@')
                                            .first,
                                      );
                                  if (error != null) {
                                    _showMessage(error);
                                  } else {
                                    _commentController.clear();
                                  }
                                },
                                child: const Text('Kirim Ulasan'),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
