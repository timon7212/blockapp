import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_exceptions.dart';
import '../dto/raffle_dto.dart';

class RaffleRepository {
  final ApiClient _api = ApiClient.instance;

  Future<List<RaffleDto>> getActiveRaffles() async {
    try {
      final res = await _api.get(ApiEndpoints.raffles);
      final dynamic body = res.data;
      List<dynamic> items;
      if (body is List<dynamic>) {
        items = body;
      } else if (body is Map<String, dynamic>) {
        items = (body['data'] as List<dynamic>?) ??
            (body['raffles'] as List<dynamic>?) ??
            [];
      } else {
        items = [];
      }
      return items
          .map((e) => RaffleDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<RaffleDto> getRaffleDetail(String id) async {
    try {
      final res = await _api.get(ApiEndpoints.raffleDetail(id));
      return RaffleDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<RaffleEntryResponseDto> enterRaffle(
      String id, RaffleEntryRequest req) async {
    try {
      final res = await _api.post(
        ApiEndpoints.raffleEnter(id),
        data: req.toJson(),
      );
      return RaffleEntryResponseDto.fromJson(
          res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<RaffleResultDto> getRaffleResult(String id) async {
    try {
      final res = await _api.get(ApiEndpoints.raffleResult(id));
      return RaffleResultDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<List<RaffleWinnerDto>> getRecentWinners() async {
    try {
      final res = await _api.get(ApiEndpoints.raffleWinners);
      final dynamic body = res.data;
      List<dynamic> items;
      if (body is List<dynamic>) {
        items = body;
      } else if (body is Map<String, dynamic>) {
        items = (body['data'] as List<dynamic>?) ??
            (body['winners'] as List<dynamic>?) ??
            [];
      } else {
        items = [];
      }
      return items
          .map((e) => RaffleWinnerDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }
}
