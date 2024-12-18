import 'dart:convert';
import 'package:test/test.dart';
import 'package:shelf/shelf.dart';
import 'package:localstore/localstore.dart';
import '../../bin/service/category_service.dart';
import '../../bin/models/category.dart';

void main() {
  final categoryService = CategoryService();
  final localstoreService = CategoryLocalstoreService();

  setUp(() async {
    // Clear the database before each test
    await Localstore.instance.collection('categories').delete();
  });

  group('CategoryService Tests', () {
    test('Save Category Handler', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/categories'),
        body: jsonEncode({
          'userId': 'user1',
          'name': 'Food',
          'icon': '🍴',
          'color': '#FF5733'
        }),
      );
      final response = await categoryService.saveCategoryHandler(request);

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json['message'], equals('Category saved successfully'));

      final categories = await localstoreService.fetchAll();
      expect(categories.length, equals(1));
      expect(categories.first.name, equals('Food'));
    });

    test('Get Categories Handler', () async {
      final category = Category(
        userId: 'user1',
        name: 'Food',
        icon: '🍴',
        color: '#FF5733',
      );
      await localstoreService.save(category.id, category);

      final request = Request('GET', Uri.parse('http://localhost/categories/user1'));
      final response = await categoryService.getCategoriesHandler(request, 'user1');

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json.length, equals(1));
      expect(json[0]['name'], equals('Food'));
    });

    test('Get Category Details Handler', () async {
      final category = Category(
        id: 'cat1',
        userId: 'user1',
        name: 'Food',
        icon: '🍴',
        color: '#FF5733',
      );
      await localstoreService.save(category.id, category);

      final request = Request('GET', Uri.parse('http://localhost/categories/cat1'));
      final response = await categoryService.getCategoriesDetailHandler(request, 'cat1');

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json['name'], equals('Food'));
    });

    test('Update Category Handler', () async {
      final category = Category(
        id: 'cat1',
        userId: 'user1',
        name: 'Food',
        icon: '🍴',
        color: '#FF5733',
      );
      await localstoreService.save(category.id, category);

      final request = Request(
        'PUT',
        Uri.parse('http://localhost/categories/cat1'),
        body: jsonEncode({'name': 'Updated Food', 'icon': '🍕', 'color': '#00FF00'}),
      );
      final response = await categoryService.updateCategoryHandler(request, 'cat1');

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json['message'], equals('Category updated successfully'));

      final updatedCategory = await localstoreService.fetchById('cat1');
      expect(updatedCategory, isNotNull);
      expect(updatedCategory!.name, equals('Updated Food'));
      expect(updatedCategory.icon, equals('🍕'));
      expect(updatedCategory.color, equals('#00FF00'));
    });

    test('Delete Category Handler', () async {
      final category = Category(
        id: 'cat1',
        userId: 'user1',
        name: 'Food',
        icon: '🍴',
        color: '#FF5733',
      );
      await localstoreService.save(category.id, category);

      final request = Request('DELETE', Uri.parse('http://localhost/categories/cat1'));
      final response = await categoryService.deleteCategoryHandler(request, 'cat1');

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json['message'], equals('Category deleted successfully'));

      final deletedCategory = await localstoreService.fetchById('cat1');
      expect(deletedCategory, isNull);
    });
  });
}