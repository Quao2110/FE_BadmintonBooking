import '../datasources/product_api_service.dart';
import '../models/product/product_response_model.dart';
import '../models/product/product_image_response_model.dart';
import '../models/product/product_list_query.dart';
import '../models/product/create_product_request.dart';
import '../models/product/update_product_request.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_image_entity.dart';
import '../../domain/repositories/i_product_repository.dart';

class ProductRepository implements IProductRepository {
  final ProductRemoteDataSource _dataSource;
  ProductRepository({ProductRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? ProductRemoteDataSource();

  @override
  Future<List<ProductEntity>> getAll(ProductListQuery query) async {
    final res = await _dataSource.getAll(query);
    if (res.isSuccess && res.result != null) {
      return res.result!.items.map(_mapToEntity).toList();
    }
    throw Exception(res.message);
  }

  @override
  Future<ProductEntity> getById(String id) async {
    final res = await _dataSource.getById(id);
    if (res.isSuccess && res.result != null) {
      return _mapToEntity(res.result!);
    }
    throw Exception(res.message);
  }

  @override
  Future<ProductEntity> create(CreateProductRequest request) async {
    final res = await _dataSource.create(request);
    if (res.isSuccess && res.result != null) {
      return _mapToEntity(res.result!);
    }
    throw Exception(res.message);
  }

  @override
  Future<ProductEntity> update(String id, UpdateProductRequest request) async {
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

  ProductEntity _mapToEntity(ProductResponseModel m) {
    return ProductEntity(
      id: m.id,
      categoryId: m.categoryId,
      categoryName: m.categoryName,
      productName: m.productName,
      description: m.description,
      price: m.price,
      imageUrl: m.imageUrl,
      stockQuantity: m.stockQuantity,
      isActive: m.isActive,
      productImages: m.productImages.map(_mapImageToEntity).toList(),
    );
  }

  ProductImageEntity _mapImageToEntity(ProductImageResponseModel m) {
    return ProductImageEntity(
      id: m.id,
      productId: m.productId,
      imageUrl: m.imageUrl,
      isThumbnail: m.isThumbnail,
      createdAt: m.createdAt,
    );
  }
}
