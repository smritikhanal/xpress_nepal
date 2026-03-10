import 'package:dio/dio.dart';
import '../models/cart_item_model.dart';
import 'cart_remote_datasource.dart';

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final Dio dio;

  CartRemoteDataSourceImpl(this.dio);

  @override
  Future<List<CartItemModel>> fetchCart() async {
    final res = await dio.get('/cart');
    // res.data is likely {success: true, data: {...}}
    // so items should be in res.data['data']['items']
    final data = res.data['data'];
    if (data == null || data['items'] == null) return [];
    
    return (data['items'] as List)
        .map((e) => CartItemModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> addToCart(String productId, double price, {Map<String, dynamic>? selectedAttributes}) async {
    final Map<String, dynamic> data = {'productId': productId, 'quantity': 1};
    if (selectedAttributes != null) {
      data['attributes'] = selectedAttributes;
    }
    
    await dio.post(
      '/cart/add',
      data: data,
    );
  }

  @override
  Future<void> updateQuantity(String productId, int quantity) async {
    await dio.put(
      '/cart/update',
      data: {'productId': productId, 'quantity': quantity},
    );
  }

  @override
  Future<void> removeItem(String productId) async {
    await dio.delete('/cart/remove/$productId');
  }

  @override
  Future<void> clearCart() async {
    await dio.delete('/cart/clear');
  }
}
