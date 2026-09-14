import 'package:dio/dio.dart';

/// Exception unifiée pour toute erreur venant de l'API. `message` est déjà
/// formaté pour être affiché tel quel à l'utilisateur (pas besoin de le
/// retraiter côté UI). `fieldErrors` contient les erreurs de validation
/// Laravel (422) par champ, utile pour surligner un champ précis du formulaire.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.fieldErrors});

  final String message;
  final int? statusCode;
  final Map<String, List<String>>? fieldErrors;

  factory ApiException.fromDioException(DioException e) {
    final response = e.response;

    if (response == null) {
      return ApiException(
        e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout
            ? 'La connexion prend trop de temps. Vérifiez votre réseau.'
            : 'Impossible de contacter le serveur. Vérifiez votre connexion.',
      );
    }

    final data = response.data;
    String message = 'Une erreur est survenue. Réessayez.';
    Map<String, List<String>>? fieldErrors;

    if (data is Map<String, dynamic>) {
      if (data['message'] is String) message = data['message'] as String;

      if (data['errors'] is Map) {
        fieldErrors = (data['errors'] as Map).map(
          (key, value) => MapEntry(key.toString(), List<String>.from(value as List)),
        );
        // Pour un message générique plus parlant que "The given data was invalid."
        final firstError = fieldErrors.values.firstOrNull?.firstOrNull;
        if (firstError != null) message = firstError;
      }
    }

    return ApiException(message, statusCode: response.statusCode, fieldErrors: fieldErrors);
  }

  @override
  String toString() => message;
}
