import 'package:dio/dio.dart';
import 'api_response.dart';

class DioHandler {
  static ApiResponse<T> handleDioError<T>(DioException error) {
    return ApiResponse.error('A network error occurred : ${error.message}');
  }
}