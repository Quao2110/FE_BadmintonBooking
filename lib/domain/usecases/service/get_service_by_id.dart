import '../../entities/service_entity.dart';
import '../../repositories/i_service_repository.dart';

class GetServiceByIdUseCase {
  final IServiceRepository repository;
  GetServiceByIdUseCase(this.repository);
  Future<ServiceEntity> call(String id) => repository.getById(id);
}
