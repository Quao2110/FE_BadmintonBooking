import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_response.dart';
import '../../core/network/dio_client.dart';
import '../models/product/product_list_query.dart';
import '../models/product/product_list_response_model.dart';
import '../models/product/product_response_model.dart';
import '../models/product/product_image_response_model.dart';
import '../models/product/create_product_request.dart';
import '../models/product/update_product_request.dart';

class ProductRemoteDataSource {
  final Dio dio;
  ProductRemoteDataSource({Dio? dio}) : dio = dio ?? DioClient.instance;

  Future<ApiResponse<ProductListResponseModel>> getAll(
    ProductListQuery query,
  ) async {
    try {
      final res = await dio.get(
        ApiConstants.products,
        queryParameters: query.toJson(),
      );
      final parsed = ApiResponse.fromJson(
        res.data,
        (json) =>
            ProductListResponseModel.fromJson(json as Map<String, dynamic>),
      );
      if (!parsed.isSuccess || parsed.result == null) return parsed;

      final imageMap = await _getProductImagesGroupedByProductId();
      final enrichedItems = parsed.result!.items
          .map(
            (item) =>
                _enrichProductWithImages(item, imageMap[item.id] ?? const []),
          )
          .toList();

      final enrichedResult = ProductListResponseModel(
        items: enrichedItems,
        page: parsed.result!.page,
        pageSize: parsed.result!.pageSize,
        totalItems: parsed.result!.totalItems,
        totalPages: parsed.result!.totalPages,
      );

      return ApiResponse<ProductListResponseModel>(
        isSuccess: parsed.isSuccess,
        message: parsed.message,
        result: enrichedResult,
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<ProductResponseModel>> getById(String id) async {
    try {
      final res = await dio.get(ApiConstants.productById(id));
      final parsed = ApiResponse.fromJson(
        res.data,
        (json) => ProductResponseModel.fromJson(json as Map<String, dynamic>),
      );
      if (!parsed.isSuccess || parsed.result == null) return parsed;

      final images = await _getProductImagesByProductId(id);
      final enriched = _enrichProductWithImages(parsed.result!, images);
      return ApiResponse<ProductResponseModel>(
        isSuccess: parsed.isSuccess,
        message: parsed.message,
        result: enriched,
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi kết nối máy chủ');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<ProductResponseModel>> create(
    CreateProductRequest request,
  ) async {
    try {
      final res = await dio.post(ApiConstants.products, data: request.toJson());
      return ApiResponse.fromJson(
        res.data,
        (json) => ProductResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi tạo sản phẩm');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<ProductResponseModel>> update(
    String id,
    UpdateProductRequest request,
  ) async {
    try {
      final res = await dio.put(
        ApiConstants.productById(id),
        data: request.toJson(),
      );
      return ApiResponse.fromJson(
        res.data,
        (json) => ProductResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi cập nhật sản phẩm');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<void>> delete(String id) async {
    try {
      final productId = id.trim();
      final res = await dio.delete(ApiConstants.productById(productId));
      final parsed = ApiResponse.fromJson(res.data, (json) => null);
      if (!parsed.isSuccess) {
        throw ServerException(
          message: parsed.message.isNotEmpty
              ? parsed.message
              : 'Không thể xoá sản phẩm.',
        );
      }
      return parsed;
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi xoá sản phẩm');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<ApiResponse<void>> uploadImage({
    required String productId,
    required XFile imageFile,
    bool isThumbnail = false,
  }) async {
    try {
      final base64Image = await _toBase64DataUri(imageFile);
      final payload = {
        'productId': productId,
        'imageUrl': base64Image,
        'isThumbnail': true,
      };
      final res = await dio.post(ApiConstants.productImages, data: payload);
      return ApiResponse.fromJson(res.data, (json) => null);
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Lỗi tải ảnh sản phẩm');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<String> _toBase64DataUri(XFile file) async {
    final bytes = await file.readAsBytes();
    final base64 = base64Encode(bytes);
    final ext = file.name.split('.').last.toLowerCase();
    final mime = switch (ext) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
    return 'data:$mime;base64,$base64';
  }

  Future<Map<String, List<ProductImageResponseModel>>>
  _getProductImagesGroupedByProductId() async {
    try {
      final res = await dio.get(ApiConstants.productImages);
      final raw = _extractListFromApiResponse(res.data);
      final images = raw
          .whereType<Map>()
          .map(
            (e) => ProductImageResponseModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
      final map = <String, List<ProductImageResponseModel>>{};
      for (final img in images) {
        if (img.productId.isEmpty) continue;
        map
            .putIfAbsent(img.productId, () => <ProductImageResponseModel>[])
            .add(img);
      }
      return map;
    } catch (_) {
      return <String, List<ProductImageResponseModel>>{};
    }
  }

  Future<List<ProductImageResponseModel>> _getProductImagesByProductId(
    String productId,
  ) async {
    try {
      final res = await dio.get(
        ApiConstants.productImages,
        queryParameters: {'productId': productId},
      );
      final raw = _extractListFromApiResponse(res.data);
      return raw
          .whereType<Map>()
          .map(
            (e) => ProductImageResponseModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    } catch (_) {
      return const <ProductImageResponseModel>[];
    }
  }

  List<dynamic> _extractListFromApiResponse(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final result = data['result'];
      if (result is List) return result;
    }
    return const <dynamic>[];
  }

  ProductResponseModel _enrichProductWithImages(
    ProductResponseModel product,
    List<ProductImageResponseModel> extraImages,
  ) {
    final mergedImages = <ProductImageResponseModel>[];
    final seenKeys = <String>{};

    void appendImages(Iterable<ProductImageResponseModel> images) {
      for (final image in images) {
        final id = image.id.trim();
        final url = image.imageUrl.trim();
        final key = id.isNotEmpty ? 'id:$id' : 'url:$url';
        if (url.isEmpty || seenKeys.contains(key)) continue;
        seenKeys.add(key);
        mergedImages.add(image);
      }
    }

    // Keep product payload images first, then append extra endpoint images.
    // This ensures we do not lose newly uploaded images if one endpoint is stale.
    appendImages(product.productImages);
    appendImages(extraImages);

    ProductImageResponseModel? thumbnail;
    ProductImageResponseModel? latestImage;
    DateTime? thumbnailTime;
    DateTime? latestTime;

    for (final image in mergedImages) {
      final url = image.imageUrl.trim();
      if (url.isEmpty) continue;
      final imageTime = DateTime.tryParse(image.createdAt ?? '');

      if (latestImage == null) {
        latestImage = image;
        latestTime = imageTime;
      } else if (imageTime != null && (latestTime == null || imageTime.isAfter(latestTime))) {
        latestImage = image;
        latestTime = imageTime;
      }

      if (image.isThumbnail) {
        if (thumbnail == null) {
          thumbnail = image;
          thumbnailTime = imageTime;
        } else if (imageTime != null && (thumbnailTime == null || imageTime.isAfter(thumbnailTime))) {
          thumbnail = image;
          thumbnailTime = imageTime;
        }
      }
    }

    final resolvedImageUrl =
        (product.imageUrl != null && product.imageUrl!.trim().isNotEmpty)
        ? product.imageUrl
      : (thumbnail?.imageUrl ?? latestImage?.imageUrl);

    return ProductResponseModel(
      id: product.id,
      categoryId: product.categoryId,
      categoryName: product.categoryName,
      productName: product.productName,
      description: product.description,
      price: product.price,
      imageUrl: resolvedImageUrl,
      stockQuantity: product.stockQuantity,
      isActive: product.isActive,
      productImages: mergedImages,
    );
  }
}
