import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/env.dart';

const _tokenStorageKey = 'trok_auth_token';

class DioClient {
  DioClient._();

  static const _secureStorage = FlutterSecureStorage();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: _tokenStorageKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _secureStorage.delete(key: _tokenStorageKey);
          }
          handler.next(error);
        },
      ),
    );

    if (!Env.isProduction) {
      dio.interceptors.add(
        PrettyDioLogger(requestHeader: false, requestBody: true, responseBody: true, error: true),
      );
    }

    return dio;
  }

  static Future<void> saveToken(String token) => _secureStorage.write(key: _tokenStorageKey, value: token);
  static Future<String?> readToken() => _secureStorage.read(key: _tokenStorageKey);
  static Future<void> clearToken() => _secureStorage.delete(key: _tokenStorageKey);
  static Future<bool> hasToken() async => (await readToken()) != null;
}
