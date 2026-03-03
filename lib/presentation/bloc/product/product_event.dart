import 'package:equatable/equatable.dart';
import '../../../data/models/product/create_product_request.dart';
import '../../../data/models/product/update_product_request.dart';
import '../../../data/models/product/product_list_query.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class GetProductsEvent extends ProductEvent {
  final ProductListQuery query;
  const GetProductsEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class GetProductByIdEvent extends ProductEvent {
  final String id;
  const GetProductByIdEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class CreateProductEvent extends ProductEvent {
  final CreateProductRequest request;
  const CreateProductEvent(this.request);
  @override
  List<Object?> get props => [request];
}

class UpdateProductEvent extends ProductEvent {
  final String id;
  final UpdateProductRequest request;
  const UpdateProductEvent(this.id, this.request);
  @override
  List<Object?> get props => [id, request];
}

class DeleteProductEvent extends ProductEvent {
  final String id;
  const DeleteProductEvent(this.id);
  @override
  List<Object?> get props => [id];
}
