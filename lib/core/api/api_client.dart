import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/env_config.dart';
import './api_endpoints.dart';
import './api_exceptions.dart';
import '../../services/token_service.dart';

/// Singleton Dio-based HTTP client with auth, refresh, and error interceptors.
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();
  static bool _initialized = false;

  late final Dio _dio;

  Dio get dio => _dio;

  /// Call once at app startup (before any API call).
  void init() {
    if (_initialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout:
            Duration(milliseconds: EnvConfig.connectTimeoutMs),
        receiveTimeout:
            Duration(milliseconds: EnvConfig.receiveTimeoutMs),
        sendTimeout:
            Duration(milliseconds: EnvConfig.sendTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _RefreshInterceptor(_dio),
      _ErrorInterceptor(),
      if (kDebugMode) _LogInterceptor(),
    ]);

    _initialized = true;
  }

  // ─── Convenience methods ───

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get<T>(path,
          queryParameters: queryParameters, options: options);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.post<T>(path,
          data: data,
          queryParameters: queryParameters,
          options: options);

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.patch<T>(path, data: data, options: options);

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.delete<T>(path, data: data, options: options);

  /// Make a request without the auth token (for login/register).
  Future<Response<T>> postPublic<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: {_AuthInterceptor._skipAuthHeader: true}),
      );

  Future<Response<T>> getPublic<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: Options(headers: {_AuthInterceptor._skipAuthHeader: true}),
      );
}

// ─── Auth Interceptor ───
// Adds Authorization: Bearer <token> to every request (unless skipAuth).

class _AuthInterceptor extends Interceptor {
  static const _skipAuthHeader = 'X-Skip-Auth';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints (login, register, etc.)
    if (options.headers.remove(_skipAuthHeader) == true) {
      return handler.next(options);
    }

    final token = await TokenService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}

// ─── Refresh Interceptor ───
// On 401 → attempt token refresh → retry original request.

class _RefreshInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})>
      _pendingRequests = [];

  _RefreshInterceptor(this._dio);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Don't retry refresh-token or login requests
    final path = err.requestOptions.path;
    if (path == ApiEndpoints.refreshToken ||
        path == ApiEndpoints.login ||
        path == ApiEndpoints.register) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      // Queue this request to retry after refresh completes
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await TokenService.getRefreshToken();
      if (refreshToken == null) {
        throw const SessionExpiredException();
      }

      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'X-Skip-Auth': true},
        ),
      );

      final newAccess = response.data['accessToken'] as String;
      final newRefresh = response.data['refreshToken'] as String;
      await TokenService.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );

      // Retry original request
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
      final retryResponse = await _dio.fetch(err.requestOptions);
      handler.resolve(retryResponse);

      // Retry queued requests
      for (final pending in _pendingRequests) {
        pending.options.headers['Authorization'] = 'Bearer $newAccess';
        final r = await _dio.fetch(pending.options);
        pending.handler.resolve(r);
      }
    } catch (_) {
      // Refresh failed — clear tokens, force re-login
      await TokenService.clearTokens();
      handler.next(err);

      for (final pending in _pendingRequests) {
        pending.handler.next(err);
      }
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }
}

// ─── Error Interceptor ───
// Maps DioException → typed ApiException.

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final ApiException apiException;

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      apiException = const TimeoutException();
    } else if (err.type == DioExceptionType.connectionError) {
      apiException = const NetworkException();
    } else if (err.response != null) {
      final status = err.response!.statusCode ?? 0;
      final msg = extractErrorMessage(err.response!.data);

      apiException = switch (status) {
        400 => BadRequestException(msg, data: err.response!.data),
        401 => UnauthorizedException(msg),
        403 => ForbiddenException(msg),
        404 => NotFoundException(msg),
        409 => ConflictException(msg),
        429 => const RateLimitException(),
        _ when status >= 500 => ServerException(msg, status),
        _ => ServerException(msg, status),
      };
    } else {
      apiException = NetworkException(err.message ?? 'Connection error');
    }

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: apiException,
        message: apiException.message,
      ),
    );
  }
}

// ─── Log Interceptor (debug only) ───

class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('→ ${options.method} ${options.uri}');
    if (options.data != null) {
      debugPrint('  body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
        '✕ ${err.response?.statusCode ?? "?"} ${err.requestOptions.uri}');
    if (err.response?.data != null) {
      debugPrint('  response: ${err.response!.data}');
    }
    if (err.error is ApiException) {
      debugPrint('  error: ${(err.error as ApiException).message}');
    }
    handler.next(err);
  }
}
