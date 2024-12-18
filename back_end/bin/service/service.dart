import 'dart:convert';
import 'package:shelf/shelf.dart';

mixin Service {
  Future<Map<String, dynamic>> parseRequestBody(Request request) async {
    final body = await request.readAsString();
    if (body.isEmpty) {
      throw ArgumentError('Request body cannot be empty.');
    }

    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
      throw ArgumentError('Invalid JSON format: ${e.toString()}');
    }
  }
}
