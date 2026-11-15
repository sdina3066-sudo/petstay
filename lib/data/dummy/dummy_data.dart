import '../models/booking.dart';
import '../models/pet.dart';
import '../models/review.dart';
import '../models/sitter.dart';

/// Sumber data lokal untuk demo; tidak menggunakan API atau database.
class DummyData {
  DummyData._();

  static final List<Sitter> sitters = [
    const Sitter(
      id: 'sitter-01',
      name: 'Nadia Putri',
      location: 'Batam Centre',
      pricePerDay: 50000,
      rating: 4.9,
      reviewCount: 18,
      acceptedPetTypes: [PetType.kucing, PetType.kelinci],
      bio: 'Penyayang hewan dan berpengalaman merawat kucing serta kelinci.',
    ),
    const Sitter(
      id: 'sitter-02',
      name: 'Rizky Pratama',
      location: 'Nagoya',
      pricePerDay: 35000,
      rating: 4.7,
      reviewCount: 12,
      acceptedPetTypes: [PetType.kucing],
      bio: 'Rumah nyaman dan aman untuk kucing kesayangan Anda.',
    ),
    const Sitter(
      id: 'sitter-03',
      name: 'Melati Sari',
      location: 'Sekupang',
      pricePerDay: 45000,
      rating: 4.8,
      reviewCount: 15,
      acceptedPetTypes: [PetType.kelinci, PetType.hamster],
      bio: 'Terbiasa merawat hewan kecil dengan jadwal makan teratur.',
    ),
    const Sitter(
      id: 'sitter-04',
      name: 'Fajar Ramadhan',
      location: 'Batu Aji',
      pricePerDay: 25000,
      rating: 4.5,
      reviewCount: 8,
      acceptedPetTypes: [PetType.hamster, PetType.lainnya],
      bio: 'Menerima hamster dan hewan kecil lainnya dengan sepenuh hati.',
    ),
    const Sitter(
      id: 'sitter-05',
      name: 'Ayu Lestari',
      location: 'Bengkong',
      pricePerDay: 60000,
      rating: 5.0,
      reviewCount: 22,
      acceptedPetTypes: [PetType.kucing, PetType.kelinci, PetType.hamster],
      bio: 'Penitip berpengalaman, laporan rutin dan tempat selalu bersih.',
    ),
    const Sitter(
      id: 'sitter-06',
      name: 'Dimas Saputra',
      location: 'Tiban',
      pricePerDay: 40000,
      rating: 4.6,
      reviewCount: 10,
      acceptedPetTypes: [PetType.kucing, PetType.lainnya],
      bio: 'Senang menemani hewan bermain dan menjaga rutinitasnya.',
    ),
    const Sitter(
      id: 'sitter-07',
      name: 'Siti Rahma',
      location: 'Batu Ampar',
      pricePerDay: 55000,
      rating: 4.8,
      reviewCount: 16,
      acceptedPetTypes: [PetType.kelinci, PetType.hamster],
      bio: 'Paham kebutuhan hewan kecil dan menyediakan area yang tenang.',
    ),
    const Sitter(
      id: 'sitter-08',
      name: 'Kevin Wijaya',
      location: 'Lubuk Baja',
      pricePerDay: 75000,
      rating: 4.9,
      reviewCount: 20,
      acceptedPetTypes: [PetType.kucing, PetType.kelinci, PetType.hamster],
      bio: 'Perawatan penuh perhatian, termasuk mengirim kabar setiap hari.',
    ),
    const Sitter(
      id: 'sitter-09',
      name: 'Intan Permata',
      location: 'Piayu',
      pricePerDay: 30000,
      rating: 4.4,
      reviewCount: 6,
      acceptedPetTypes: [PetType.kucing, PetType.hamster],
      bio: 'Pilihan ramah di kantong untuk penitipan yang nyaman.',
    ),
  ];

