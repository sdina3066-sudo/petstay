/// Ulasan pemilik hewan untuk penitip.
class Review {
  const Review({
    required this.id,
    required this.sitterId,
    required this.ownerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String sitterId;
  final String ownerName;
  final double rating;
  final String comment;
  final DateTime createdAt;
}
