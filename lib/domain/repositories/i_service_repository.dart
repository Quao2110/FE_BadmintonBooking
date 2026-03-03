import '../entities/service_entity.dart';

abstract class IServiceRepository {
  Future<List<ServiceEntity>> getAll();
  Future<ServiceEntity> getById(String id);
}
