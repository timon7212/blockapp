import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_exceptions.dart';
import '../dto/gift_card_dto.dart';
import '../dto/cashout_dto.dart';
import '../dto/charity_dto.dart';
import '../dto/leaderboard_dto.dart';

class StoreRepository {
  final ApiClient _api = ApiClient.instance;

  // ─── Gift Cards ───

  Future<List<GiftCardDto>> getGiftCards({String? country}) async {
    try {
      final res = await _api.get(
        ApiEndpoints.giftCards,
        queryParameters: {if (country != null) 'country': country},
      );
      // API may return a list directly or a paginated object like { data: [...] }
      final dynamic body = res.data;
      List<dynamic> items;
      if (body is List<dynamic>) {
        items = body;
      } else if (body is Map<String, dynamic>) {
        items = (body['data'] as List<dynamic>?) ??
            (body['items'] as List<dynamic>?) ??
            (body['giftCards'] as List<dynamic>?) ??
            [];
      } else {
        items = [];
      }
      return items
          .map((e) => GiftCardDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<RedemptionResponseDto> redeemGiftCard(
      RedeemGiftCardRequest req) async {
    try {
      final res =
          await _api.post(ApiEndpoints.redeemGiftCard, data: req.toJson());
      return RedemptionResponseDto.fromJson(
          res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<List<RedemptionHistoryDto>> getRedemptionHistory() async {
    try {
      final res = await _api.get(ApiEndpoints.giftCardHistory);
      final dynamic body = res.data;
      List<dynamic> items;
      if (body is List<dynamic>) {
        items = body;
      } else if (body is Map<String, dynamic>) {
        items = (body['data'] as List<dynamic>?) ?? [];
      } else {
        items = [];
      }
      return items
          .map((e) =>
              RedemptionHistoryDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  // ─── Cash Out ───

  Future<CashOutResponseDto> requestCashOut(CashOutRequest req) async {
    try {
      final res = await _api.post(ApiEndpoints.cashOut, data: req.toJson());
      return CashOutResponseDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<List<CashOutHistoryDto>> getCashOutHistory() async {
    try {
      final res = await _api.get(ApiEndpoints.cashOutHistory);
      final dynamic body = res.data;
      List<dynamic> items;
      if (body is List<dynamic>) {
        items = body;
      } else if (body is Map<String, dynamic>) {
        items = (body['data'] as List<dynamic>?) ?? [];
      } else {
        items = [];
      }
      return items
          .map((e) =>
              CashOutHistoryDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  // ─── Charities ───

  Future<List<CharityDto>> getCharities() async {
    try {
      final res = await _api.get(ApiEndpoints.charities);
      final dynamic body = res.data;
      List<dynamic> items;
      if (body is List<dynamic>) {
        items = body;
      } else if (body is Map<String, dynamic>) {
        items = (body['data'] as List<dynamic>?) ?? [];
      } else {
        items = [];
      }
      return items
          .map((e) => CharityDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<DonationResponseDto> donate(
      String charityId, DonateRequest req) async {
    try {
      final res = await _api.post(
        ApiEndpoints.charityDonate(charityId),
        data: req.toJson(),
      );
      return DonationResponseDto.fromJson(
          res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  // ─── Leaderboard ───

  Future<List<LeaderboardEntryDto>> getWeeklyLeaderboard() async {
    try {
      final res = await _api.get(ApiEndpoints.leaderboardWeekly);
      final dynamic body = res.data;
      List<dynamic> items;
      if (body is List<dynamic>) {
        items = body;
      } else if (body is Map<String, dynamic>) {
        items = (body['data'] as List<dynamic>?) ?? [];
      } else {
        items = [];
      }
      return items
          .map((e) =>
              LeaderboardEntryDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<UserRankDto> getMyRank() async {
    try {
      final res = await _api.get(ApiEndpoints.leaderboardMe);
      return UserRankDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }
}
