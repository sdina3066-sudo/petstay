/// Jenis hewan yang didukung oleh data dummy PetStay.
enum PetType {
  kucing,
  kelinci,
  hamster,
  lainnya;

  String get label => switch (this) {
    PetType.kucing => 'Kucing',
    PetType.kelinci => 'Kelinci',
    PetType.hamster => 'Hamster',
    PetType.lainnya => 'Lainnya',
  };
}

/// Profil hewan milik pengguna.
class Pet {
  const Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.ageYears,
    required this.feedingHabits,
    required this.notes,
  });

  final String id;
  final String name;
  final PetType type;
  final int ageYears;
  final String feedingHabits;
  final String notes;

  Pet copyWith({
    String? id,
    String? name,
    PetType? type,
    int? ageYears,
    String? feedingHabits,
    String? notes,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      ageYears: ageYears ?? this.ageYears,
      feedingHabits: feedingHabits ?? this.feedingHabits,
      notes: notes ?? this.notes,
    );
  }
}
