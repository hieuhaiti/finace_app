import 'package:test/test.dart';
import '../../bin/models/category.dart';

void main() {
  group('Category Model Tests', () {
    test('Category creation with provided ID', () {
      final category = Category(
        id: '123',
        userId: 'user1',
        name: 'Food',
        icon: 'food_icon',
        color: '#FF0000',
      );

      expect(category.id, equals('123'));
      expect(category.userId, equals('user1'));
      expect(category.name, equals('Food'));
      expect(category.icon, equals('food_icon'));
      expect(category.color, equals('#FF0000'));
    });

    test('Category creation with auto-increment ID', () {
      final category1 = Category(
        userId: 'user1',
        name: 'Food',
        icon: 'food_icon',
        color: '#FF0000',
      );
      final category2 = Category(
        userId: 'user2',
        name: 'Transport',
        icon: 'transport_icon',
        color: '#00FF00',
      );

      expect(category1.id, equals('1'));
      expect(category2.id, equals('2'));
    });

    test('Category toJson', () {
      final category = Category(
        id: '123',
        userId: 'user1',
        name: 'Food',
        icon: 'food_icon',
        color: '#FF0000',
      );
      final json = category.toJson();

      expect(json['id'], equals('123'));
      expect(json['userId'], equals('user1'));
      expect(json['name'], equals('Food'));
      expect(json['icon'], equals('food_icon'));
      expect(json['color'], equals('#FF0000'));
    });

    test('Category fromJson', () {
      final json = {
        'id': '123',
        'userId': 'user1',
        'name': 'Food',
        'icon': 'food_icon',
        'color': '#FF0000',
      };
      final category = Category.fromJson(json);

      expect(category.id, equals('123'));
      expect(category.userId, equals('user1'));
      expect(category.name, equals('Food'));
      expect(category.icon, equals('food_icon'));
      expect(category.color, equals('#FF0000'));
    });

    test('Category fromJson with missing fields', () {
      final json = {
        'id': '123',
        'name': 'Food',
      };

      expect(() => Category.fromJson(json), throwsArgumentError);
    });
  });
}
