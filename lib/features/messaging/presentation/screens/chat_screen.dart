import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pusher_reverb_flutter/pusher_reverb_flutter.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/realtime/reverb_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/messaging_repository.dart';
import '../providers/messaging_providers.dart';
import '../widgets/message_bubble.dart';
import 'chat_screen_args.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.args});

  final ChatScreenArgs args;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  String? _conversationId;
  String? _otherName;
  String? _otherAvatarUrl;

  final _messages = <MessageModel>[];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  String? _currentUserId;
  PrivateChannel? _channel;
  bool _channelSubscribed = false;

  bool _isLoadingHistory = true;
  bool _isSending = false;
  String? _errorMessage;

  bool _otherIsTyping = false;
  Timer? _typingIndicatorTimer;
  Timer? _typingBroadcastTimer;

  @override
  void initState() {
    super.initState();
    _otherName = widget.args.conversation?.otherParticipant.fullName ?? widget.args.sellerName;
    _otherAvatarUrl = widget.args.conversation?.otherParticipant.avatarUrl ?? widget.args.sellerAvatarUrl;
    _textController.addListener(_onTextChanged);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final me = await ref.read(authRepositoryProvider).me();
      _currentUserId = me.id;
    } catch (_) {
      // pas bloquant pour l'affichage initial, juste pour distinguer mes bulles
    }

    final existing = widget.args.conversation;
    if (existing != null) {
      _conversationId = existing.id;
      await _loadHistory(existing.id);
      await _subscribeToChannel(existing.id);
    } else {
      if (mounted) setState(() => _isLoadingHistory = false); // en attente du premier message
    }
  }

  Future<void> _loadHistory(String conversationId) async {
    try {
      final messages = await ref.read(messagingRepositoryProvider).getMessages(conversationId);
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(messages)
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt)); // garantit toujours ancien -> récent
        _isLoadingHistory = false;
      });
      _scrollToBottom(animate: false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingHistory = false;
        _errorMessage = 'Impossible de charger les messages.';
      });
    }
  }

  Future<void> _subscribeToChannel(String conversationId) async {
    // connect() attend maintenant la vraie connexion (socketId assigné) avant
    // de retourner -> subscribeToPrivateChannel() peut planter sinon.
    final client = await ref.read(reverbServiceProvider).connect();
    if (!mounted) return;

    final channelName = 'private-conversation.$conversationId';
    // NOTE: subscribeToPrivateChannel() s'abonne déjà tout seul en interne
    // (elle appelle channel.subscribe() elle-même) -> pas besoin de le refaire.
    final channel = client.subscribeToPrivateChannel(channelName);

    channel.addStateListener((state) {
      _channelSubscribed = state == ChannelState.subscribed;
    });

    channel.bind('message.sent', (eventName, data) {
      debugPrint('[ChatScreen] Événement message.sent reçu en temps réel.');
      final message = MessageModel.fromJson(Map<String, dynamic>.from(data as Map));
      if (message.senderId == _currentUserId) {
        debugPrint('[ChatScreen] Message reçu = le mien (déjà affiché en optimiste), ignoré.');
        return;
      }
      if (!mounted) return;
      setState(() {
        _messages
          ..add(message)
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        _otherIsTyping = false;
      });
      _typingIndicatorTimer?.cancel();
      _scrollToBottom();
      debugPrint('[ChatScreen] Invalidation de conversationsProvider (message reçu en temps réel)...');
      ref.invalidate(conversationsProvider);
      debugPrint('[ChatScreen] conversationsProvider invalidé (réception temps réel) avec succès.');
    });

    channel.bind('client-typing', (eventName, data) {
      if (!mounted) return;
      setState(() => _otherIsTyping = true);
      _typingIndicatorTimer?.cancel();
      _typingIndicatorTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _otherIsTyping = false);
      });
    });

    _channel = channel;
  }

  void _onTextChanged() {
    if (_channel == null || !_channelSubscribed) return;

    // Throttle: on ne whisper pas à chaque frappe, juste au début d'une
    // séquence de frappe, toutes les 2s tant qu'on continue de taper.
    if (_typingBroadcastTimer == null || !_typingBroadcastTimer!.isActive) {
      _channel!.whisper('typing', {'userId': _currentUserId});
      _typingBroadcastTimer = Timer(const Duration(seconds: 2), () {});
    }
  }

  Future<void> _send() async {
    final body = _textController.text.trim();
    if (body.isEmpty || _isSending) return;

    debugPrint('[ChatScreen] _send() démarré, _conversationId=$_conversationId');

    setState(() => _isSending = true);
    _textController.clear();

    try {
      if (_conversationId == null) {
        debugPrint('[ChatScreen] Démarrage d\'une nouvelle conversation...');
        final conversation = await ref.read(messagingRepositoryProvider).startConversation(
              listingId: widget.args.listingId!,
              message: body,
            );
        if (!mounted) {
          debugPrint('[ChatScreen] ATTENTION: widget démonté juste après startConversation, arrêt.');
          return;
        }
        _conversationId = conversation.id;
        debugPrint('[ChatScreen] Conversation créée: ${conversation.id}');
        await _loadHistory(conversation.id);
        await _subscribeToChannel(conversation.id);
      } else {
        debugPrint('[ChatScreen] Envoi du message dans la conversation existante $_conversationId...');
        final message = await ref.read(messagingRepositoryProvider).sendMessage(_conversationId!, body);
        if (!mounted) {
          debugPrint('[ChatScreen] ATTENTION: widget démonté juste après sendMessage, arrêt.');
          return;
        }
        debugPrint('[ChatScreen] Message envoyé avec succès, id=${message.id}');
        setState(() {
          _messages
            ..add(message)
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        });
      }
      _scrollToBottom();
      // Invalide ICI (dès qu'on sait que les données ont changé), pas dans
      // dispose() -> fonctionne quelle que soit la façon dont on quitte
      // ensuite l'écran (bouton retour, geste système, bouton Android...).
      debugPrint('[ChatScreen] Invalidation de conversationsProvider (après envoi)...');
      ref.invalidate(conversationsProvider);
      debugPrint('[ChatScreen] conversationsProvider invalidé avec succès.');
    } on ApiException catch (e) {
      debugPrint('[ChatScreen] ApiException pendant _send(): ${e.message}');
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (e, stackTrace) {
      debugPrint('[ChatScreen] Erreur INATTENDUE pendant _send(): $e');
      debugPrint(stackTrace.toString());
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (animate) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return 'Hier';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _timeLabel(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    debugPrint('[ChatScreen] dispose() appelé, _conversationId=$_conversationId');
    _typingIndicatorTimer?.cancel();
    _typingBroadcastTimer?.cancel();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    if (_conversationId != null) {
      try {
        ref.read(reverbServiceProvider).unsubscribe('private-conversation.$_conversationId');
        debugPrint('[ChatScreen] Invalidation de conversationsProvider (dans dispose)...');
        ref.invalidate(conversationsProvider);
        debugPrint('[ChatScreen] conversationsProvider invalidé (dans dispose) avec succès.');
      } catch (e, stackTrace) {
        debugPrint('[ChatScreen] Erreur pendant le nettoyage dans dispose(): $e');
        debugPrint(stackTrace.toString());
      }
    } else {
      debugPrint('[ChatScreen] dispose(): _conversationId est null, pas d\'invalidation.');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // En-tête
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 12),
              child: Row(
                children: [
                  IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.surfaceMuted,
                    backgroundImage: _otherAvatarUrl != null ? CachedNetworkImageProvider(_otherAvatarUrl!) : null,
                    child: _otherAvatarUrl == null
                        ? Text(
                            (_otherName?.isNotEmpty ?? false) ? _otherName![0].toUpperCase() : '?',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_otherName ?? 'Conversation', style: textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                        if (_otherIsTyping)
                          const Text('en train d\'écrire...', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600))
                        else if (widget.args.listingTitle != null || widget.args.conversation?.listing != null)
                          Text(
                            widget.args.listingTitle ?? widget.args.conversation!.listing!.title,
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Messages
            Expanded(
              child: _isLoadingHistory
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _messages.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'Envoie le premier message pour démarrer la conversation.',
                              style: textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final showDateSeparator = index == 0 ||
                                _dateLabel(_messages[index - 1].createdAt) != _dateLabel(message.createdAt);

                            return Column(
                              children: [
                                if (showDateSeparator) DateSeparator(label: _dateLabel(message.createdAt)),
                                MessageBubble(
                                  body: message.body,
                                  time: _timeLabel(message.createdAt),
                                  isMine: message.senderId == _currentUserId,
                                ),
                              ],
                            );
                          },
                        ),
            ),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                  child: Text(_errorMessage!, style: textTheme.bodySmall?.copyWith(color: AppColors.error)),
                ),
              ),

            // Barre de saisie
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
                      child: TextField(
                        controller: _textController,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Écrire un message...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: AppColors.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _isSending ? null : _send,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: _isSending
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
