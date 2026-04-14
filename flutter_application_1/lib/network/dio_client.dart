import 'package:dio/dio.dart';
import 'rest_client.dart';

class DioClient {
  late RestClient client;

  DioClient() {
    final dio = Dio();

    dio.options = BaseOptions(
      baseUrl: 'https://api.example.com',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      headers: {
        'Authorization': 'Bearer YOUR_TOKEN',
        'Accept': 'application/json',
      },
    );

    client = RestClient(dio);
  }
}