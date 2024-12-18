import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../data/localstore.dart';
import '../models/user.dart';
import 'service.dart';

/// UserService handles all user-related operations
class UserService with Service {
  final LocalstoreService<User> _userStore;

  UserService()
      : _userStore = UserLocalstoreService();

  /// Sign Up Handler
  Future<Response> signUpHandler(Request request) async {
    try {
      final body = await parseRequestBody(request);
      final username = body['username'];
      final password = body['password'];

      if (username == null || password == null) {
        return Response.badRequest(body: 'Username and password are required');
      }

      final existingUsers = await _userStore.fetchWhere('username', username);
      if (existingUsers.isNotEmpty) {
        return Response(409, body: 'Username already exists');
      }

      final newUser = User(username: username, password: password);
      await _userStore.save(newUser.id, newUser);

      return Response.ok(jsonEncode({
        'message': 'User created successfully',
        'userId': newUser.id,
      }));
    } catch (e) {
      return Response.internalServerError(body: 'Error creating user: $e');
    }
  }

  /// Sign In Handler
  Future<Response> signInHandler(Request request) async {
    try {
      final body = await parseRequestBody(request);
      final username = body['username'];
      final password = body['password'];

      if (username == null || password == null) {
        return Response.badRequest(body: 'Username and password are required');
      }

      final users = await _userStore.fetchWhere('username', username);
      if (users.isEmpty || users.first.password != password) {
        return Response(401, body: 'Invalid username or password');
      }

      return Response.ok(jsonEncode({
        'message': 'Sign in successful',
        'userId': users.first.id,
      }));
    } catch (e) {
      return Response.internalServerError(body: 'Error during sign in: $e');
    }
  }

  /// Get User by ID Handler
  Future<Response> getUserByIdHandler(Request request, String userId) async {
    try {
      final user = await _userStore.fetchById(userId);
      if (user == null) {
        return Response.notFound('User not found');
      }

      return Response.ok(jsonEncode(user.toJson()));
    } catch (e) {
      return Response.internalServerError(body: 'Error fetching user: $e');
    }
  }

  /// Get User by Username Handler
  Future<Response> getUserByUsernameHandler(
      Request request, String username) async {
    try {
      final users = await _userStore.fetchWhere('username', username);
      if (users.isEmpty) {
        return Response.notFound('User not found');
      }

      return Response.ok(jsonEncode(users.first.toJson()));
    } catch (e) {
      return Response.internalServerError(body: 'Error fetching user: $e');
    }
  }

  /// Update User Handler
  Future<Response> updateUserHandler(Request request, String userId) async {
    try {
      final body = await parseRequestBody(request);
      await _userStore.update(userId, body);
      return Response.ok(jsonEncode({'message': 'User updated successfully'}));
    } catch (e) {
      return Response.internalServerError(body: 'Error updating user: $e');
    }
  }

  /// Delete User Handler
  Future<Response> deleteUserHandler(Request request, String userId) async {
    try {
      await _userStore.delete(userId);
      return Response.ok(jsonEncode({'message': 'User deleted successfully'}));
    } catch (e) {
      return Response.internalServerError(body: 'Error deleting user: $e');
    }
  }
}

/// LocalstoreService implementation for User
class UserLocalstoreService extends LocalstoreService<User> {
  @override
  String get collectionName => 'users';

  @override
  User fromJson(Map<String, dynamic> json) => User.fromJson(json);

  @override
  Map<String, dynamic> toJson(User object) => object.toJson();
}