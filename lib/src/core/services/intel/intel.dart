import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Intel {
  static final Dio _dio = Dio();
  static String? _apiKey;

  static Future<void> _initialize() async {
    await dotenv.load(fileName: '.env');
    String key = dotenv.env['OPENAI']!;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $key',
    };
    _apiKey = key;
  }

  static Future<Stream<List<int>>> fetchQueryResponse(String query) async {
    if(_apiKey == null) await _initialize();
    Response response = await _dio.post(
      'https://api.openai.com/v1/chat/completions',
      options: Options(
        responseType: ResponseType.stream,
      ),
      data: {
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "You are a helpful assistant."},
          {"role": "user", "content": query},
        ],
        "stream": true,
      },
    );
    Stream<List<int>> responseStream = response.data.stream as Stream<List<int>>;
    return responseStream.asBroadcastStream();
  }
}