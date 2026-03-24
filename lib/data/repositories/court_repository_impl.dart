import '../datasources/court_api_service.dart';
import 'package:image_picker/image_picker.dart';
import '../models/court/court_response_model.dart';
import '../../domain/entities/court_entity.dart';
import '../../domain/repositories/i_court_repository.dart';

class CourtRepository implements ICourtRepository {
  final CourtRemoteDataSource _dataSource;
  CourtRepository({CourtRemoteDataSource? dataSource})
    : _dataSource = dataSource ?? CourtRemoteDataSource();

  @override
  Future<List<CourtEntity>> getAll() async {
    final items = await _dataSource.getAll();
    return items.map(_mapToEntity).toList();
  }

  @override
  Future<CourtEntity> getById(String id) async {
    final item = await _dataSource.getById(id);
    return _mapToEntity(item);
  }

  @override
  Future<void> uploadImage(String courtId, XFile imageFile) {
    return _dataSource.uploadImage(courtId: courtId, imageFile: imageFile);
  }

  @override
  Future<void> updateCourt({
    required String courtId,
    required String courtName,
    String? description,
    required String status,
  }) {
    return _dataSource.updateCourt(
      courtId: courtId,
      courtName: courtName,
      description: description,
      status: status,
    );
  }

  CourtEntity _mapToEntity(CourtResponseModel m) {
    return CourtEntity(
      id: m.id,
      courtName: m.courtName,
      description: m.description,
      status: m.status,
      courtImages: m.courtImages
          .map(
            (img) => CourtImageEntity(
              id: img.id,
              courtId: img.courtId,
              imageUrl: img.imageUrl,
            ),
          )
          .toList(),
    );
  }
}
