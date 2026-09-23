import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/dio_provider.dart';
import '../models/public_profile_model.dart';

class ProfileRepository {
  ProfileRepository(this._dio);

  final Dio _dio;

  Future<PublicProfileModel> getPublicProfile(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      return PublicProfileModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) => ProfileRepository(ref.watch(dioProvider)));
