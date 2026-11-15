import 'package:flutter/material.dart';

import '../data/models/pet.dart';

/// Kartu profil hewan dengan aksi ubah dan hapus.
class PetCard extends StatelessWidget {
  const PetCard({
    required this.pet,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Pet pet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: colors.primaryContainer,
              foregroundColor: colors.onPrimaryContainer,
              child: Text(_emojiFor(pet.type)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text('${pet.type.label} • ${pet.ageYears} tahun'),
                  if (pet.feedingHabits.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Makan: ${pet.feedingHabits}'),
                  ],
                  if (pet.notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Catatan: ${pet.notes}'),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Aksi hewan',
              onSelected: (String action) {
                if (action == 'edit') onEdit();
                if (action == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Ubah')),
                PopupMenuItem(value: 'delete', child: Text('Hapus')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _emojiFor(PetType type) => switch (type) {
    PetType.kucing => '🐱',
    PetType.kelinci => '🐰',
    PetType.hamster => '🐹',
    PetType.lainnya => '🐾',
  };
}
