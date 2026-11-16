import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/api_interceptor.dart';
import '../../core/network/dio_client.dart';

/// One place for file uploads so no controller ever touches Dio.
class UploadRepository {
  UploadRepository(this._dio);
  final DioClient _dio;

  /// Uploads a single file. Returns the stored object coordinates.
  Future<UploadedFile> single(
    MultipartFile file, {
    String folder = 'misc',
  }) async {
    try {
      final form = FormData.fromMap({'file': file, 'folder': folder});
      final res = await _dio.dio.post(ApiEndpoints.uploadSingle, data: form);
      return UploadedFile.fromJson(
        ((res.data as Map)['data'] as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  /// Uploads several files; fails soft per item — returns the ones
  /// that made it so callers can decide whether a partial upload is
  /// acceptable.
  Future<List<UploadedFile>> multiple(
    List<MultipartFile> files, {
    String folder = 'misc',
  }) async {
    try {
      final form = FormData.fromMap({'files': files, 'folder': folder});
      final res = await _dio.dio.post(ApiEndpoints.uploadMultiple, data: form);
      final list = ((res.data as Map)['data'] as List?) ?? const [];
      return list
          .whereType<Map>()
          .map((m) => UploadedFile.fromJson(m.cast<String, dynamic>()))
          .toList();
    } catch (e) {
      throw _toApi(e);
    }
  }

  ApiException _toApi(Object e) =>
      e is ApiException ? e : toApiException(e as dynamic);
}

/// `{ key, url, mimeType, size, originalName }` — the upload response.
class UploadedFile {
  UploadedFile({
    required this.key,
    required this.url,
    this.mimeType,
    this.size,
    this.originalName,
  });

  final String key;
  final String url;
  final String? mimeType;
  final int? size;
  final String? originalName;

  factory UploadedFile.fromJson(Map<String, dynamic> j) => UploadedFile(
    key: (j['key'] ?? '').toString(),
    url: (j['url'] ?? '').toString(),
    mimeType: j['mimeType']?.toString(),
    size: (j['size'] as num?)?.toInt(),
    originalName: j['originalName']?.toString(),
  );

  Map<String, dynamic> toPayload({String kind = 'image'}) => {
    'key': key,
    'url': url,
    'mimeType': mimeType,
    'size': size,
    'kind': kind,
    if (originalName != null) 'originalName': originalName,
  };
}
