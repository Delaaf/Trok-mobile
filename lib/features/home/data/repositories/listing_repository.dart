import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/dio_provider.dart';
import '../models/listing_model.dart';

class ListingRepository {
  ListingRepository(this._dio);

  final Dio _dio;

  Future<PaginatedListings> getListings({
    String? query,
    int? categoryId,
    String? city,
    String? commune,
    String? location,
    String sort = 'recent',
    int page = 1,
  }) async {
    try {
      final response = await _dio.get('/listings', queryParameters: {
        if (query != null && query.isNotEmpty) 'q': query,
        if (categoryId != null) 'category_id': categoryId,
        if (city != null && city.isNotEmpty) 'city': city,
        if (commune != null && commune.isNotEmpty) 'commune': commune,
        if (location != null && location.isNotEmpty) 'location': location,
        'sort': sort,
        'page': page,
      });

      return PaginatedListings.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ListingModel> getListing(String id) async {
    try {
      final response = await _dio.get('/listings/$id');
      return ListingModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<PaginatedListings> getMyListings() async {
    try {
      final response = await _dio.get('/me/listings');
      return PaginatedListings.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> markAsSold(String id) async {
    try {
      await _dio.post('/listings/$id/sold');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteListing(String id) async {
    try {
      await _dio.delete('/listings/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> updateListing(String id, Map<String, dynamic> fields) async {
    try {
      await _dio.patch('/listings/$id', data: fields);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final listingRepositoryProvider = Provider<ListingRepository>((ref) => ListingRepository(ref.watch(dioProvider)));
