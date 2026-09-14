import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/dio_provider.dart';
import '../models/auth_user.dart';

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  /// POST /auth/register
  /// Retourne l'utilisateur créé (encore `pending_verification` à ce stade —
  /// aucun token n'est émis tant que l'OTP n'a pas été vérifié).
  Future<AuthUser> register({
    required String fullName,
    required String email,
    String? phone,
    required String password,
    required String passwordConfirmation,
    required String role,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'full_name': fullName,
        'email': email,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role,
      });

      return AuthUser.fromJson(response.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /auth/login
  /// Sauvegarde le token automatiquement en cas de succès.
  Future<AuthUser> login({required String email, required String password}) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
        'device_name': 'mobile',
      });

      final token = response.data['token'] as String;
      await DioClient.saveToken(token);

      return AuthUser.fromJson(response.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /auth/otp/request
  Future<void> requestOtp({required String identifier, required String channel, required String purpose}) async {
    try {
      await _dio.post('/auth/otp/request', data: {
        'identifier': identifier,
        'channel': channel,
        'purpose': purpose,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /auth/otp/verify
  /// Si purpose == "registration", le backend renvoie un token -> on le sauvegarde
  /// et l'utilisateur est alors connecté (plus besoin de repasser par /login).
  Future<bool> verifyOtp({required String identifier, required String purpose, required String code}) async {
    try {
      final response = await _dio.post('/auth/otp/verify', data: {
        'identifier': identifier,
        'purpose': purpose,
        'code': code,
      });

      final token = response.data['token'] as String?;
      if (token != null) {
        await DioClient.saveToken(token);
        return true; // connecté directement
      }

      return false; // code vérifié mais pas de token émis (ex: password_reset)
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// GET /auth/me
  Future<AuthUser> me() async {
    try {
      final response = await _dio.get('/auth/me');
      return AuthUser.fromJson(response.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST /auth/logout
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException catch (_) {
      // Même si l'appel réseau échoue, on purge le token localement.
    } finally {
      await DioClient.clearToken();
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(dioProvider)));
