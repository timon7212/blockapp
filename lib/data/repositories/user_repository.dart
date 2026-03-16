import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_exceptions.dart';
import '../dto/user_dto.dart';

class UserRepository {
  final ApiClient _api = ApiClient.instance;

  Future<UserProfileDto> getProfile() async {
    try {
      final res = await _api.get(ApiEndpoints.userProfile);
      return UserProfileDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<UserProfileDto> updateProfile(UpdateProfileRequest req) async {
    try {
      final res = await _api.patch(ApiEndpoints.userProfile, data: req.toJson());
      return UserProfileDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<void> completeOnboarding(OnboardingRequest req) async {
    try {
      await _api.post(ApiEndpoints.onboarding, data: req.toJson());
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }
}
