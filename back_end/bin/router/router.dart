import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart';

// Load the .env file from the current directory
var env = DotEnv()..load(['./bin/router/.env']);

/// Header mặc định cho dữ liệu trả về dưới dạng JSON
final _headers = (jsonDecode(env['_headers'] ?? '{}') as Map<String, dynamic>)
    .map((key, value) => MapEntry(key, value.toString()));

final router = Router(notFoundHandler: _notFoundHandler)
  ..get('/', _rootHandler);

Response _notFoundHandler(Request req) {
  return Response.notFound('Không tìm thấy đường dẫn "${req.url}" trên server');
}

Response _rootHandler(Request req) {
  final response = jsonEncode({'message': 'Hello world'});
  return Response.ok(response, headers: _headers);
}
