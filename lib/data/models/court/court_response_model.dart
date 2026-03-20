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
    String? pickString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
      return null;
    }

    return CourtImageModel(
      id: pickString(['id', 'Id']) ?? '',
      courtId: pickString(['courtId', 'CourtId']) ?? '',
      imageUrl:
          pickString(['imageUrl', 'ImageUrl', 'url', 'Url', 'path', 'Path']) ??
          '',
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
    String? pickString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
      return null;
    }

    List<dynamic>? pickList(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is List) return value;
      }
      return null;
    }

    final rawImages = pickList([
      'courtImages',
      'CourtImages',
      'images',
      'Images',
    ]);

    return CourtResponseModel(
      id: pickString(['id', 'Id']) ?? '',
      courtName: pickString(['courtName', 'CourtName', 'name', 'Name']) ?? '',
      description: pickString(['description', 'Description']),
      status: pickString(['status', 'Status']) ?? '',
      courtImages:
          rawImages
              ?.map((e) => CourtImageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
