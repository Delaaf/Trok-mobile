import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/dio_provider.dart';
import '../models/listing_model.dart';

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

  Future<PaginatedListings> getMyFavorites() async {
    try {
      final response = await _dio.get('/me/favorites');
      return PaginatedListings.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) => FavoriteRepository(ref.watch(dioProvider)));
