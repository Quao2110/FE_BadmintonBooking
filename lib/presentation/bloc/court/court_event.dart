import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class CourtEvent extends Equatable {
  const CourtEvent();
  @override
  List<Object?> get props => [];
}

class LoadAllCourts extends CourtEvent {
  const LoadAllCourts();
}

class LoadCourtById extends CourtEvent {
  final String id;
  const LoadCourtById(this.id);
  @override
  List<Object?> get props => [id];
}

class UploadCourtImage extends CourtEvent {
  final String courtId;
  final XFile imageFile;

  const UploadCourtImage({required this.courtId, required this.imageFile});

  @override
  List<Object?> get props => [courtId, imageFile.path];
}

class UpdateCourt extends CourtEvent {
  final String courtId;
  final String courtName;
  final String? description;
  final String status;

  const UpdateCourt({
    required this.courtId,
    required this.courtName,
    this.description,
    required this.status,
  });

  @override
  List<Object?> get props => [courtId, courtName, description, status];
}
