import 'package:flutter/material.dart';
import 'package:xpress_nepal/features/category/domain/entities/category_entity.dart';
import 'package:xpress_nepal/features/category/domain/repositories/category_repository.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository _repository;

  List<CategoryEntity> _categories = [];
  bool _isLoading = false;
  String? _error;

  CategoryViewModel({required CategoryRepository repository})
    : _repository = repository;

  List<CategoryEntity> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Notify loading state

    try {
      _categories = await _repository.getCategories();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
