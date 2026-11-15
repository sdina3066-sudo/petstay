import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../data/models/pet.dart';
import '../../data/models/sitter.dart';
import '../../providers/booking_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/sitter_provider.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({required this.sitterId, super.key});

  final String sitterId;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  late final TextEditingController _notesController;
  static final DateFormat _dateFormat = DateFormat('d MMMM y', 'id_ID');
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    final BookingProvider booking = context.read<BookingProvider>();
    _startController = TextEditingController(
      text: _formatDate(booking.startDate),
    );
    _endController = TextEditingController(text: _formatDate(booking.endDate));
    _notesController = TextEditingController(text: booking.draftNotes);
  }

  String _formatDate(DateTime? date) =>
      date == null ? '' : _dateFormat.format(date);

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final BookingProvider booking = context.read<BookingProvider>();
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    final DateTime firstDate = isStart ? today : (booking.startDate ?? today);
    final DateTime initialDate = isStart
        ? (booking.startDate != null && !booking.startDate!.isBefore(today)
              ? booking.startDate!
              : today)
        : (booking.endDate != null && !booking.endDate!.isBefore(firstDate)
              ? booking.endDate!
              : firstDate);
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(today.year + 3),
      helpText: isStart ? 'Pilih tanggal mulai' : 'Pilih tanggal selesai',
    );
    if (selected == null || !mounted) return;
    if (isStart) {
      booking.setStartDate(selected);
      _startController.text = _formatDate(selected);
      if (booking.endDate != null && booking.endDate!.isBefore(selected)) {
        booking.setEndDate(null);
        _endController.clear();
      }
    } else {
      booking.setEndDate(selected);
      _endController.text = _formatDate(selected);
    }
  }

  void _submit(Sitter sitter, PetProvider pets, BookingProvider booking) {
    if (!_formKey.currentState!.validate()) return;
    final Pet? pet = booking.selectedPetId == null
        ? null
        : pets.findById(booking.selectedPetId!);
    final String? error = booking.createBooking(sitter: sitter, pet: pet);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    _startController.clear();
    _endController.clear();
    _notesController.clear();
    context.read<NavigationProvider>().selectTab(1);
    Navigator.of(
      context,
    ).popUntil((Route<dynamic> route) => route.settings.name == AppRoutes.main);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Pesanan berhasil dibuat.')));
  }

  @override
  Widget build(BuildContext context) {
    final Sitter? sitter = context.watch<SitterProvider>().findById(
      widget.sitterId,
    );
    final PetProvider pets = context.watch<PetProvider>();
    if (sitter == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pemesanan')),
        body: const Center(child: Text('Data penitip tidak ditemukan.')),
      );
    }

    return Consumer<BookingProvider>(
      builder: (BuildContext context, BookingProvider booking, _) {
        if (pets.pets.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Pemesanan')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pets_outlined, size: 52),
                    const SizedBox(height: 12),
                    const Text(
                      'Tambahkan hewan terlebih dahulu sebelum membuat pesanan.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        context.read<NavigationProvider>().selectTab(2);
                        Navigator.of(context).popUntil(
                          (Route<dynamic> route) =>
                              route.settings.name == AppRoutes.main,
                        );
                      },
                      child: const Text('Tambah Hewan'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        final String? selectedPetId =
            pets.findById(booking.selectedPetId ?? '') == null
            ? null
            : booking.selectedPetId;

        return Scaffold(
          appBar: AppBar(title: const Text('Form Pemesanan')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Penitip: ${sitter.name}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 18),
                        DropdownButtonFormField<String>(
                          initialValue: selectedPetId,
                          decoration: const InputDecoration(
                            labelText: 'Pilih hewan',
                            prefixIcon: Icon(Icons.pets),
                          ),
                          items: pets.pets
                              .map(
                                (Pet pet) => DropdownMenuItem<String>(
                                  value: pet.id,
                                  child: Text(
                                    '${pet.name} • ${pet.type.label}',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: booking.setSelectedPet,
                          validator: (String? value) =>
                              value == null ? 'Hewan wajib dipilih.' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _startController,
                          readOnly: true,
                          onTap: () => _pickDate(isStart: true),
                          decoration: const InputDecoration(
                            labelText: 'Tanggal mulai',
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal mulai wajib dipilih.';
                            }
                            final DateTime? date = booking.startDate;
                            if (date != null &&
                                date.isBefore(
                                  DateUtils.dateOnly(DateTime.now()),
                                )) {
                              return 'Tanggal mulai tidak boleh di masa lalu.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _endController,
                          readOnly: true,
                          onTap: () => _pickDate(isStart: false),
                          decoration: const InputDecoration(
                            labelText: 'Tanggal selesai',
                            prefixIcon: Icon(Icons.event_available_outlined),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal selesai wajib dipilih.';
                            }
                            if (booking.startDate != null &&
                                booking.endDate != null &&
                                booking.endDate!.isBefore(booking.startDate!)) {
                              return 'Tanggal selesai tidak boleh sebelum tanggal mulai.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesController,
                          minLines: 3,
                          maxLines: 5,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Catatan untuk penitip (opsional)',
                            alignLabelWithHint: true,
                          ),
                          onChanged: booking.setDraftNotes,
                        ),
                        const SizedBox(height: 20),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ringkasan biaya',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${booking.durationDays} hari × ${_currency.format(sitter.pricePerDay)}',
                                ),
                                const Divider(height: 22),
                                Row(
                                  children: [
                                    const Expanded(child: Text('Total')),
                                    Text(
                                      _currency.format(
                                        booking.totalCostFor(sitter),
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () => _submit(sitter, pets, booking),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Konfirmasi Pesanan'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
