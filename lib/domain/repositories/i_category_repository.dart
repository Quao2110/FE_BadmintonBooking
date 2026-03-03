import '../../data/models/category/create_category_request.dart';
import '../../data/models/category/update_category_request.dart';
import '../entities/category_entity.dart';

abstract class ICategoryRepository {
  Future<List<CategoryEntity>> getAll();
  Future<CategoryEntity> getById(String id);
  Future<CategoryEntity> create(CreateCategoryRequest request);
  Future<CategoryEntity> update(String id, UpdateCategoryRequest request);
  Future<void> delete(String id);
}
