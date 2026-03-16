import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/api_exceptions.dart';
import '../dto/earn_dto.dart';

class EarnRepository {
  final ApiClient _api = ApiClient.instance;

  // ─── Games ───

  Future<List<GameDto>> getGames() async {
    try {
      final res = await _api.get(ApiEndpoints.games);
      return (res.data as List<dynamic>)
          .map((e) => GameDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<GameCompleteResponseDto> completeGame(
      GameCompleteRequest req) async {
    try {
      final res =
          await _api.post(ApiEndpoints.gameComplete, data: req.toJson());
      return GameCompleteResponseDto.fromJson(
          res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  // ─── Tasks ───

  Future<List<TaskDto>> getTasks() async {
    try {
      final res = await _api.get(ApiEndpoints.tasks);
      return (res.data as List<dynamic>)
          .map((e) => TaskDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<void> startTask(String taskId) async {
    try {
      await _api.post(ApiEndpoints.taskStart,
          data: TaskStartRequest(taskId: taskId).toJson());
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<TaskCompleteResponseDto> completeTask(String taskId) async {
    try {
      final res = await _api.post(ApiEndpoints.taskComplete(taskId));
      return TaskCompleteResponseDto.fromJson(
          res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  // ─── Surveys ───

  Future<List<SurveyDto>> getSurveys() async {
    try {
      final res = await _api.get(ApiEndpoints.surveys);
      return (res.data as List<dynamic>)
          .map((e) => SurveyDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }

  Future<SurveyCompleteResponseDto> submitSurvey(
      String id, SurveySubmitRequest req) async {
    try {
      final res = await _api.post(
        ApiEndpoints.surveySubmit(id),
        data: req.toJson(),
      );
      return SurveyCompleteResponseDto.fromJson(
          res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ServerException(e.message ?? 'Failed');
    }
  }
}
