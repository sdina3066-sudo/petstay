import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../data/models/review.dart';
import '../../data/models/sitter.dart';
import '../../providers/booking_provider.dart';
import '../../providers/sitter_provider.dart';

class SitterDetailScreen extends StatelessWidget {
  const SitterDetailScreen({required this.sitterId, super.key});

  final String sitterId;

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  static final DateFormat _dateFormat = DateFormat('d MMMM y', 'id_ID');

  @override
  Widget build(BuildContext context) {
    final Sitter? sitter = context.watch<SitterProvider>().findById(sitterId);
    if (sitter == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Penitip')),
        body: const Center(child: Text('Data penitip tidak ditemukan.')),
      );
    }
    final List<Review> reviews = context
        .watch<BookingProvider>()
        .reviews
        .where((Review review) => review.sitterId == sitter.id)
        .toList();
    final String initials = sitter.name
        .split(' ')
        .take(2)
        .map((String part) => part[0])
        .join()
        .toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Penitip')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          child: Text(
                            initials,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          sitter.name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 5),
                        Text(sitter.location),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _DetailMetric(
                              icon: Icons.star_rounded,
                              label:
                                  '${sitter.rating.toStringAsFixed(1)} (${sitter.reviewCount} ulasan)',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _DetailMetric(
                              icon: Icons.payments_outlined,
                              label:
                                  '${_currency.format(sitter.pricePerDay)} / hari',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Tentang penitip',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(sitter.bio),
                  const SizedBox(height: 20),
                  Text(
                    'Hewan yang diterima',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: sitter.acceptedPetTypes
                        .map((type) => Chip(label: Text(type.label)))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Ulasan pemilik',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (reviews.isEmpty)
                    const Text('Belum ada ulasan untuk penitip ini.')
                  else
                    ...reviews.map(
                      (Review review) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      review.ownerName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                  ),
                                  Icon(
                                    Icons.star_rounded,
                                    size: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary,
                                  ),
                                  Text(review.rating.toStringAsFixed(1)),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(review.comment),
                              const SizedBox(height: 5),
                              Text(
                                _dateFormat.format(review.createdAt),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: FilledButton.icon(
          onPressed: () =>
              Navigator.of(context)
                  .pushNamed(AppRoutes.booking, arguments: sitter.id),
          icon: const Icon(Icons.calendar_month),
          label: const Text('Pesan Sekarang'),
        ),
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
      ],
    );
  }
}
