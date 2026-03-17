import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_exceptions.dart';
import '../dto/screen_time_dto.dart';
import '../dto/spin_dto.dart';

class EventsRepository {
  final ApiClient _api = ApiClient.instance;

  Future<ScreenTimeSyncResponseDto> syncScreenTime(
      ScreenTimeSyncRequest req) async {
    try {
      final res =
          await _api.post(ApiEndpoints.screenTimeSync, data: req.toJson());
      return ScreenTimeSyncResponseDto.fromJson(
          res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<CollectPointsResponseDto> collectPoints() async {
    try {
      final res = await _api.post(ApiEndpoints.collectPoints);
      return CollectPointsResponseDto.fromJson(
          res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<RecordAdViewResponseDto> recordAdView(
      RecordAdViewRequest req) async {
    try {
      final res = await _api.post(ApiEndpoints.adView, data: req.toJson());
      return RecordAdViewResponseDto.fromJson(
          res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<List<SpinPrizeDto>> getSpinPrizes() async {
    try {
      final res = await _api.get(ApiEndpoints.spinPrizes);
      final dynamic body = res.data;
      List<dynamic> items;
      if (body is List<dynamic>) {
        items = body;
      } else if (body is Map<String, dynamic>) {
        items = (body['data'] as List<dynamic>?) ??
            (body['prizes'] as List<dynamic>?) ??
            (body['items'] as List<dynamic>?) ??
            [];
      } else {
        items = [];
      }
      return items
          .map((e) => SpinPrizeDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<SpinWheelResponseDto> spin() async {
    try {
      final res = await _api.post(ApiEndpoints.spin);
      return SpinWheelResponseDto.fromJson(
          res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }
}
