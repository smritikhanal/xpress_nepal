import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xpress_nepal/core/services/api_service.dart';
import 'package:xpress_nepal/features/category/data/datasources/category_remote_datasource.dart';
import 'package:xpress_nepal/features/category/data/repositories/category_repository_impl.dart';
import 'package:xpress_nepal/features/category/presentation/view_model/category_view_model.dart';

class CategoryProvider extends InheritedWidget {
  final CategoryViewModel categoryViewModel;

  const CategoryProvider({
    Key? key,
    required this.categoryViewModel,
    required Widget child,
  }) : super(key: key, child: child);

  static CategoryProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CategoryProvider>();
  }

  // Singleton instance
  // Singleton instance
  static CategoryProvider instance = _createInstance();

  @visibleForTesting
  static set setInstance(CategoryProvider value) {
    instance = value;
  }

  static CategoryProvider _createInstance() {
    final apiService = ApiService();
    final remoteDataSource = CategoryRemoteDataSource(apiService: apiService);
    final repository = CategoryRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );
    final viewModel = CategoryViewModel(repository: repository);

    return CategoryProvider(
      categoryViewModel: viewModel,
      child: const SizedBox(),
    );
  }

  @override
  bool updateShouldNotify(CategoryProvider oldWidget) {
    return categoryViewModel != oldWidget.categoryViewModel;
  }
}
