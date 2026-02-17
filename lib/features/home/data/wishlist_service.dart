import 'package:xpress_nepal/core/api/api_client.dart';
import 'package:xpress_nepal/core/constants/api_constants.dart';
import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';

class WishlistService {
  final ApiClient apiClient;
  WishlistService(this.apiClient);

  Future<List<ProductEntity>> fetchWishlist() async {
    final response = await apiClient.get('${ApiConstants.apiUrl}/wishlist');
    final data = response.data;
    // If backend returns { success, message, data: { products: [...] } }
    final products = (data['data']?['products'] ?? []) as List;
    return products.map((e) => ProductEntity.fromJson(e)).toList();
  }

  Future<void> addToWishlist(String productId) async {
    await apiClient.post(
      '${ApiConstants.apiUrl}/wishlist/add',
      data: {'productId': productId},
    );
  }

  Future<void> removeFromWishlist(String productId) async {
    await apiClient.delete('${ApiConstants.apiUrl}/wishlist/remove/$productId');
  }
}
