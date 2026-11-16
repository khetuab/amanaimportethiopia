import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/api_interceptor.dart';
import '../../core/network/dio_client.dart';
import '../models/importer_profile_model.dart';

class ImporterRepository {
  ImporterRepository(this._dio);
  final DioClient _dio;

  Future<({ImporterProfileModel profile, List<dynamic> documents})>
  getMyProfile() async {
    try {
      final res = await _dio.dio.get(ApiEndpoints.importerMyProfile);
      final data = ((res.data as Map)['data'] as Map).cast<String, dynamic>();
      return (
        profile: ImporterProfileModel.fromJson(
          (data['profile'] as Map).cast<String, dynamic>(),
        ),
        documents: (data['documents'] as List?) ?? const [],
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<ImporterProfileModel> submitVerification(
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await _dio.dio.post(
        ApiEndpoints.importerSubmitVerification,
        data: payload,
      );
      return ImporterProfileModel.fromJson(
        ((res.data as Map)['data'] as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  ApiException _toApi(Object e) =>
      e is ApiException ? e : toApiException(e as dynamic);

  Future<List<dynamic>> getDocuments() async {
    try {
      final res = await _dio.dio.get(ApiEndpoints.importerMyProfile);
      final data = ((res.data as Map)['data'] as Map).cast<String, dynamic>();
      return (data['documents'] as List?) ?? const [];
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<Map<String, dynamic>> addDocument({
    required String type,
    required String fileKey,
    required String fileUrl,
    required String mimeType,
    required int size,
    String? label,
  }) async {
    try {
      final res = await _dio.dio.post(
        ApiEndpoints.importerAddDocument,
        data: {
          'type': type,
          'fileKey': fileKey,
          'fileUrl': fileUrl,
          'mimeType': mimeType,
          'size': size,
          'label': ?label,
        },
      );
      return ((res.data as Map)['data'] as Map).cast<String, dynamic>();
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<void> removeDocument(String id) async {
    try {
      await _dio.dio.delete(ApiEndpoints.importerRemoveDocument(id));
    } catch (e) {
      throw _toApi(e);
    }
  }
}
