import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/dio_provider.dart';

class CreateListingRepository {
  CreateListingRepository(this._dio);

  final Dio _dio;

  Future<String> create({
    required int categoryId,
    required String title,
    required String description,
    required bool isFree,
    double? price,
    required bool isNegotiable,
    required bool acceptsExchange,
    required String condition,
    required Map<String, dynamic> attributes,
    String? city,
    String? commune,
    required List<XFile> images,
  }) async {
    final fields = <MapEntry<String, String>>[
      MapEntry('category_id', categoryId.toString()),
      MapEntry('title', title),
      MapEntry('description', description),
      // IMPORTANT: la règle Laravel `boolean` accepte true/false/0/1/'0'/'1'
      // mais PAS les chaînes littérales "true"/"false" envoyées en multipart.
      MapEntry('is_free', isFree ? '1' : '0'),
      MapEntry('is_negotiable', isNegotiable ? '1' : '0'),
      MapEntry('accepts_exchange', acceptsExchange ? '1' : '0'),
      MapEntry('condition', condition),
    ];

    if (!isFree && price != null) {
      fields.add(MapEntry('price', price.toString()));
    }
    if (city != null && city.trim().isNotEmpty) fields.add(MapEntry('city', city.trim()));
    if (commune != null && commune.trim().isNotEmpty) fields.add(MapEntry('commune', commune.trim()));

    // Laravel comprend la notation attributes[cle]=valeur envoyée en multipart
    // comme un tableau associatif -> correspond à `attributes` (array) côté StoreListingRequest.
    attributes.forEach((key, value) {
      final stringValue = value?.toString().trim() ?? '';
      if (stringValue.isNotEmpty) {
        fields.add(MapEntry('attributes[$key]', stringValue));
      }
    });

    final imageFiles = <MapEntry<String, MultipartFile>>[];
    for (final image in images) {
      imageFiles.add(MapEntry(
        'images[]',
        await MultipartFile.fromFile(image.path, filename: image.name),
      ));
    }

    final formData = FormData()
      ..fields.addAll(fields)
      ..files.addAll(imageFiles);

    try {
      final response = await _dio.post('/listings', data: formData);
      return response.data['data']['id'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final createListingRepositoryProvider = Provider<CreateListingRepository>(
  (ref) => CreateListingRepository(ref.watch(dioProvider)),
);
