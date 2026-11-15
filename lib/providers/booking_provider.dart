import 'package:flutter/material.dart';

import '../data/models/booking.dart';
import '../data/models/pet.dart';
import '../data/models/review.dart';
import '../data/models/sitter.dart';
import '../data/repositories/pet_stay_repository.dart';
import 'sitter_provider.dart';

/// Mengelola pesanan, laporan, ulasan, dan draft pemesanan yang belum disimpan.
class BookingProvider extends ChangeNotifier {
  BookingProvider(PetStayRepository repository)
    : _bookings = repository.getBookings().toList(),
      _reviews = repository.getReviews().toList();

  final List<Booking> _bookings;
  final List<Review> _reviews;
  SitterProvider? _sitterProvider;
  String? _selectedPetId;
  DateTime? _startDate;
  DateTime? _endDate;
  String _draftNotes = '';

  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<Review> get reviews => List.unmodifiable(_reviews);
  String? get selectedPetId => _selectedPetId;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get draftNotes => _draftNotes;

  void connectSitterProvider(SitterProvider provider) {
    _sitterProvider = provider;
  }

  void setSelectedPet(String? id) {
    _selectedPetId = id;
    notifyListeners();
  }

  void setStartDate(DateTime? date) {
    _startDate = date == null ? null : DateUtils.dateOnly(date);
    notifyListeners();
  }

  void setEndDate(DateTime? date) {
    _endDate = date == null ? null : DateUtils.dateOnly(date);
    notifyListeners();
  }

  void setDraftNotes(String value) {
    _draftNotes = value;
    notifyListeners();
  }

  int get durationDays {
    if (_startDate == null || _endDate == null) return 0;
    final int days = _endDate!.difference(_startDate!).inDays;
    return days == 0 ? 1 : days;
  }

  int totalCostFor(Sitter sitter) => durationDays * sitter.pricePerDay;

  /// Validasi dan simpan pesanan; nilai null menandakan operasi berhasil.
  String? createBooking({required Sitter sitter, required Pet? pet}) {
    if (pet == null || _selectedPetId == null) {
      return 'Pilih hewan yang akan dititipkan.';
    }
    if (_startDate == null || _endDate == null) {
      return 'Tanggal mulai dan selesai wajib dipilih.';
    }
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    if (_startDate!.isBefore(today)) {
      return 'Tanggal mulai tidak boleh di masa lalu.';
    }
    if (_endDate!.isBefore(_startDate!)) {
      return 'Tanggal selesai tidak boleh sebelum tanggal mulai.';
    }
    if (!sitter.acceptedPetTypes.contains(pet.type)) {
      return 'Penitip ini tidak menerima jenis hewan ${pet.type.label}.';
    }

    _bookings.insert(
      0,
      Booking(
        id: 'booking-${DateTime.now().microsecondsSinceEpoch}',
        sitterId: sitter.id,
        petId: pet.id,
        startDate: _startDate!,
        endDate: _endDate!,
        notes: _draftNotes.trim(),
        totalCost: durationDays * sitter.pricePerDay,
        status: BookingStatus.menunggu,
        dailyReports: const [],
      ),
    );
    _selectedPetId = null;
    _startDate = null;
    _endDate = null;
    _draftNotes = '';
    notifyListeners();
    return null;
  }

  String? updateStatus(String bookingId) {
    final int index = _bookings.indexWhere(
      (Booking booking) => booking.id == bookingId,
    );
    if (index < 0) return 'Pesanan tidak ditemukan.';
    final Booking current = _bookings[index];
    final int nextIndex = current.status.index + 1;
    if (nextIndex >= BookingStatus.values.length) {
      return 'Pesanan sudah mencapai status selesai.';
    }
    _bookings[index] = current.copyWith(
      status: BookingStatus.values[nextIndex],
    );
    notifyListeners();
    return null;
  }

  String? addDailyReport(String bookingId, String message) {
    final int index = _bookings.indexWhere(
      (Booking booking) => booking.id == bookingId,
    );
    if (index < 0) return 'Pesanan tidak ditemukan.';
    if (message.trim().isEmpty) return 'Laporan tidak boleh kosong.';
    final Booking current = _bookings[index];
    _bookings[index] = current.copyWith(
      dailyReports: [
        ...current.dailyReports,
        DailyReport(date: DateTime.now(), message: message.trim()),
      ],
    );
    notifyListeners();
    return null;
  }

  String? addReview({
    required String bookingId,
    required double rating,
    required String comment,
    required String ownerName,
  }) {
    final int index = _bookings.indexWhere(
      (Booking booking) => booking.id == bookingId,
    );
    if (index < 0) return 'Pesanan tidak ditemukan.';
    final Booking booking = _bookings[index];
    if (booking.status != BookingStatus.selesai) {
      return 'Ulasan hanya dapat diberikan setelah pesanan selesai.';
    }
    if (booking.hasReview) return 'Pesanan ini sudah memiliki ulasan.';
    if (rating < 1 || rating > 5) {
      return 'Pilih rating bintang terlebih dahulu.';
    }
    if (comment.trim().isEmpty) return 'Komentar ulasan tidak boleh kosong.';

    final Review review = Review(
      id: 'review-${DateTime.now().microsecondsSinceEpoch}',
      sitterId: booking.sitterId,
      ownerName: ownerName,
      rating: rating,
      comment: comment.trim(),
      createdAt: DateTime.now(),
    );
    _reviews.insert(0, review);
    _bookings[index] = booking.copyWith(hasReview: true);
    _sitterProvider?.addReview(review);
    notifyListeners();
    return null;
  }

  Booking? findById(String id) {
    for (final Booking booking in _bookings) {
      if (booking.id == id) return booking;
    }
    return null;
  }
}
