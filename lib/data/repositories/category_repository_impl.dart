import '../datasources/category_api_service.dart';
import '../models/category/category_response_model.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../models/category/create_category_request.dart';
import '../models/category/update_category_request.dart';

class CategoryRepository implements ICategoryRepository {
  final CategoryRemoteDataSource _dataSource;
  CategoryRepository({CategoryRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? CategoryRemoteDataSource();

  @override
  Future<List<CategoryEntity>> getAll() async {
    final res = await _dataSource.getAll();
    if (res.isSuccess && res.result != null) {
      return res.result!.map(_mapToEntity).toList();
    }
    throw Exception(res.message);
  }

  @override
  Future<CategoryEntity> getById(String id) async {
    final res = await _dataSource.getById(id);
    if (res.isSuccess && res.result != null) {
      return _mapToEntity(res.result!);
    }
    throw Exception(res.message);
  }

  @override
  Future<CategoryEntity> create(CreateCategoryRequest request) async {
    final res = await _dataSource.create(request);
    if (res.isSuccess && res.result != null) {
      return _mapToEntity(res.result!);
    }
    throw Exception(res.message);
  }

  @override
  Future<CategoryEntity> update(String id, UpdateCategoryRequest request) async {
    final res = await _dataSource.update(id, request);
    if (res.isSuccess && res.result != null) {
      return _mapToEntity(res.result!);
    }
    throw Exception(res.message);
  }

  @override
  Future<void> delete(String id) async {
    final res = await _dataSource.delete(id);
    if (!res.isSuccess) throw Exception(res.message);
  }

  CategoryEntity _mapToEntity(CategoryResponseModel m) {
    return CategoryEntity(
      id: m.id,
      categoryName: m.categoryName,
    );
  }
}
