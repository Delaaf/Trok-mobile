import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/dio_provider.dart';
import '../models/location_search_result.dart';

class LocationRepository {
  LocationRepository(this._dio);

  final Dio _dio;

  Future<List<LocationSearchResult>> search(String query) async {
    try {
      final response = await _dio.get('/locations/search', queryParameters: {'q': query});
      final data = response.data['data'] as List;
      return data.map((e) => LocationSearchResult.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<NearestLocationResult> nearest(double latitude, double longitude) async {
    try {
      final response = await _dio.get('/locations/nearest', queryParameters: {'lat': latitude, 'lng': longitude});
      return NearestLocationResult.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final locationRepositoryProvider = Provider<LocationRepository>((ref) => LocationRepository(ref.watch(dioProvider)));
