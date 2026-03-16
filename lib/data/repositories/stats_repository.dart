import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_exceptions.dart';
import '../dto/stats_dto.dart';

class StatsRepository {
  final ApiClient _api = ApiClient.instance;

  Future<DailyStatsDto> getDailyStats({String? date}) async {
    try {
      final res = await _api.get(
        ApiEndpoints.dailyStats,
        queryParameters: {if (date != null) 'date': date},
      );
      return DailyStatsDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<List<WeeklyStatsEntryDto>> getWeeklyStats() async {
    try {
      final res = await _api.get(ApiEndpoints.weeklyStats);
      return (res.data as List<dynamic>)
          .map((e) =>
              WeeklyStatsEntryDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<StreakDto> getStreak() async {
    try {
      final res = await _api.get(ApiEndpoints.streak);
      return StreakDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }
}
