import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'service.dart';

class GeneralService with Service {
  Response notFoundHandler(Request req) {
    return Response.notFound(
        'Không tìm thấy đường dẫn "${req.url}" trên server');
  }

  Response rootHandler(Request req) {
    final headers = {'Content-Type': 'application/json'};
    final response = jsonEncode({'message': 'Hello world'});
    return Response.ok(response, headers: headers);
  }
}
