import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/models/pet.dart';
import '../../providers/pet_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/pet_card.dart';

class MyPetsScreen extends StatelessWidget {
  const MyPetsScreen({super.key});

  Future<void> _openForm(BuildContext context, {Pet? pet}) async {
    final Pet? result = await showModalBottomSheet<Pet>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PetFormSheet(pet: pet),
    );
    if (result == null || !context.mounted) return;
    final PetProvider provider = context.read<PetProvider>();
    final String? error = pet == null
        ? provider.addPet(result)
        : provider.updatePet(result);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _confirmDelete(BuildContext context, Pet pet) async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: const Text('Hapus hewan?'),
            content: Text('Profil ${pet.name} akan dihapus dari daftar.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !context.mounted) return;
    final String? error = context.read<PetProvider>().deletePet(pet.id);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Pet> pets = context.watch<PetProvider>().pets;
    return Scaffold(
      appBar: AppBar(title: const Text('Hewan Saya')),
      body: pets.isEmpty
          ? const EmptyState(
              title: 'Belum ada hewan',
              message: 'Tambahkan profil hewan untuk mulai membuat pesanan.',
              icon: Icons.pets_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: pets.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                final Pet pet = pets[index];
                return PetCard(
                  pet: pet,
                  onEdit: () => _openForm(context, pet: pet),
                  onDelete: () => _confirmDelete(context, pet),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Hewan'),
      ),
    );
  }
}

class _PetFormSheet extends StatefulWidget {
  const _PetFormSheet({this.pet});

  final Pet? pet;

  @override
  State<_PetFormSheet> createState() => _PetFormSheetState();
}

class _PetFormSheetState extends State<_PetFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _feedingController;
  late final TextEditingController _notesController;
  PetType? _type;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet?.name ?? '');
    _ageController = TextEditingController(
      text: widget.pet?.ageYears.toString() ?? '',
    );
    _feedingController = TextEditingController(
      text: widget.pet?.feedingHabits ?? '',
    );
    _notesController = TextEditingController(text: widget.pet?.notes ?? '');
    _type = widget.pet?.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _feedingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final Pet pet = Pet(
      id: widget.pet?.id ?? 'pet-${DateTime.now().microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      type: _type!,
      ageYears: int.parse(_ageController.text.trim()),
      feedingHabits: _feedingController.text.trim(),
      notes: _notesController.text.trim(),
    );
    Navigator.of(context).pop(pet);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.pet == null ? 'Tambah Hewan' : 'Ubah Hewan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Nama hewan'),
                    validator: (String? value) =>
                        value == null || value.trim().isEmpty
                        ? 'Nama hewan wajib diisi.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<PetType>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Jenis hewan'),
                    items: PetType.values
                        .map(
                          (PetType type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.label),
                          ),
                        )
                        .toList(),
                    onChanged: (PetType? value) =>
                        setState(() => _type = value),
                    validator: (PetType? value) =>
                        value == null ? 'Jenis hewan wajib dipilih.' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Umur (tahun)',
                    ),
                    validator: (String? value) {
                      final int? age = int.tryParse(value ?? '');
                      if (age == null) return 'Umur harus berupa angka.';
                      if (age <= 0) return 'Umur harus lebih dari 0.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _feedingController,
                    decoration: const InputDecoration(
                      labelText: 'Kebiasaan makan',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _notesController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Catatan khusus',
                      alignLabelWithHint: true,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _save,
                    child: const Text('Simpan Profil Hewan'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
