import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/shop_api_service.dart';
import '../../../data/repositories/shop_repository_impl.dart';
import '../../../domain/repositories/i_shop_repository.dart';
import 'shop_event.dart';
import 'shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final IShopRepository repository;

  ShopBloc({required this.repository}) : super(const ShopInitial()) {
    on<LoadShopInfo>(_onLoadShopInfo);
    on<CalculateDistance>(_onCalculateDistance);
    on<UpdateShopEvent>(_onUpdateShop);
  }

  factory ShopBloc.create() {
    return ShopBloc(
      repository: ShopRepositoryImpl(remoteDataSource: ShopRemoteDataSource()),
    );
  }

  Future<void> _onLoadShopInfo(
    LoadShopInfo event,
    Emitter<ShopState> emit,
  ) async {
    final currentState = state;
    double? lat;
    double? lng;

    if (currentState is ShopInitial) {
      lat = currentState.userLat;
      lng = currentState.userLng;
    } else if (currentState is ShopLoading) {
      lat = currentState.userLat;
      lng = currentState.userLng;
    }

    emit(ShopLoading(userLat: lat, userLng: lng));
    try {
      final shop = await repository.getShopInfo();
      double? distance;
      if (lat != null && lng != null) {
        distance = await repository.calculateDistance(lat, lng);
      }
      emit(
        ShopLoaded(shop: shop, userLat: lat, userLng: lng, distance: distance),
      );
    } catch (e) {
      emit(ShopError(message: e.toString()));
    }
  }

  Future<void> _onCalculateDistance(
    CalculateDistance event,
    Emitter<ShopState> emit,
  ) async {
    final currentState = state;
    if (currentState is ShopLoaded) {
      try {
        final distance = await repository.calculateDistance(
          event.userLat,
          event.userLng,
        );
        emit(
          currentState.copyWith(
            distance: distance,
            userLat: event.userLat,
            userLng: event.userLng,
          ),
        );
      } catch (e) {
        // Ignore errors for distance
      }
    } else if (currentState is ShopInitial) {
      emit(ShopInitial(userLat: event.userLat, userLng: event.userLng));
    } else if (currentState is ShopLoading) {
      emit(ShopLoading(userLat: event.userLat, userLng: event.userLng));
    }
  }

  Future<void> _onUpdateShop(
    UpdateShopEvent event,
    Emitter<ShopState> emit,
  ) async {
    emit(const ShopUpdating());
    try {
      final updatedShop = await repository.updateShop(
        event.shopId,
        event.request,
      );
      emit(
        ShopUpdateSuccess(
          shop: updatedShop,
          message: 'Cập nhật shop thành công',
        ),
      );
    } catch (e) {
      emit(ShopError(message: e.toString()));
    }
  }
}
