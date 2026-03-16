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
  const UnauthorizedException([super.message = 'Unauthorized'])
      : super(statusCode: 401);
}

/// 403 — forbidden.
class ForbiddenException extends ApiException {
  const ForbiddenException([super.message = 'Forbidden'])
      : super(statusCode: 403);
}

/// 404 — not found.
class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Not found'])
      : super(statusCode: 404);
}

/// 400 — bad request / validation error.
class BadRequestException extends ApiException {
  const BadRequestException(super.message, {super.data})
      : super(statusCode: 400);
}

/// 409 — conflict (e.g. email already registered).
class ConflictException extends ApiException {
  const ConflictException([super.message = 'Conflict'])
      : super(statusCode: 409);
}

/// 429 — rate limited.
class RateLimitException extends ApiException {
  const RateLimitException([super.message = 'Too many requests'])
      : super(statusCode: 429);
}

/// 5xx — server error.
class ServerException extends ApiException {
  const ServerException([super.message = 'Server error', int? statusCode])
      : super(statusCode: statusCode ?? 500);
}

/// No internet connection.
class NetworkException extends ApiException {
  const NetworkException(
      [super.message = 'No internet connection. Check your network.']);
}

/// Request timed out.
class TimeoutException extends ApiException {
  const TimeoutException([super.message = 'Request timed out']);
}

/// Token refresh failed — user needs to re-login.
class SessionExpiredException extends ApiException {
  const SessionExpiredException(
      [super.message = 'Session expired. Please log in again.'])
      : super(statusCode: 401);
}

/// Helper: extract readable error message from API response body.
/// Handles NestJS error format: { "statusCode": 400, "message": [...], "error": "Bad Request" }
String extractErrorMessage(dynamic data) {
  if (data == null) return 'Something went wrong';
  if (data is String) return data.isEmpty ? 'Something went wrong' : data;
  if (data is Map) {
    final message = data['message'];
    if (message is List && message.isNotEmpty) {
      // NestJS validation errors: ["email must be valid", "password too short"]
      return message.join('. ');
    }
    if (message is String && message.isNotEmpty) {
      return message;
    }
    final error = data['error'];
    if (error is String && error.isNotEmpty) {
      return error;
    }
    return 'Something went wrong';
  }
  return data.toString();
}
