import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../models/user.dart';
import 'service.dart';
import '../data/user_storage.dart';

/// Lớp lưu trữ User

/// Lớp xử lý User
class UserService with Service {
  final UserStorage userStorage = UserStorage('bin/data/json/users.json');
  final _headers = {'Content-Type': 'application/json'};

  /// Xử lý đăng ký người dùng
  Future<Response> signUpHandler(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final username = data['username'] as String;
      final password = data['password'] as String;

      if (username.isEmpty || password.isEmpty) {
        return Response.badRequest(
            body: 'Username and password are required', headers: _headers);
      }

      final existingUsers = await userStorage.fetchWhere('username', username);
      if (existingUsers.isNotEmpty) {
        return Response(409,
            body: 'Username already exists', headers: _headers);
      }

      final newUser = User(username: username, password: password);
      await userStorage.save(newUser.id, newUser);

      return Response.ok(
          jsonEncode({
            'message': 'User created successfully',
            'userId': newUser.id,
          }),
          headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: 'Error creating user: $e', headers: _headers);
    }
  }

  /// Xử lý đăng nhập người dùng
  Future<Response> signInHandler(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final username = data['username'] as String;
      final password = data['password'] as String;

      if (username.isEmpty || password.isEmpty) {
        return Response.badRequest(
            body: 'Username and password are required', headers: _headers);
      }

      final users = await userStorage.fetchWhere('username', username);
      if (users.isEmpty || users.first.password != password) {
        return Response(401,
            body: 'Invalid username or password', headers: _headers);
      }

      return Response.ok(
          jsonEncode({
            'message': 'Sign in successful',
            'userId': users.first.id,
          }),
          headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: 'Error during sign in: $e', headers: _headers);
    }
  }

  /// Lấy thông tin người dùng theo ID
  Future<Response> getUserByIdHandler(Request request, String userId) async {
    try {
      final user = await userStorage.fetchById(userId);
      if (user == null) {
        return Response.notFound('User not found', headers: _headers);
      }

      return Response.ok(jsonEncode(user.toJson()), headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: 'Error fetching user: $e', headers: _headers);
    }
  }

  /// Lấy thông tin người dùng theo username
  Future<Response> getUserByUsernameHandler(
      Request request, String username) async {
    try {
      final users = await userStorage.fetchWhere('username', username);
      if (users.isEmpty) {
        return Response.notFound('User not found', headers: _headers);
      }

      return Response.ok(jsonEncode(users.first.toJson()), headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: 'Error fetching user: $e', headers: _headers);
    }
  }

  /// Cập nhật thông tin người dùng
  Future<Response> updateUserHandler(Request request, String userId) async {
    try {
      final updates = await request.readAsString();
      final data = jsonDecode(updates) as Map<String, dynamic>;

      final existingUser = await userStorage.fetchById(userId);
      if (existingUser == null) {
        return Response.notFound('User not found', headers: _headers);
      }

      final updatedUser = User(
        id: userId,
        username: data['username'] ?? existingUser.username,
        password: data['password'] ?? existingUser.password,
      );

      await userStorage.save(userId, updatedUser);

      return Response.ok(jsonEncode({'message': 'User updated successfully'}),
          headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: 'Error updating user: $e', headers: _headers);
    }
  }

  /// Xóa người dùng
  Future<Response> deleteUserHandler(Request request, String userId) async {
    try {
      await userStorage.delete(userId);
      return Response.ok(jsonEncode({'message': 'User deleted successfully'}),
          headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: 'Error deleting user: $e', headers: _headers);
    }
  }
}
