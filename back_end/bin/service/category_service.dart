import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../service/service.dart';
import '../data/json_storage.dart';
import '../models/category.dart';

class CategoryJsonStorage extends JsonStorage<Category> {
  @override
  CategoryJsonStorage() : super('bin/data/json/categories.json');

  @override
  Category fromJson(Map<String, dynamic> json) => Category.fromJson(json);

  @override
  @override
  Map<String, dynamic> toJson(Category object) => object.toJson();
}

/// CategoryService handles all category-related operations
class CategoryService with Service {
  final CategoryJsonStorage _categoryStore = CategoryJsonStorage();
  final _headers = {'Content-Type': 'application/json'};

  /// Initialize default categories for a user
  Future<void> initializeDefaultCategories(String userId) async {
    final defaultCategories = [
      {'name': 'Other', 'icon': '🤷‍♂️', 'color': '#A0A0A0'},
      {'name': 'Food', 'icon': '🍴', 'color': '#FF5733'},
      {'name': 'Transportation', 'icon': '🚗', 'color': '#3498DB'},
      {'name': 'Bills', 'icon': '🧾', 'color': '#FFC300'},
      {'name': 'Rent', 'icon': '🏠', 'color': '#2ECC71'},
      {'name': 'Clothing', 'icon': '🧥', 'color': '#9B59B6'},
      {'name': 'Health', 'icon': '🏥', 'color': '#E74C3C'},
      {'name': 'Entertainment', 'icon': '🎮', 'color': '#F39C12'},
      {'name': 'Charity', 'icon': '💝', 'color': '#D35400'},
      {'name': 'Debt', 'icon': '💳', 'color': '#34495E'},
    ];

    for (var category in defaultCategories) {
      final newCategory = Category(
        userId: userId,
        name: category['name']!,
        icon: category['icon']!,
        color: category['color']!,
      );
      await _categoryStore.save(newCategory.id, newCategory);
    }
  }

  /// Validate category limit
  Future<void> validateCategoryLimit(String userId) async {
    final categories = await _categoryStore.fetchWhere('userId', userId);
    if (categories.length >= 10) {
      throw Exception(
          'You can only have up to 10 categories. Please delete an existing one.');
    }
  }

  /// Add a new category with duplicate name validation
  Future<Response> saveCategoryHandler(Request request) async {
    try {
      final body = await parseRequestBody(request);

      // Tạo danh mục từ dữ liệu request
      final category = Category.fromJson(body);

      // Lấy tất cả các danh mục của user
      final existingCategories =
          await _categoryStore.fetchWhere('userId', category.userId);

      // Kiểm tra trùng lặp tên
      final isDuplicate =
          existingCategories.any((c) => c.name == category.name);
      if (isDuplicate) {
        return Response(
          409,
          body: jsonEncode({
            'error': 'Category name already exists',
            'suggestion': 'Please choose a different name for the category.'
          }),
          headers: _headers,
        );
      }

      await _categoryStore.save(category.id, category);
      return Response.ok(
          jsonEncode({
            'message': 'Category saved successfully',
            'id': category.id,
          }),
          headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: jsonEncode({
            'error': 'Error saving category',
            'details': e.toString(),
            'suggestion': 'Ensure the request data is valid and not duplicated.'
          }),
          headers: _headers);
    }
  }

  /// Get all categories by user ID
  Future<Response> getCategoriesHandler(Request request, String userId) async {
    try {
      final categories = await _categoryStore.fetchWhere('userId', userId);
      final categoryList = categories.map((c) => c.toJson()).toList();
      return Response.ok(jsonEncode(categoryList), headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: 'Error fetching categories: $e', headers: _headers);
    }
  }

  /// Get category details by ID
  Future<Response> getCategoriesDetailHandler(
      Request request, String categoryId) async {
    try {
      final category = await _categoryStore.fetchById(categoryId);
      if (category == null) {
        return Response.notFound('Category not found', headers: _headers);
      }
      return Response.ok(jsonEncode(category.toJson()), headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: 'Error fetching category: $e', headers: _headers);
    }
  }

  /// Update a category handler
  Future<Response> updateCategoryHandler(
      Request request, String categoryId) async {
    try {
      // Lấy dữ liệu cập nhật từ request
      final updates = await parseRequestBody(request);

      // Kiểm tra danh mục có tồn tại không
      final existingCategory = await _categoryStore.fetchById(categoryId);
      if (existingCategory == null) {
        return Response.notFound('Category not found', headers: _headers);
      }

      // Tạo danh mục mới bằng cách kết hợp dữ liệu cũ và mới
      final updatedCategory = Category(
        id: categoryId,
        userId: updates['userId'] ?? existingCategory.userId,
        name: updates['name'] ?? existingCategory.name,
        icon: updates['icon'] ?? existingCategory.icon,
        color: updates['color'] ?? existingCategory.color,
      );

      // Lưu danh mục đã cập nhật
      await _categoryStore.save(categoryId, updatedCategory);

      return Response.ok(
          jsonEncode({'message': 'Category updated successfully'}),
          headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: 'Error updating category: $e', headers: _headers);
    }
  }

  /// Delete a category handler
  Future<Response> deleteCategoryHandler(
      Request request, String categoryId) async {
    try {
      await _categoryStore.delete(categoryId);
      return Response.ok(
          jsonEncode({'message': 'Category deleted successfully'}),
          headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: 'Error deleting category: $e', headers: _headers);
    }
  }
}
