/// Status pesanan untuk simulasi alur penitipan.
enum BookingStatus {
  menunggu,
  diterima,
  sedangDititip,
  selesai;

  String get label => switch (this) {
    BookingStatus.menunggu => 'Menunggu',
    BookingStatus.diterima => 'Diterima',
    BookingStatus.sedangDititip => 'Sedang Dititip',
    BookingStatus.selesai => 'Selesai',
  };
}

/// Catatan singkat dari penitip untuk satu hari penitipan.
class DailyReport {
  const DailyReport({required this.date, required this.message});

  final DateTime date;
  final String message;
}

/// Pemesanan penitipan beserta status dan laporan hariannya.
class Booking {
  const Booking({
    required this.id,
    required this.sitterId,
    required this.petId,
    required this.startDate,
    required this.endDate,
    required this.notes,
    required this.totalCost,
    required this.status,
    required this.dailyReports,
    this.hasReview = false,
  });

  final String id;
  final String sitterId;
  final String petId;
  final DateTime startDate;
  final DateTime endDate;
  final String notes;
  final int totalCost;
  final BookingStatus status;
  final List<DailyReport> dailyReports;
  final bool hasReview;

  /// Lama penitipan dalam hari berdasarkan selisih tanggal mulai dan selesai.
  int get durationDays => endDate.difference(startDate).inDays;

  Booking copyWith({
    String? id,
    String? sitterId,
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    int? totalCost,
    BookingStatus? status,
    List<DailyReport>? dailyReports,
    bool? hasReview,
  }) {
    return Booking(
      id: id ?? this.id,
      sitterId: sitterId ?? this.sitterId,
      petId: petId ?? this.petId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      totalCost: totalCost ?? this.totalCost,
      status: status ?? this.status,
      dailyReports: dailyReports ?? this.dailyReports,
      hasReview: hasReview ?? this.hasReview,
    );
  }
}
