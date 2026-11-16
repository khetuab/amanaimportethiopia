import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/cloudinary_config.dart';
import 'image_compress_service.dart';

class CloudinaryUpload {
  const CloudinaryUpload({
    required this.publicId,
    required this.url,
    required this.bytes,
    required this.originalName,
    this.width,
    this.height,
    this.format,
    this.deliveryType = 'upload',
  });

  final String publicId;
  final String url;
  final int bytes;
  final String originalName;
  final int? width;
  final int? height;
  final String? format;
  final String deliveryType; // 'upload' = public, 'authenticated' = private

  String get mimeType =>
      'image/${format == null || format == 'jpg' ? 'jpeg' : format}';

  Map<String, dynamic> toAttachment({String kind = 'reference_image'}) => {
    'key': publicId,
    'url': url,
    'mimeType': mimeType,
    'size': bytes,
    'kind': kind,
    'originalName': originalName,
  };
}

class CloudinaryException implements Exception {
  CloudinaryException(this.message);
  final String message;
  @override
  String toString() => message;
}

class CloudinaryService {
  CloudinaryService({Dio? dio})
      : _dio = dio ??
      Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 90),
        receiveTimeout: const Duration(seconds: 60),
      ));

  final Dio _dio;

  String get _endpoint =>
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload';

  Future<CloudinaryUpload> uploadImage(
      XFile file, {
        String? folder,
        String? uploadPreset,
        void Function(double progress)? onProgress,
        CancelToken? cancelToken,
      }) async {
    final preset = uploadPreset ?? CloudinaryConfig.uploadPreset;
    if (CloudinaryConfig.cloudName.isEmpty || preset.isEmpty) {
      throw CloudinaryException('Cloudinary is not configured.');
    }

    final compressed = await ImageCompressService.compress(File(file.path));
    final name = file.name.isEmpty ? 'image.jpg' : file.name;

    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(compressed.path, filename: name),
      'upload_preset': preset,
      if (folder != null) 'folder': folder,
    });

    try {
      final res = await _dio.post(
        _endpoint,
        data: form,
        cancelToken: cancelToken,
        onSendProgress: (sent, total) {
          if (total > 0) onProgress?.call(sent / total);
        },
      );
      final d = Map<String, dynamic>.from(res.data as Map);
      return CloudinaryUpload(
        publicId: d['public_id'].toString(),
        url: d['secure_url'].toString(),
        bytes: (d['bytes'] as num?)?.toInt() ?? 0,
        width: (d['width'] as num?)?.toInt(),
        height: (d['height'] as num?)?.toInt(),
        format: d['format']?.toString(),
        deliveryType: (d['type'] ?? 'upload').toString(),
        originalName: name,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      String? msg;
      if (data is Map) {
        final err = data['error'];
        if (err is Map) msg = err['message']?.toString();
      }
      throw CloudinaryException(
        msg ?? 'Image upload failed. Check your connection and try again.',
      );
    }
  }

  Future<List<CloudinaryUpload>> uploadImages(
      List<XFile> files, {
        String? folder,
        String? uploadPreset,
        void Function(double progress)? onProgress,
      }) {
    final progress = List<double>.filled(files.length, 0);
    void report() {
      if (onProgress == null || files.isEmpty) return;
      onProgress(progress.reduce((a, b) => a + b) / files.length);
    }

    return Future.wait([
      for (var i = 0; i < files.length; i++)
        uploadImage(
          files[i],
          folder: folder,
          uploadPreset: uploadPreset,
          onProgress: (p) {
            progress[i] = p;
            report();
          },
        ),
    ]);
  }

  /// Fast, small versions of public Cloudinary images (used for thumbnails).
  static String optimized(String url, {int? width, int? height}) {
    const marker = '/image/upload/';
    if (!url.contains('res.cloudinary.com') || !url.contains(marker)) return url;
    final t = [
      'f_auto',
      'q_auto',
      if (width != null) 'w_$width',
      if (height != null) 'h_$height',
      if (width != null || height != null) 'c_fill',
    ].join(',');
    return url.replaceFirst(marker, '$marker$t/');
  }
}