import 'package:equatable/equatable.dart';
import '../../../data/models/category/create_category_request.dart';
import '../../../data/models/category/update_category_request.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class GetAllCategoriesEvent extends CategoryEvent {
  const GetAllCategoriesEvent();
}

class GetCategoryByIdEvent extends CategoryEvent {
  final String id;
  const GetCategoryByIdEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class CreateCategoryEvent extends CategoryEvent {
  final CreateCategoryRequest request;
  const CreateCategoryEvent(this.request);
  @override
  List<Object?> get props => [request];
}

class UpdateCategoryEvent extends CategoryEvent {
  final String id;
  final UpdateCategoryRequest request;
  const UpdateCategoryEvent(this.id, this.request);
  @override
  List<Object?> get props => [id, request];
}

class DeleteCategoryEvent extends CategoryEvent {
  final String id;
  const DeleteCategoryEvent(this.id);
  @override
  List<Object?> get props => [id];
}
