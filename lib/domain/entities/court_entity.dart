class CourtEntity {
  final String id;
  final String courtName;
  final String? description;
  final String status;
  final List<CourtImageEntity> courtImages;

  CourtEntity({
    required this.id,
    required this.courtName,
    this.description,
    required this.status,
    required this.courtImages,
  });

  String? get primaryImageUrl => courtImages.isNotEmpty ? courtImages.first.imageUrl : null;
}

class CourtImageEntity {
  final String id;
  final String courtId;
  final String imageUrl;

  CourtImageEntity({
    required this.id,
    required this.courtId,
    required this.imageUrl,
  });
}
