import '../../repositories/i_category_repository.dart';

class DeleteCategoryUseCase {
  final ICategoryRepository repository;
  DeleteCategoryUseCase(this.repository);
  Future<void> call(String id) => repository.delete(id);
}
