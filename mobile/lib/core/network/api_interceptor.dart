import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import '../constants/api_endpoints.dart';
import '../constants/storage_keys.dart';
import '../storage/secure_storage.dart';
import 'api_exception.dart';

/// Adds Bearer auth, refreshes on 401 (once per request), forwards to
/// `/auth/refresh`, and retries the original request transparently.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secure, this._dio);

  final SecureStorage _secure;
  final Dio _dio;

  bool _refreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})>
  _queue = [];

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final path = options.path;

    final isAuth =
        path.contains('/auth/login') ||
            path.contains('/auth/register') ||
            path.contains('/auth/refresh') ||
            path.contains('/auth/forgot-password') ||
            path.contains('/auth/reset-password');

    if (!isAuth) {
      try {
        final token = await _secure.read(StorageKeys.accessToken);

        Get.log(
          '[AUTH DEBUG] ${options.method} $path '
              '| tokenExists: ${token != null && token.trim().isNotEmpty} '
              '| existingAuthorization: '
              '${options.headers.containsKey('Authorization')}',
        );

        if (token != null && token.trim().isNotEmpty) {
          options.headers['Authorization'] = 'Bearer ${token.trim()}';
        } else {
          options.headers.remove('Authorization');
        }
      } catch (e) {
        Get.log('[AUTH DEBUG] Failed to read access token: $e');
        return handler.reject(
          DioException(
            requestOptions: options,
            error: 'Unable to read authentication token',
          ),
        );
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final path = err.requestOptions.path;

    final isRefreshCall = path.contains('/auth/refresh');

    if (status != 401 || isRefreshCall) {
      return handler.next(err);
    }

    if (_refreshing) {
      _queue.add((options: err.requestOptions, handler: handler));
      return;
    }

    _refreshing = true;
    try {
      final newToken = await _refresh();
      if (newToken == null) {
        await _handleAuthFailure();
        for (final q in _queue) {
          q.handler.next(err);
        }
        _queue.clear();
        return handler.next(err);
      }

      // Retry original
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newToken';
      final response = await _dio.fetch(opts);
      handler.resolve(response);

      // Retry queued
      for (final q in _queue) {
        q.options.headers['Authorization'] = 'Bearer $newToken';
        try {
          final r = await _dio.fetch(q.options);
          q.handler.resolve(r);
        } catch (e) {
          q.handler.next(err);
        }
      }
      _queue.clear();
    } catch (_) {
      await _handleAuthFailure();
      handler.next(err);
    } finally {
      _refreshing = false;
    }
  }

  Future<String?> _refresh() async {
    final refreshToken = await _secure.read(StorageKeys.refreshToken);
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final res = await _dio.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );
      final data = res.data;
      if (data is! Map) return null;
      final tokens = data['data']?['tokens'];
      if (tokens is! Map) return null;
      final access = tokens['accessToken'] as String?;
      final refresh = tokens['refreshToken'] as String?;
      if (access == null || refresh == null) return null;
      await _secure.write(StorageKeys.accessToken, access);
      await _secure.write(StorageKeys.refreshToken, refresh);
      return access;
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleAuthFailure() async {
    await _secure.delete(StorageKeys.accessToken);
    await _secure.delete(StorageKeys.refreshToken);
    // Broadcast — AuthController listens and redirects to login.
    Get.log('[auth] refresh failed — session cleared');
  }
}

/// Convert any DioException into ApiException for consistent handling.
ApiException toApiException(DioException e) {
  final status = e.response?.statusCode;
  final data = e.response?.data;

  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout) {
    return ApiException(
      message: 'Connection timed out. Check your internet and try again.',
      statusCode: status,
      code: 'TIMEOUT',
    );
  }
  if (e.type == DioExceptionType.connectionError) {
    return ApiException(
      message: 'No internet connection.',
      statusCode: status,
      code: 'NETWORK',
    );
  }
  if (e.type == DioExceptionType.cancel) {
    return ApiException(
      message: 'Request cancelled.',
      statusCode: status,
      code: 'CANCELLED',
    );
  }

  return ApiException.fromJson(data, statusCode: status);
}
