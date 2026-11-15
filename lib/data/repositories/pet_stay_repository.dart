import '../dummy/dummy_data.dart';
import '../models/booking.dart';
import '../models/pet.dart';
import '../models/review.dart';
import '../models/sitter.dart';

/// Gerbang akses data lokal agar UI dan provider tidak bergantung langsung
/// pada sumber dummy.
class PetStayRepository {
  const PetStayRepository();

  List<Sitter> getSitters() => List.unmodifiable(DummyData.sitters);

  List<Pet> getPets() => List.unmodifiable(DummyData.pets);

  List<Booking> getBookings() => List.unmodifiable(DummyData.bookings);

  List<Review> getReviews() => List.unmodifiable(DummyData.reviews);
}
