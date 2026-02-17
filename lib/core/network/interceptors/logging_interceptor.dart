import 'package:dio/dio.dart';
import 'dart:developer' as developer;

/// Interceptor para logging de requests y responses (solo en debug)
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      '🌐 REQUEST[${options.method}] => ${options.uri}',
      name: 'DioClient',
    );
    developer.log(
      '📤 Headers: ${options.headers}',
      name: 'DioClient',
    );
    if (options.data != null) {
      developer.log(
        '📦 Data: ${options.data}',
        name: 'DioClient',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '✅ RESPONSE[${response.statusCode}] <= ${response.requestOptions.uri}',
      name: 'DioClient',
    );
    developer.log(
      '📥 Data: ${response.data}',
      name: 'DioClient',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '❌ ERROR[${err.response?.statusCode}] => ${err.requestOptions.uri}',
      name: 'DioClient',
      error: err.message,
    );
    developer.log(
      '💥 Error: ${err.error}',
      name: 'DioClient',
    );
    handler.next(err);
  }
}
