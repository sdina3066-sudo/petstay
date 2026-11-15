import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_stay/data/models/pet.dart';
import 'package:pet_stay/data/models/sitter.dart';
import 'package:pet_stay/data/repositories/pet_stay_repository.dart';
import 'package:pet_stay/providers/auth_provider.dart';
import 'package:pet_stay/providers/booking_provider.dart';
import 'package:pet_stay/providers/pet_provider.dart';
import 'package:pet_stay/providers/sitter_provider.dart';

void main() {
  const PetStayRepository repository = PetStayRepository();

  group('AuthProvider', () {
    test('memvalidasi login dan menyimpan peran', () {
      final AuthProvider auth = AuthProvider();
      expect(
        auth.login(email: '', password: '', role: UserRole.pemilik),
        isNotNull,
      );
      expect(
        auth.login(
          email: 'pemilik@example.com',
          password: 'rahasia1',
          role: UserRole.penitip,
        ),
        isNull,
      );
      expect(auth.isLoggedIn, isTrue);
      expect(auth.role, UserRole.penitip);
      auth.logout();
      expect(auth.isLoggedIn, isFalse);
    });
  });

  group('SitterProvider', () {
    test('mencari dan memfilter penitip berdasarkan jenis hewan', () async {
      final SitterProvider sitters = SitterProvider(repository);
      await sitters.retry();
      sitters.setQuery('Nagoya');
      expect(sitters.filteredSitters.map((Sitter sitter) => sitter.id), [
        'sitter-02',
      ]);
      sitters.setQuery('');
      sitters.setPetTypeFilter(PetType.hamster);
      expect(
        sitters.filteredSitters.every(
          (Sitter sitter) => sitter.acceptedPetTypes.contains(PetType.hamster),
        ),
        isTrue,
      );
      sitters.dispose();
    });
  });

  group('Pet dan pesanan', () {
    test('CRUD hewan dan membuat pesanan dengan rating baru', () async {
      final PetProvider pets = PetProvider(repository);
      final Pet addedPet = Pet(
        id: 'pet-test',
        name: 'Kiki',
        type: PetType.kucing,
        ageYears: 2,
        feedingHabits: 'Pagi dan sore',
        notes: '',
      );
      expect(pets.addPet(addedPet), isNull);
      expect(pets.findById(addedPet.id)?.name, 'Kiki');
      expect(pets.updatePet(addedPet.copyWith(name: 'Kiki Baru')), isNull);
      expect(pets.findById(addedPet.id)?.name, 'Kiki Baru');

      final SitterProvider sitters = SitterProvider(repository);
      await sitters.retry();
      final BookingProvider bookings = BookingProvider(repository)
        ..connectSitterProvider(sitters);
      final Sitter sitter = sitters.findById('sitter-01')!;
      final Pet pet = pets.findById('pet-01')!;
      final DateTime tomorrow = DateUtils.dateOnly(DateTime.now())
          .add(const Duration(days: 1));
      bookings.setSelectedPet(pet.id);
      bookings.setStartDate(tomorrow);
      bookings.setEndDate(tomorrow.add(const Duration(days: 2)));
      expect(bookings.createBooking(sitter: sitter, pet: pet), isNull);
      final String bookingId = bookings.bookings.first.id;
      expect(bookings.bookings.first.totalCost, sitter.pricePerDay * 2);

      expect(bookings.updateStatus(bookingId), isNull);
      expect(bookings.updateStatus(bookingId), isNull);
      expect(bookings.updateStatus(bookingId), isNull);
      expect(
        bookings.addReview(
          bookingId: bookingId,
          rating: 5,
          comment: 'Perawatan sangat baik.',
          ownerName: 'Pemilik',
        ),
        isNull,
      );
      expect(bookings.findById(bookingId)?.hasReview, isTrue);
      expect(sitters.findById(sitter.id)?.reviewCount, sitter.reviewCount + 1);
      expect(pets.deletePet(addedPet.id), isNull);

      bookings.dispose();
      sitters.dispose();
      pets.dispose();
    });

    test('menolak pesanan jika jenis hewan tidak diterima', () {
      final BookingProvider bookings = BookingProvider(repository);
      final Sitter sitter = repository.getSitters().firstWhere(
        (Sitter item) => item.id == 'sitter-02',
      );
      final Pet rabbit = repository.getPets().firstWhere(
        (Pet item) => item.type == PetType.kelinci,
      );
      final DateTime tomorrow = DateUtils.dateOnly(DateTime.now())
          .add(const Duration(days: 1));
      bookings.setSelectedPet(rabbit.id);
      bookings.setStartDate(tomorrow);
      bookings.setEndDate(tomorrow.add(const Duration(days: 1)));
      expect(
        bookings.createBooking(sitter: sitter, pet: rabbit),
        contains('tidak menerima'),
      );
      bookings.dispose();
    });
  });
}
