import 'package:flutter/material.dart';

/// Meminta konfirmasi sebelum pengguna keluar dari sesi PetStay.
Future<bool> showExitConfirmation(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('Keluar dari sistem?'),
          content: const Text('Apakah Anda yakin mau keluar dari sistem?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Ya, Keluar'),
            ),
          ],
        ),
      ) ??
      false;
}
