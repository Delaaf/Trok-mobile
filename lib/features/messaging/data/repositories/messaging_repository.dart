import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/dio_provider.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class MessagingRepository {
  MessagingRepository(this._dio);

  final Dio _dio;

  Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await _dio.get('/conversations');
      final data = response.data['data'] as List;
      return data.map((e) => ConversationModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ConversationModel> startConversation({required String listingId, required String message}) async {
    try {
      final response = await _dio.post('/conversations', data: {
        'listing_id': listingId,
        'message': message,
      });
      return ConversationModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Retourne les messages du plus ANCIEN au plus RÉCENT (prêt pour affichage
  /// chronologique direct) — le backend les renvoie dans l'autre sens.
  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final response = await _dio.get('/conversations/$conversationId/messages');
      final data = response.data['data'] as List;
      return data.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList().reversed.toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<MessageModel> sendMessage(String conversationId, String body) async {
    try {
      final response = await _dio.post('/conversations/$conversationId/messages', data: {'body': body});
      return MessageModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final messagingRepositoryProvider = Provider<MessagingRepository>((ref) => MessagingRepository(ref.watch(dioProvider)));
