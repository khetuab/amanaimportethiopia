import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../config/app_config.dart';
import '../config/env.dart';
import '../storage/secure_storage.dart';
import 'api_interceptor.dart';

/// Singleton Dio factory. Repositories accept a Dio instance
/// injected via GetX.
class DioClient {
  DioClient._(this.dio);

  final Dio dio;

  static Future<DioClient> create(SecureStorage secure) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        responseType: ResponseType.json,
        headers: {'Accept': 'application/json'},
        validateStatus: (status) =>
        status != null && status >= 200 && status < 300,// 401 handled by interceptor
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (object) => debugPrint(object.toString()),
      ),
    );

    if (Env.isDev) {
      dio.interceptors.add(
        LogInterceptor(
          request: false,
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: false,
          error: true,
          logPrint: (o) => Get.log('$o'),
        ),
      );
    }

    if (Env.isDev) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: false,
          error: true,
          logPrint: (o) => Get.log('$o'),
        ),
      );
    }

    dio.interceptors.add(AuthInterceptor(secure, dio));

    return DioClient._(dio);
  }
}
