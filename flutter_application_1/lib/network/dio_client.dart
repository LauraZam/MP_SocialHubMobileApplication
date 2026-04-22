import 'package:dio/dio.dart';
import 'package:flutter_application_1/network/api_client.dart';
class DioClient {
  late ApiClient client;

  DioClient() {
    final dio = Dio();

    dio.options = BaseOptions(
      baseUrl: 'https://zenquotes.io/api/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      headers: {
        'Authorization': '95566548',
        'Accept': 'application/json',
      },
    );

    client = ApiClient(dio);
  }
}