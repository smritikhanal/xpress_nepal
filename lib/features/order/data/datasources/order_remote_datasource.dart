import 'package:dio/dio.dart';
import '../models/order_model.dart';
import '../../domain/models/order_entity.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder(Map<String, dynamic> data);
  Future<List<OrderModel>> getMyOrders(int page, int limit);
  Future<OrderModel> getOrderById(String id);
  Future<List<OrderModel>> getSellerOrders(int page, int limit);
  Future<OrderModel> updateOrderStatus(String id, String status);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio _dio;

  OrderRemoteDataSourceImpl(this._dio);

  @override
  Future<OrderModel> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/orders', data: data);
      
      if (response.statusCode == 201) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<OrderModel>> getMyOrders(int page, int limit) async {
    try {
      final response = await _dio.get(
        '/orders',
        queryParameters: {'page': page, 'limit': limit},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['orders'];
        return data.map((item) => OrderModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    try {
      final response = await _dio.get('/orders/$id');
      
      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load order details');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<OrderModel>> getSellerOrders(int page, int limit) async {
    try {
      final response = await _dio.get(
        '/orders/seller/my-orders',
        queryParameters: {'page': page, 'limit': limit},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['orders'];
        return data.map((item) => OrderModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load seller orders');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OrderModel> updateOrderStatus(String id, String status) async {
    try {
      final response = await _dio.put(
        '/orders/$id/status',
        data: {'orderStatus': status},
      );
      
      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update order status');
      }
    } catch (e) {
      rethrow;
    }
  }
}
