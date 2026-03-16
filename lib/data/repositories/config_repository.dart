import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_exceptions.dart';
import '../dto/config_dto.dart';
import '../dto/device_dto.dart';

class ConfigRepository {
  final ApiClient _api = ApiClient.instance;

  Future<AppConfigDto> getConfig() async {
    try {
      final res = await _api.getPublic(ApiEndpoints.config);
      return AppConfigDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<DeviceResponseDto> registerDevice(
      RegisterDeviceRequest req) async {
    try {
      final res = await _api.post(ApiEndpoints.devices, data: req.toJson());
      return DeviceResponseDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }
}
