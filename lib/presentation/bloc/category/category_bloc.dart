import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/category_repository_impl.dart';
import '../../../domain/usecases/category/get_all_categories.dart';
import '../../../domain/usecases/category/get_category_by_id.dart';
import '../../../domain/usecases/category/create_category.dart';
import '../../../domain/usecases/category/update_category.dart';
import '../../../domain/usecases/category/delete_category.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetAllCategoriesUseCase getAllCategories;
  final GetCategoryByIdUseCase getCategoryById;
  final CreateCategoryUseCase createCategory;
  final UpdateCategoryUseCase updateCategory;
  final DeleteCategoryUseCase deleteCategory;

  CategoryBloc({
    required this.getAllCategories,
    required this.getCategoryById,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
  }) : super(const CategoryInitial()) {
    on<GetAllCategoriesEvent>(_onGetAll);
    on<GetCategoryByIdEvent>(_onGetById);
    on<CreateCategoryEvent>(_onCreate);
    on<UpdateCategoryEvent>(_onUpdate);
    on<DeleteCategoryEvent>(_onDelete);
  }

  factory CategoryBloc.create() {
    final repo = CategoryRepository();
    return CategoryBloc(
      getAllCategories: GetAllCategoriesUseCase(repo),
      getCategoryById: GetCategoryByIdUseCase(repo),
      createCategory: CreateCategoryUseCase(repo),
      updateCategory: UpdateCategoryUseCase(repo),
      deleteCategory: DeleteCategoryUseCase(repo),
    );
  }

  Future<void> _onGetAll(GetAllCategoriesEvent event, Emitter<CategoryState> emit) async {
    emit(const CategoryLoading());
    try {
      final items = await getAllCategories();
      emit(CategoryListLoaded(items));
    } catch (e) {
      emit(CategoryError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onGetById(GetCategoryByIdEvent event, Emitter<CategoryState> emit) async {
    emit(const CategoryLoading());
    try {
      final item = await getCategoryById(event.id);
      emit(CategoryLoaded(item));
    } catch (e) {
      emit(CategoryError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onCreate(CreateCategoryEvent event, Emitter<CategoryState> emit) async {
    emit(const CategoryLoading());
    try {
      await createCategory(event.request);
      emit(const CategoryActionSuccess(message: 'Tạo danh mục thành công!'));
    } catch (e) {
      emit(CategoryError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onUpdate(UpdateCategoryEvent event, Emitter<CategoryState> emit) async {
    emit(const CategoryLoading());
    try {
      await updateCategory(event.id, event.request);
      emit(const CategoryActionSuccess(message: 'Cập nhật danh mục thành công!'));
    } catch (e) {
      emit(CategoryError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDelete(DeleteCategoryEvent event, Emitter<CategoryState> emit) async {
    emit(const CategoryLoading());
    try {
      await deleteCategory(event.id);
      emit(const CategoryActionSuccess(message: 'Xoá danh mục thành công!'));
    } catch (e) {
      emit(CategoryError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
