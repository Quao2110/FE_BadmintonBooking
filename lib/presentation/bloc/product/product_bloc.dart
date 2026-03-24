import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/product_repository_impl.dart';
import '../../../domain/usecases/product/get_products.dart';
import '../../../domain/usecases/product/get_product_by_id.dart';
import '../../../domain/usecases/product/create_product.dart';
import '../../../domain/usecases/product/update_product.dart';
import '../../../domain/usecases/product/delete_product.dart';
import '../../../domain/usecases/product/upload_product_image.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProducts;
  final GetProductByIdUseCase getProductById;
  final CreateProductUseCase createProduct;
  final UpdateProductUseCase updateProduct;
  final DeleteProductUseCase deleteProduct;
  final UploadProductImageUseCase uploadProductImage;

  ProductBloc({
    required this.getProducts,
    required this.getProductById,
    required this.createProduct,
    required this.updateProduct,
    required this.deleteProduct,
    required this.uploadProductImage,
  }) : super(const ProductInitial()) {
    on<GetProductsEvent>(_onGetAll);
    on<GetProductByIdEvent>(_onGetById);
    on<CreateProductEvent>(_onCreate);
    on<UpdateProductEvent>(_onUpdate);
    on<DeleteProductEvent>(_onDelete);
    on<UploadProductImageEvent>(_onUploadImage);
  }

  factory ProductBloc.create() {
    final repo = ProductRepository();
    return ProductBloc(
      getProducts: GetProductsUseCase(repo),
      getProductById: GetProductByIdUseCase(repo),
      createProduct: CreateProductUseCase(repo),
      updateProduct: UpdateProductUseCase(repo),
      deleteProduct: DeleteProductUseCase(repo),
      uploadProductImage: UploadProductImageUseCase(repo),
    );
  }

  Future<void> _onGetAll(
    GetProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      final items = await getProducts(event.query);
      emit(ProductListLoaded(items));
    } catch (e) {
      emit(ProductError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onGetById(
    GetProductByIdEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      final item = await getProductById(event.id);
      emit(ProductLoaded(item));
    } catch (e) {
      emit(ProductError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onCreate(
    CreateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      await createProduct(event.request);
      emit(const ProductActionSuccess(message: 'Tạo sản phẩm thành công!'));
    } catch (e) {
      emit(ProductError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onUpdate(
    UpdateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      await updateProduct(event.id, event.request);
      emit(
        const ProductActionSuccess(message: 'Cập nhật sản phẩm thành công!'),
      );
    } catch (e) {
      emit(ProductError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDelete(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      await deleteProduct(event.id);
      emit(const ProductActionSuccess(message: 'Xoá sản phẩm thành công!'));
    } catch (e) {
      emit(ProductError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onUploadImage(
    UploadProductImageEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      await uploadProductImage(
        event.productId,
        event.imageFile,
        isThumbnail: event.isThumbnail,
      );
      emit(const ProductActionSuccess(message: 'Tải ảnh sản phẩm thành công!'));
    } catch (e) {
      emit(ProductError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
