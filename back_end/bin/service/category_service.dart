import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../service/service.dart';
import '../data/localstore.dart';
import '../models/category.dart';

/// CategoryService handles all category-related operations
class CategoryService with Service {
  final LocalstoreService<Category> _categoryStore;

  CategoryService() : _categoryStore = CategoryLocalstoreService();

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

  /// Add a new category handler
  Future<Response> saveCategoryHandler(Request request) async {
    try {
      final body = await parseRequestBody(request);
      final category = Category.fromJson(body);
      await validateCategoryLimit(category.userId);
      await _categoryStore.save(category.id, category);
      return Response.ok(
          jsonEncode({'message': 'Category saved successfully'}));
    } catch (e) {
      return Response.internalServerError(body: 'Error saving category: $e');
    }
  }

  /// Get all categories by user ID
  Future<Response> getCategoriesHandler(Request request, String userId) async {
    try {
      final categories = await _categoryStore.fetchWhere('userId', userId);
      final categoryList = categories.map((c) => c.toJson()).toList();
      return Response.ok(jsonEncode(categoryList));
    } catch (e) {
      return Response.internalServerError(
          body: 'Error fetching categories: $e');
    }
  }

  /// Get category details by ID
  Future<Response> getCategoriesDetailHandler(
      Request request, String categoryId) async {
    try {
      final category = await _categoryStore.fetchById(categoryId);
      if (category == null) {
        return Response.notFound('Category not found');
      }
      return Response.ok(jsonEncode(category.toJson()));
    } catch (e) {
      return Response.internalServerError(body: 'Error fetching category: $e');
    }
  }

  /// Update a category handler
  Future<Response> updateCategoryHandler(
      Request request, String categoryId) async {
    try {
      final body = await parseRequestBody(request);
      await _categoryStore.update(categoryId, body);
      return Response.ok(
          jsonEncode({'message': 'Category updated successfully'}));
    } catch (e) {
      return Response.internalServerError(body: 'Error updating category: $e');
    }
  }

  /// Delete a category handler
  Future<Response> deleteCategoryHandler(
      Request request, String categoryId) async {
    try {
      await _categoryStore.delete(categoryId);
      return Response.ok(
          jsonEncode({'message': 'Category deleted successfully'}));
    } catch (e) {
      return Response.internalServerError(body: 'Error deleting category: $e');
    }
  }
}

/// LocalstoreService implementation for Category
class CategoryLocalstoreService extends LocalstoreService<Category> {
  @override
  String get collectionName => 'categories';

  @override
  Category fromJson(Map<String, dynamic> json) => Category.fromJson(json);

  @override
  @override
  Map<String, dynamic> toJson(Category object) => object.toJson();
}
