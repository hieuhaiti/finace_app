import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'router/router.dart';

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;
  final corsHeader = createMiddleware(
    requestHandler: (req) {
      print(req);
      if (req.method == 'OPTIONS') {
        return Response.ok('', headers: {
          // Cho phép mọi nguồn truy cập (trong môi trường dev). Trong môi trường production chúng ta nên thay * bằng domain cụ thể.
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, HEAD',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        });
      }
      return null; // Tiếp tục xử lý các yêu cầu khác
    },
    responseHandler: (res) {
      print(res);
      return res.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, HEAD',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      });
    },
  );
  // Configure a pipeline that logs requests.
  final handler = Pipeline()
      .addMiddleware(corsHeader) // Thêm middleware xử lý CORS
      .addMiddleware(logRequests())
      .addHandler(router.call);
  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server đang chạy tại http://${server.address.host}:${server.port}');
}
