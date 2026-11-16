import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../config/app_config.dart';

/// Compresses picked images before upload. Never upload raw camera files.
class ImageCompressService {
  ImageCompressService._();

  static Future<File> compress(File input) async {
    final dir = await getTemporaryDirectory();
    final target = File(
      '${dir.path}/${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    final result = await FlutterImageCompress.compressAndGetFile(
      input.absolute.path,
      target.path,
      quality: AppConfig.imageQuality,
      minWidth: AppConfig.imageMaxWidthPx,
      minHeight: AppConfig.imageMaxWidthPx,
      format: CompressFormat.jpeg,
    );
    return result != null ? File(result.path) : input;
  }
}
