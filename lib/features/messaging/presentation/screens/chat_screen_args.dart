import '../../data/models/conversation_model.dart';

/// Passé via `extra` de go_router. Deux cas : on ouvre une conversation déjà
/// existante (depuis la liste), ou on en démarre une nouvelle depuis le bouton
/// "Contacter le vendeur" d'une annonce (la conversation n'existe pas encore
/// côté serveur tant que le premier message n'est pas envoyé).
class ChatScreenArgs {
  const ChatScreenArgs.existing(ConversationModel conversation)
      : conversation = conversation,
        listingId = null,
        listingTitle = null,
        sellerId = null,
        sellerName = null,
        sellerAvatarUrl = null;

  const ChatScreenArgs.newConversation({
    required String listingId,
    required String listingTitle,
    required String sellerId,
    required String sellerName,
    String? sellerAvatarUrl,
  })  : conversation = null,
        listingId = listingId,
        listingTitle = listingTitle,
        sellerId = sellerId,
        sellerName = sellerName,
        sellerAvatarUrl = sellerAvatarUrl;

  final ConversationModel? conversation;
  final String? listingId;
  final String? listingTitle;
  final String? sellerId;
  final String? sellerName;
  final String? sellerAvatarUrl;

  bool get isNew => conversation == null;
}
