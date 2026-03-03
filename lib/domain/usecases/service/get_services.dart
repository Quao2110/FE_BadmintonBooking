import '../../entities/service_entity.dart';
import '../../repositories/i_service_repository.dart';

class GetServicesUseCase {
  final IServiceRepository repository;
  GetServicesUseCase(this.repository);
  Future<List<ServiceEntity>> call() => repository.getAll();
}
