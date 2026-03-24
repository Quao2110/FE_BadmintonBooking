import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/utils/helpers.dart';
import '../models/commerce/cart_model.dart';
import '../models/commerce/order_model.dart';
import '../models/commerce/support_message_model.dart';

class CommerceApiService {
  final Dio dio;

  CommerceApiService({Dio? dio}) : dio = dio ?? DioClient.instance;

  Future<CartModel> getCart() async {
    final payload = await _get(ApiConstants.cart);
    final result = _extractResult(payload);
    return CartModel.fromJson(_toMap(result));
  }

  Future<void> addToCart({
    required String productId,
    required int quantity,
  }) async {
    await _post(ApiConstants.cartAdd, {
      'productId': productId,
      'quantity': quantity,
    });
  }

  Future<void> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    await _put(ApiConstants.cartItemById(cartItemId), {'quantity': quantity});
  }

  Future<void> removeCartItem(String cartItemId) async {
    await _delete(ApiConstants.cartItemById(cartItemId));
  }

  Future<void> clearCart() async {
    await _delete(ApiConstants.cartClear);
  }

  Future<OrderModel> checkout({
    required String address,
    required String phone,
    String? note,
    required String paymentMethod,
  }) async {
    final payload = await _post(ApiConstants.orderCheckout, {
      'deliveryAddress': address,
      'paymentMethod': paymentMethod,
    });
    return OrderModel.fromJson(_toMap(_extractResult(payload)));
  }

  Future<List<OrderModel>> getMyOrders() async {
    final payload = await _get(ApiConstants.orderMyOrders);
    final result = _extractResult(payload);
    final list = _extractList(result);
    return list.map((e) => OrderModel.fromJson(_toMap(e))).toList();
  }

  Future<List<OrderModel>> getOrders({
    String? userId,
    String? orderStatus,
    String? paymentStatus,
    int page = 1,
    int pageSize = 10,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (userId != null && userId.trim().isNotEmpty) 'userId': userId.trim(),
      if (orderStatus != null && orderStatus.trim().isNotEmpty)
        'orderStatus': orderStatus.trim(),
      if (paymentStatus != null && paymentStatus.trim().isNotEmpty)
        'paymentStatus': paymentStatus.trim(),
    };

    final payload = await _get(ApiConstants.orders, query: query);
    final result = _extractResult(payload);
    final list = _extractList(result);
    return list.map((e) => OrderModel.fromJson(_toMap(e))).toList();
  }

  Future<OrderModel> getOrderById(String orderId) async {
    final payload = await _get(ApiConstants.orderById(orderId));
    return OrderModel.fromJson(_toMap(_extractResult(payload)));
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await _put(ApiConstants.orderUpdateStatus(orderId), {'newStatus': status});
  }

  Future<void> cancelOrder(String orderId) async {
    await _post(ApiConstants.orderCancel(orderId), {});
  }

  Future<String> createVnPayLink({
    required String txnRef,
    required int amountVnd,
    required String orderInfo,
    String? ipAddr,
  }) async {
    final payload = await _post(ApiConstants.paymentCreateVnpayLink, {
      'txnRef': txnRef,
      'amountVnd': amountVnd,
      'orderInfo': orderInfo,
      'ipAddr': ipAddr,
    });

    final result = _toMap(_extractResult(payload));
    final url =
        (result['paymentUrl'] ?? result['url'] ?? result['payUrl'] ?? '')
            .toString();
    if (url.isEmpty) {
      throw ServerException(message: 'Khong lay duoc payment url tu he thong.');
    }
    return url;
  }

  Future<bool> confirmVnPayReturn(Map<String, String> queryParams) async {
    final payload = await _get(
      ApiConstants.paymentVnpayReturn,
      query: queryParams,
    );
    final result = _toMap(_extractResult(payload));
    final isSuccess = result['isSuccess'];
    if (isSuccess is bool) {
      return isSuccess;
    }
    return false;
  }

  Future<List<SupportMessageModel>> getMessages() async {
    final payload = await _get(ApiConstants.messages);
    final list = _extractList(_extractResult(payload));
    final currentUserId = await _getCurrentUserId();

    return list.map((e) {
      final map = _toMap(e);
      final senderId = (map['senderId'] ?? '').toString();
      final isMe = currentUserId != null && senderId == currentUserId;

      map['senderRole'] = isMe ? 'Customer' : 'Admin';
      map['senderName'] = isMe ? 'Ban' : 'Ho tro';
      map['content'] = map['content'] ?? map['messageText'];
      map['createdAt'] = map['createdAt'] ?? map['sentAt'];

      return SupportMessageModel.fromJson(map);
    }).toList();
  }

  Future<SupportMessageModel?> sendMessage(String content) async {
    await _post(ApiConstants.messagesSend, {
      'messageText': content,
      'imageUrl': '',
    });

    // Backend returns only { success, messageId }, no full message payload.
    return null;
  }

  Future<String?> _getCurrentUserId() async {
    final token = await SecureStorage.getToken();
    if (token == null || token.isEmpty) return null;
    return JwtHelper.getUserId(token);
  }

  Future<dynamic> _get(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await dio.get(path, queryParameters: query);
      return res.data;
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Server error');
    }
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    try {
      final res = await dio.post(path, data: body);
      return res.data;
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Server error');
    }
  }

  Future<dynamic> _put(String path, Map<String, dynamic> body) async {
    try {
      final res = await dio.put(path, data: body);
      return res.data;
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Server error');
    }
  }

  Future<dynamic> _delete(String path) async {
    try {
      final res = await dio.delete(path);
      return res.data;
    } on DioException catch (e) {
      if (e.error is Exception) throw e.error!;
      throw ServerException(message: e.message ?? 'Server error');
    }
  }

  dynamic _extractResult(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      if (payload.containsKey('isSuccess')) {
        final ok = payload['isSuccess'] == true;
        if (!ok) {
          throw ServerException(
            message: (payload['message'] ?? 'Request failed').toString(),
          );
        }
      }

      if (payload.containsKey('result')) {
        return payload['result'];
      }
      if (payload.containsKey('data')) {
        return payload['data'];
      }
      return payload;
    }
    return payload;
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List<dynamic>) return data;
    if (data is Map<String, dynamic>) {
      final items = data['items'];
      if (items is List<dynamic>) return items;
      final messages = data['messages'];
      if (messages is List<dynamic>) return messages;
    }
    return const [];
  }

  Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }
}
