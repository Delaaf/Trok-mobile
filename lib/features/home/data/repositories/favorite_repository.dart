import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/dio_provider.dart';

class FavoriteRepository {
  FavoriteRepository(this._dio);

  final Dio _dio;

  Future<void> add(String listingId) async {
    try {
      await _dio.post('/listings/$listingId/favorite');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> remove(String listingId) async {
    try {
      await _dio.delete('/listings/$listingId/favorite');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) => FavoriteRepository(ref.watch(dioProvider)));
