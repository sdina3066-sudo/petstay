import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models/sitter.dart';

/// Kartu ringkas penitip yang dapat digunakan pada daftar beranda.
class SitterCard extends StatelessWidget {
  const SitterCard({required this.sitter, required this.onTap, super.key});

  final Sitter sitter;
  final VoidCallback onTap;

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String initials = sitter.name
        .split(' ')
        .take(2)
        .map((String part) => part.isNotEmpty ? part[0] : '')
        .join()
        .toUpperCase();
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
                child: Text(initials),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sitter.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sitter.location,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: sitter.acceptedPetTypes
                          .map(
                            (type) => Chip(
                              label: Text(type.label),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.zero,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, color: colors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          '${sitter.rating.toStringAsFixed(1)} (${sitter.reviewCount})',
                        ),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            '${_currency.format(sitter.pricePerDay)}/hari',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
