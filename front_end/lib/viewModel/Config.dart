import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static late String baseURL;

  static Future<void> loadEnv() async {
    await dotenv.load(fileName: '.env');

    String? ip = dotenv.env['ip'];
    String? port = dotenv.env['port'];

    if (ip == null || port == null) {
      throw Exception("IP or port not found in .env file");
    }
    baseURL = "http://$ip:$port/api/v1";
  }
}