import '../entities/court_entity.dart';

abstract class ICourtRepository {
  Future<List<CourtEntity>> getAll();
  Future<CourtEntity> getById(String id);
}
