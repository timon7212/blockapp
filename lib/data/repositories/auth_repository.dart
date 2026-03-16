import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_exceptions.dart';
import '../../services/token_service.dart';
import '../dto/auth_dto.dart';

class AuthRepository {
  final ApiClient _api = ApiClient.instance;

  Future<AuthResponseDto> register(RegisterRequest req) async {
    try {
      final res = await _api.postPublic(ApiEndpoints.register, data: req.toJson());
      final dto = AuthResponseDto.fromJson(res.data as Map<String, dynamic>);
      await TokenService.saveTokens(
        accessToken: dto.accessToken,
        refreshToken: dto.refreshToken,
      );
      return dto;
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Registration failed');
    }
  }

  Future<AuthResponseDto> login(LoginRequest req) async {
    try {
      final res = await _api.postPublic(ApiEndpoints.login, data: req.toJson());
      final dto = AuthResponseDto.fromJson(res.data as Map<String, dynamic>);
      await TokenService.saveTokens(
        accessToken: dto.accessToken,
        refreshToken: dto.refreshToken,
      );
      return dto;
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Login failed');
    }
  }

  Future<AuthResponseDto> googleSignIn(GoogleSignInRequest req) async {
    try {
      final res = await _api.postPublic(ApiEndpoints.googleSignIn, data: req.toJson());
      final dto = AuthResponseDto.fromJson(res.data as Map<String, dynamic>);
      await TokenService.saveTokens(
        accessToken: dto.accessToken,
        refreshToken: dto.refreshToken,
      );
      return dto;
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Google sign-in failed');
    }
  }

  Future<MessageResponseDto> verifyEmail(String token) async {
    try {
      final res = await _api.getPublic(
        ApiEndpoints.verifyEmail,
        queryParameters: {'token': token},
      );
      return MessageResponseDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Verification failed');
    }
  }

  Future<MessageResponseDto> resendVerification(String email) async {
    try {
      final res = await _api.postPublic(
        ApiEndpoints.resendVerification,
        data: {'email': email},
      );
      return MessageResponseDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<MessageResponseDto> forgotPassword(String email) async {
    try {
      final res = await _api.postPublic(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
      return MessageResponseDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<MessageResponseDto> resetPassword(ResetPasswordRequest req) async {
    try {
      final res = await _api.postPublic(
        ApiEndpoints.resetPassword,
        data: req.toJson(),
      );
      return MessageResponseDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<void> changePassword(ChangePasswordRequest req) async {
    try {
      await _api.post(ApiEndpoints.changePassword, data: req.toJson());
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiEndpoints.logout);
    } catch (_) {
      // Ignore logout errors
    } finally {
      await TokenService.clearTokens();
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _api.delete(ApiEndpoints.deleteAccount);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    } finally {
      await TokenService.clearTokens();
    }
  }
}
