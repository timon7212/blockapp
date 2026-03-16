import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_exceptions.dart';
import '../dto/wallet_dto.dart';
import '../dto/pagination_dto.dart';

class WalletRepository {
  final ApiClient _api = ApiClient.instance;

  Future<WalletDto> getWallet() async {
    try {
      final res = await _api.get(ApiEndpoints.wallet);
      return WalletDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<PaginatedResponse<TransactionDto>> getTransactions({
    int page = 1,
    int limit = 20,
    TransactionTypeDto? type,
  }) async {
    try {
      final res = await _api.get(
        ApiEndpoints.transactions,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (type != null) 'type': type.value,
        },
      );
      final json = res.data as Map<String, dynamic>;
      return PaginatedResponse<TransactionDto>(
        data: (json['data'] as List<dynamic>)
            .map((e) => TransactionDto.fromJson(e as Map<String, dynamic>))
            .toList(),
        meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }
}
