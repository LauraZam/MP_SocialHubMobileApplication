import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_client.g.dart';

@JsonSerializable()
class Quote {
  @JsonKey(name: 'q')
  final String text;
  @JsonKey(name: 'a')
  final String author;

  Quote({required this.text, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);
}

@RestApi(baseUrl: "https://zenquotes.io/api/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @GET("quotes")
  Future<List<Quote>> getQuotesList();
}