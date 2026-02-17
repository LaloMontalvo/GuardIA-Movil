/// Excepciones personalizadas para la capa de datos

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException: $message (Code: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  NetworkException([this.message = 'Sin conexión a internet']);

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  CacheException([this.message = 'Error de caché']);

  @override
  String toString() => 'CacheException: $message';
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException([this.message = 'No autorizado']);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;

  ValidationException(this.message, {this.errors});

  @override
  String toString() => 'ValidationException: $message';
}
