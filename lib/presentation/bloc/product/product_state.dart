import 'package:equatable/equatable.dart';
import '../../../domain/entities/product_entity.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductListLoaded extends ProductState {
  final List<ProductEntity> products;
  const ProductListLoaded(this.products);
  @override
  List<Object?> get props => [products];
}

class ProductLoaded extends ProductState {
  final ProductEntity product;
  const ProductLoaded(this.product);
  @override
  List<Object?> get props => [product];
}

class ProductActionSuccess extends ProductState {
  final String message;
  const ProductActionSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
  @override
  List<Object?> get props => [message];
}
