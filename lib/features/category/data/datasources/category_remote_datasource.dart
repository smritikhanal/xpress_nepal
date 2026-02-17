import 'package:xpress_nepal/core/constants/api_constants.dart';
import 'package:xpress_nepal/core/services/api_service.dart';
import 'package:xpress_nepal/features/category/data/models/category_model.dart';

class CategoryRemoteDataSource {
  final ApiService _apiService;

  CategoryRemoteDataSource({required ApiService apiService})
    : _apiService = apiService;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiService.get('${ApiConstants.apiUrl}/categories');

    if (response.success && response.data != null) {
      final dynamic responseData = response.data!['data'];
      List<dynamic> list = [];

      if (responseData is Map && responseData.containsKey('categories')) {
        list = responseData['categories'];
      } else if (responseData is List) {
        list = responseData;
      } else if (response.data!.containsKey('categories')) {
        list = response.data!['categories'];
      }

      return list.map((e) => CategoryModel.fromJson(e)).toList();
    } else {
      throw Exception(response.message ?? 'Failed to load categories');
    }
  }
}
