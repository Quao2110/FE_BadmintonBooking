import '../../data/models/product/create_product_request.dart';
import '../../data/models/product/update_product_request.dart';
import '../../data/models/product/product_list_query.dart';
import 'package:image_picker/image_picker.dart';
import '../entities/product_entity.dart';

abstract class IProductRepository {
  Future<List<ProductEntity>> getAll(ProductListQuery query);
  Future<ProductEntity> getById(String id);
  Future<ProductEntity> create(CreateProductRequest request);
  Future<ProductEntity> update(String id, UpdateProductRequest request);
  Future<void> uploadImage(
    String productId,
    XFile imageFile, {
    bool isThumbnail = false,
  });
  Future<void> delete(String id);
}
