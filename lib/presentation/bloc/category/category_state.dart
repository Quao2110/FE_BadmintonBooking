import 'package:equatable/equatable.dart';
import '../../../domain/entities/category_entity.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryListLoaded extends CategoryState {
  final List<CategoryEntity> categories;
  const CategoryListLoaded(this.categories);
  @override
  List<Object?> get props => [categories];
}

class CategoryLoaded extends CategoryState {
  final CategoryEntity category;
  const CategoryLoaded(this.category);
  @override
  List<Object?> get props => [category];
}

class CategoryActionSuccess extends CategoryState {
  final String message;
  const CategoryActionSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class CategoryError extends CategoryState {
  final String message;
  const CategoryError(this.message);
  @override
  List<Object?> get props => [message];
}
