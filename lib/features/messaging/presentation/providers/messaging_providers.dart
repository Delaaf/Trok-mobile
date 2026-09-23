import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/conversation_model.dart';
import '../../data/repositories/messaging_repository.dart';

final conversationsProvider = FutureProvider<List<ConversationModel>>((ref) {
  return ref.watch(messagingRepositoryProvider).getConversations();
});
