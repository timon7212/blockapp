/// Base API exception.
sealed class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// 401 — invalid or expired token.
class UnauthorizedException extends ApiException {
  const UnauthorizedException([String message = 'Unauthorized'])
      : super(message, statusCode: 401);
}

/// 403 — forbidden.
class ForbiddenException extends ApiException {
  const ForbiddenException([String message = 'Forbidden'])
      : super(message, statusCode: 403);
}

/// 404 — not found.
class NotFoundException extends ApiException {
  const NotFoundException([String message = 'Not found'])
      : super(message, statusCode: 404);
}

/// 400 — bad request / validation error.
class BadRequestException extends ApiException {
  const BadRequestException(String message, {dynamic data})
      : super(message, statusCode: 400, data: data);
}

/// 409 — conflict (e.g. email already registered).
class ConflictException extends ApiException {
  const ConflictException([String message = 'Conflict'])
      : super(message, statusCode: 409);
}

/// 429 — rate limited.
class RateLimitException extends ApiException {
  const RateLimitException([String message = 'Too many requests'])
      : super(message, statusCode: 429);
}

/// 5xx — server error.
class ServerException extends ApiException {
  const ServerException([String message = 'Server error', int? statusCode])
      : super(message, statusCode: statusCode ?? 500);
}

/// No internet connection.
class NetworkException extends ApiException {
  const NetworkException(
      [String message = 'No internet connection. Check your network.'])
      : super(message);
}

/// Request timed out.
class TimeoutException extends ApiException {
  const TimeoutException([String message = 'Request timed out'])
      : super(message);
}

/// Token refresh failed — user needs to re-login.
class SessionExpiredException extends ApiException {
  const SessionExpiredException(
      [String message = 'Session expired. Please log in again.'])
      : super(message, statusCode: 401);
}

/// Helper: extract readable error message from API response body.
String extractErrorMessage(dynamic data) {
  if (data == null) return 'Unknown error';
  if (data is String) return data;
  if (data is Map) {
    return (data['message'] ?? data['error'] ?? 'Unknown error').toString();
  }
  return data.toString();
}
