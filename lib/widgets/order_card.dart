import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_theme.dart';
import '../data/models/booking.dart';

/// Kartu pesanan dengan identitas hewan, penitip, tanggal, dan status.
class OrderCard extends StatelessWidget {
  const OrderCard({
    required this.booking,
    required this.petName,
    required this.sitterName,
    required this.onTap,
    super.key,
  });

  final Booking booking;
  final String petName;
  final String sitterName;
  final VoidCallback onTap;

  static final DateFormat _dateFormat = DateFormat('d MMM y', 'id_ID');

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color statusColor = switch (booking.status) {
      BookingStatus.menunggu => colors.onSurfaceVariant,
      BookingStatus.diterima => colors.primary,
      BookingStatus.sedangDititip => colors.onSurface,
      BookingStatus.selesai => AppTheme.successColor,
    };
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$petName bersama $sitterName',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_dateFormat.format(booking.startDate)} - '
                '${_dateFormat.format(booking.endDate)}',
              ),
              const SizedBox(height: 10),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(
                    booking.status.label,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