  static const List<Pet> pets = [
    Pet(
      id: 'pet-01',
      name: 'Mimi',
      type: PetType.kucing,
      ageYears: 2,
      feedingHabits: 'Makan dua kali sehari, suka ikan.',
      notes: 'Takut suara keras.',
    ),
    Pet(
      id: 'pet-02',
      name: 'Mochi',
      type: PetType.kelinci,
      ageYears: 1,
      feedingHabits: 'Rumput dan sayuran segar.',
      notes: 'Perlu ruang untuk bergerak.',
    ),
    Pet(
      id: 'pet-03',
      name: 'Bubu',
      type: PetType.hamster,
      ageYears: 1,
      feedingHabits: 'Pelet hamster setiap sore.',
      notes: 'Jangan membangunkan saat siang.',
    ),
    Pet(
      id: 'pet-04',
      name: 'Oyen',
      type: PetType.kucing,
      ageYears: 3,
      feedingHabits: 'Makan pagi dan malam.',
      notes: 'Ramah dan suka bermain bola.',
    ),
  ];

  static List<Booking> get bookings {
    final DateTime today = DateTime.now();
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime twoDaysAgo = today.subtract(const Duration(days: 2));
    final DateTime tomorrow = today.add(const Duration(days: 1));
    final DateTime nextWeek = today.add(const Duration(days: 7));

    return [
      Booking(
        id: 'booking-01',
        sitterId: 'sitter-01',
        petId: 'pet-01',
        startDate: twoDaysAgo,
        endDate: tomorrow,
        notes: 'Mohon kabari jika Mimi terlihat kurang aktif.',
        totalCost: 150000,
        status: BookingStatus.sedangDititip,
        dailyReports: [
          DailyReport(
            date: twoDaysAgo,
            message: 'Mimi sudah makan dan bermain.',
          ),
          DailyReport(
            date: yesterday,
            message: 'Mimi tidur nyenyak dan makan habis.',
          ),
        ],
      ),
      Booking(
        id: 'booking-02',
        sitterId: 'sitter-05',
        petId: 'pet-02',
        startDate: tomorrow,
        endDate: nextWeek,
        notes: 'Mochi perlu sayuran segar setiap pagi.',
        totalCost: 420000,
        status: BookingStatus.menunggu,
        dailyReports: const [],
      ),
      Booking(
        id: 'booking-03',
        sitterId: 'sitter-02',
        petId: 'pet-04',
        startDate: yesterday,
        endDate: today,
        notes: 'Oyen suka bermain bola.',
        totalCost: 35000,
        status: BookingStatus.diterima,
        dailyReports: const [],
      ),
      Booking(
        id: 'booking-04',
        sitterId: 'sitter-03',
        petId: 'pet-03',
        startDate: twoDaysAgo,
        endDate: yesterday,
        notes: 'Pastikan kandang Bubu tetap kering.',
        totalCost: 45000,
        status: BookingStatus.selesai,
        dailyReports: [
          DailyReport(date: twoDaysAgo, message: 'Bubu makan dengan lahap.'),
          DailyReport(date: yesterday, message: 'Kandang sudah dibersihkan.'),
        ],
        hasReview: true,
      ),
      Booking(
        id: 'booking-05',
        sitterId: 'sitter-08',
        petId: 'pet-01',
        startDate: today.add(const Duration(days: 10)),
        endDate: today.add(const Duration(days: 12)),
        notes: 'Mimi membawa makanan sendiri.',
        totalCost: 150000,
        status: BookingStatus.menunggu,
        dailyReports: const [],
      ),
    ];
  }

  static List<Review> get reviews {
    final DateTime now = DateTime.now();
    return [
      Review(
        id: 'review-01',
        sitterId: 'sitter-01',
        ownerName: 'Rani',
        rating: 5,
        comment: 'Mimi dirawat dengan baik, saya mendapat kabar setiap hari.',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Review(
        id: 'review-02',
        sitterId: 'sitter-02',
        ownerName: 'Bima',
        rating: 4.5,
        comment: 'Tempatnya bersih dan Oyen terlihat nyaman.',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Review(
        id: 'review-03',
        sitterId: 'sitter-03',
        ownerName: 'Dewi',
        rating: 5,
        comment: 'Bubu dijaga dengan telaten. Terima kasih!',
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      Review(
        id: 'review-04',
        sitterId: 'sitter-05',
        ownerName: 'Tia',
        rating: 4.5,
        comment: 'Responsif dan rutin mengirim foto perkembangan.',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Review(
        id: 'review-05',
        sitterId: 'sitter-08',
        ownerName: 'Andi',
        rating: 5,
        comment: 'Pengalaman penitipan yang sangat menyenangkan.',
        createdAt: now.subtract(const Duration(days: 12)),
      ),
    ];
  }
}
