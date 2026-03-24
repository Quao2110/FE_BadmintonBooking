import 'package:image_picker/image_picker.dart';
import '../entities/court_entity.dart';

abstract class ICourtRepository {
  Future<List<CourtEntity>> getAll();
  Future<CourtEntity> getById(String id);
  Future<void> uploadImage(String courtId, XFile imageFile);
  Future<void> updateCourt({
    required String courtId,
    required String courtName,
    String? description,
    required String status,
  });
}
