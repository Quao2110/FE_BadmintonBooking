class CourtImageModel {
  final String id;
  final String courtId;
  final String imageUrl;

  CourtImageModel({
    required this.id,
    required this.courtId,
    required this.imageUrl,
  });

  factory CourtImageModel.fromJson(Map<String, dynamic> json) {
    return CourtImageModel(
      id: json['id']?.toString() ?? '',
      courtId: json['courtId']?.toString() ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class CourtResponseModel {
  final String id;
  final String courtName;
  final String? description;
  final String status;
  final List<CourtImageModel> courtImages;

  CourtResponseModel({
    required this.id,
    required this.courtName,
    this.description,
    required this.status,
    required this.courtImages,
  });

  factory CourtResponseModel.fromJson(Map<String, dynamic> json) {
    return CourtResponseModel(
      id: json['id']?.toString() ?? '',
      courtName: json['courtName'] ?? '',
      description: json['description'],
      status: json['status'] ?? '',
      courtImages: (json['courtImages'] as List?)
              ?.map((e) => CourtImageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
