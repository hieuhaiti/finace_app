import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../service/service.dart';
import '../models/category.dart';
import '../data/category_storage.dart';

/// CategoryService handles all category-related operations
class CategoryService with Service {
  final CategoryStorage categoryStorage =
      CategoryStorage('bin/data/json/categories.json');
  final _headers = {'Content-Type': 'application/json'};

  /// Initialize default categories for a user
  Future<void> initializeDefaultCategories(String userId) async {
    final defaultCategories = [
      {'name': 'Other', 'icon': '🤷‍♂️', 'color': '#D3D3D3'},
      {'name': 'Food', 'icon': '🍴', 'color': '#FF6347'},
      {'name': 'Transportation', 'icon': '🚗', 'color': '#1E90FF'},
      {'name': 'Bills', 'icon': '🧾', 'color': '#FFD700'},
      {'name': 'Rent', 'icon': '🏠', 'color': '#32CD32'},
      {'name': 'Clothing', 'icon': '🧥', 'color': '#8A2BE2'},
      {'name': 'Health', 'icon': '🏥', 'color': '#FF4500'},
      {'name': 'Entertainment', 'icon': '🎮', 'color': '#FFA500'},
      {'name': 'Charity', 'icon': '💝', 'color': '#FF8C00'},
      {'name': 'Debt', 'icon': '💳', 'color': '#2F4F4F'},
      {'name': 'Salary', 'icon': '💵', 'color': '#3CB371'},
    ];

    for (var category in defaultCategories) {
      final newCategory = Category(
        userId: userId,
        name: category['name']!,
        icon: category['icon']!,
        color: category['color']!,
      );
      await categoryStorage.save(newCategory.id, newCategory);
    }
  }

  /// Validate category limit
  Future<void> validateCategoryLimit(String userId) async {
    final categories = await categoryStorage.fetchWhere('userId', userId);
    if (categories.length >= 20) {
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
          await categoryStorage.fetchWhere('userId', category.userId);

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

      await categoryStorage.save(category.id, category);
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
      final categories = await categoryStorage.fetchWhere('userId', userId);
      if (categories.isEmpty) {
        await initializeDefaultCategories(userId);
        return Response.ok(
            jsonEncode({
              'message': 'Initialized default category.',
            }),
            headers: _headers);
      }
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
      final category = await categoryStorage.fetchById(categoryId);
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
      final existingCategory = await categoryStorage.fetchById(categoryId);
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
      await categoryStorage.save(categoryId, updatedCategory);

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
      await categoryStorage.delete(categoryId);
      return Response.ok(
          jsonEncode({'message': 'Category deleted successfully'}),
          headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: 'Error deleting category: $e', headers: _headers);
    }
  }
}
