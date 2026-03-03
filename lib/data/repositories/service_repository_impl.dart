import '../datasources/service_api_service.dart';
import '../models/service/service_response_model.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/i_service_repository.dart';

class ServiceRepository implements IServiceRepository {
  final ServiceRemoteDataSource _dataSource;
  ServiceRepository({ServiceRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? ServiceRemoteDataSource();

  @override
  Future<List<ServiceEntity>> getAll() async {
    final res = await _dataSource.getAll();
    if (res.isSuccess && res.result != null) {
      return res.result!.map(_mapToEntity).toList();
    }
    throw Exception(res.message);
  }

  @override
  Future<ServiceEntity> getById(String id) async {
    final res = await _dataSource.getById(id);
    if (res.isSuccess && res.result != null) {
      return _mapToEntity(res.result!);
    }
    throw Exception(res.message);
  }

  ServiceEntity _mapToEntity(ServiceResponseModel m) {
    return ServiceEntity(
      id: m.id,
      serviceName: m.serviceName,
      price: m.price,
      unit: m.unit,
      stockQuantity: m.stockQuantity,
      isActive: m.isActive,
    );
  }
}
