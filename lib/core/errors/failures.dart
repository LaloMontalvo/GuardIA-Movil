/// Clase base para errores de la aplicación
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => message;
}

/// Error de red (sin conexión, timeout, etc.)
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Error de conexión'])
      : super(message);
}

/// Error del servidor (500, 502, etc.)
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Error del servidor'])
      : super(message);
}

/// Error de autenticación (401, 403)
class AuthFailure extends Failure {
  const AuthFailure([String message = 'No autorizado']) : super(message);
}

/// Error de validación (400)
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Datos inválidos'])
      : super(message);
}

/// Recurso no encontrado (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Recurso no encontrado'])
      : super(message);
}

/// Error desconocido
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'Error desconocido'])
      : super(message);
}

/// Error de caché/almacenamiento local
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Error de almacenamiento'])
      : super(message);
}
