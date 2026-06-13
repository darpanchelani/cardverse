import 'package:cardverse/core/config/app_config.dart';
import 'package:cardverse/core/network/api_exception.dart';
import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({
    Dio? dio,
    Future<String?> Function()? tokenProvider,
    String baseUrl = AppConfig.apiBaseUrl,
  }) : _tokenProvider = tokenProvider,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               connectTimeout: const Duration(seconds: 8),
               receiveTimeout: const Duration(seconds: 10),
               headers: {'Accept': 'application/json'},
             ),
           );

  static ApiClient? globalInstance;

  final Dio _dio;
  final Future<String?> Function()? _tokenProvider;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) => _request('GET', path, query: query);

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) => _request('POST', path, data: data);

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? data,
  }) => _request('PATCH', path, data: data);

  Future<Map<String, dynamic>> delete(String path) => _request('DELETE', path);

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final token = await _tokenProvider?.call();
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: query,
        options: Options(
          method: method,
          headers: token == null ? null : {'Authorization': 'Bearer $token'},
        ),
      );
      return _map(response.data);
    } on DioException catch (error) {
      final body = _map(error.response?.data);
      final errors = body['errors'] as List<dynamic>? ?? const [];
      final validationMessage = errors.isEmpty
          ? null
          : _map(errors.first)['message']?.toString();
      throw ApiException(
        validationMessage ??
            body['message']?.toString() ??
            (error.type == DioExceptionType.connectionError ||
                    error.type == DioExceptionType.connectionTimeout
                ? 'Could not connect to the CardVerse server.'
                : 'Request failed. Please try again.'),
        statusCode: error.response?.statusCode,
        errors: errors,
      );
    }
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }
}
