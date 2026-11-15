import 'pet.dart';

/// Informasi penitip dan preferensi hewan yang dapat dirawat.
class Sitter {
  const Sitter({
    required this.id,
    required this.name,
    required this.location,
    required this.pricePerDay,
    required this.rating,
    required this.reviewCount,
    required this.acceptedPetTypes,
    required this.bio,
  });

  final String id;
  final String name;
  final String location;
  final int pricePerDay;
  final double rating;
  final int reviewCount;
  final List<PetType> acceptedPetTypes;
  final String bio;

  Sitter copyWith({
    String? id,
    String? name,
    String? location,
    int? pricePerDay,
    double? rating,
    int? reviewCount,
    List<PetType>? acceptedPetTypes,
    String? bio,
  }) {
    return Sitter(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      acceptedPetTypes: acceptedPetTypes ?? this.acceptedPetTypes,
      bio: bio ?? this.bio,
    );
  }
}
