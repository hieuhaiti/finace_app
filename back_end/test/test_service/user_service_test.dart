import 'dart:convert';
import 'package:localstore/localstore.dart';
import 'package:test/test.dart';
import 'package:shelf/shelf.dart';
import '../../bin/service/user_service.dart';
import '../../bin/models/user.dart';

void main() {
  final userService = UserService();
  final localstoreService = UserLocalstoreService();

  setUp(() async {
    // Clear the database before each test
    await Localstore.instance.collection('users').delete();
  });

  group('UserService Tests', () {
    test('Sign Up Handler', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/auth/signup'),
        body: jsonEncode({'username': 'testuser', 'password': 'testpass'}),
      );
      final response = await userService.signUpHandler(request);

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json['message'], equals('User created successfully'));
      expect(json['userId'], isNotNull);

      final users = await localstoreService.fetchAll();
      expect(users.length, equals(1));
      expect(users.first.username, equals('testuser'));
    });

    test('Sign In Handler', () async {
      final user = User(id: 'testid', username: 'testuser', password: 'testpass');
      await localstoreService.save(user.id, user);

      final request = Request(
        'POST',
        Uri.parse('http://localhost/auth/signin'),
        body: jsonEncode({'username': 'testuser', 'password': 'testpass'}),
      );
      final response = await userService.signInHandler(request);

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json['message'], equals('Sign in successful'));
      expect(json['userId'], equals('testid'));
    });

    test('Get User by ID Handler', () async {
      final user = User(id: 'testid', username: 'testuser', password: 'testpass');
      await localstoreService.save(user.id, user);

      final request = Request('GET', Uri.parse('http://localhost/users/${user.id}'));
      final response = await userService.getUserByIdHandler(request, user.id);

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json['username'], equals('testuser'));
    });

    test('Get User by Username Handler', () async {
      final user = User(id: 'testid', username: 'testuser', password: 'testpass');
      await localstoreService.save(user.id, user);

      final request = Request(
          'GET', Uri.parse('http://localhost/users/username/${user.username}'));
      final response =
          await userService.getUserByUsernameHandler(request, user.username);

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json['username'], equals('testuser'));
    });

    test('Update User Handler', () async {
      final user = User(id: 'testid', username: 'testuser', password: 'testpass');
      await localstoreService.save(user.id, user);

      final request = Request(
        'PUT',
        Uri.parse('http://localhost/users/${user.id}'),
        body:
            jsonEncode({'username': 'updateduser', 'password': 'updatedpass'}),
      );
      final response = await userService.updateUserHandler(request, user.id);

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json['message'], equals('User updated successfully'));

      final updatedUser = await localstoreService.fetchById(user.id);
      expect(updatedUser, isNotNull);
      expect(updatedUser!.username, equals('updateduser'));
      expect(updatedUser.password, equals('updatedpass'));
    });

    test('Delete User Handler', () async {
      final user = User(id: 'testid', username: 'testuser', password: 'testpass');
      await localstoreService.save(user.id, user);

      final request = Request('DELETE', Uri.parse('http://localhost/users/${user.id}'));
      final response = await userService.deleteUserHandler(request, user.id);

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json['message'], equals('User deleted successfully'));

      final deletedUser = await localstoreService.fetchById(user.id);
      expect(deletedUser, isNull);
    });
  });
}