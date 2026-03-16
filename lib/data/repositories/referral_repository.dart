import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_exceptions.dart';
import '../dto/referral_dto.dart';

class ReferralRepository {
  final ApiClient _api = ApiClient.instance;

  Future<ReferralStatsDto> getReferralDetails() async {
    try {
      final res = await _api.get(ApiEndpoints.referrals);
      return ReferralStatsDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<List<InviteeDto>> getInvitees() async {
    try {
      final res = await _api.get(ApiEndpoints.referralInvitees);
      return (res.data as List<dynamic>)
          .map((e) => InviteeDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<CollectReferralResponseDto> collectChildReferrals() async {
    try {
      final res = await _api.post(ApiEndpoints.collectChildReferrals);
      return CollectReferralResponseDto.fromJson(
          res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<CollectReferralResponseDto> collectGrandchildReferrals() async {
    try {
      final res = await _api.post(ApiEndpoints.collectGrandchildReferrals);
      return CollectReferralResponseDto.fromJson(
          res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<InviteLinkDto> getInviteLink() async {
    try {
      final res = await _api.get(ApiEndpoints.inviteLink);
      return InviteLinkDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<ReferralStatsOverviewDto> getReferralStats() async {
    try {
      final res = await _api.get(ApiEndpoints.referralStats);
      return ReferralStatsOverviewDto.fromJson(
          res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }
}
