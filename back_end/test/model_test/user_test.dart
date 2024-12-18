import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import '../../bin/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('User creation with provided ID', () {
      final user = User(id: '123', username: 'testuser', password: 'testpass');

      expect(user.id, equals('123'));
      expect(user.username, equals('testuser'));
      expect(user.password, equals('testpass'));
    });

    test('User creation with UUID', () {
      final user = User(username: 'testuser', password: 'testpass');

      expect(user.id, isNotNull);
      expect(Uuid.isValidUUID(fromString: user.id), isTrue);
      expect(user.username, equals('testuser'));
      expect(user.password, equals('testpass'));
    });

    test('User toJson', () {
      final user = User(id: '123', username: 'testuser', password: 'testpass');
      final json = user.toJson();

      expect(json['id'], equals('123'));
      expect(json['username'], equals('testuser'));
      expect(json['password'], equals('testpass'));
    });

    test('User fromJson', () {
      final json = {
        'id': '123',
        'username': 'testuser',
        'password': 'testpass',
      };
      final user = User.fromJson(json);

      expect(user.id, equals('123'));
      expect(user.username, equals('testuser'));
      expect(user.password, equals('testpass'));
    });

    test('User fromJson with missing fields', () {
      final json = {
        'id': '123',
        'username': 'testuser',
      };

      expect(() => User.fromJson(json), throwsArgumentError);
    });
  });
}