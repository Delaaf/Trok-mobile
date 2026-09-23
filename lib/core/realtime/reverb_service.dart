import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pusher_reverb_flutter/pusher_reverb_flutter.dart';
import '../config/env.dart';
import '../network/dio_client.dart';

class ReverbService {
  ReverbClient? _client;
  Completer<void>? _connectedCompleter;

  /// Retourne le client une fois la connexion RÉELLEMENT établie (socketId
  /// assigné). Indispensable : `subscribeToPrivateChannel` lève une exception
  /// si appelée avant que la connexion soit prête.
  Future<ReverbClient> connect() async {
    if (_client != null) {
      if (_connectedCompleter != null && !_connectedCompleter!.isCompleted) {
        await _connectedCompleter!.future;
      }
      return _client!;
    }

    _connectedCompleter = Completer<void>();

    _client = ReverbClient.instance(
      host: Env.reverbHost,
      port: Env.reverbPort,
      appKey: Env.reverbKey,
      authorizer: _authorizer,
      authEndpoint: '${Env.apiBaseUrl}/broadcasting/auth',
      onConnected: (socketId) {
        debugPrint('[Reverb] Connecté (socketId=$socketId)');
        if (!(_connectedCompleter?.isCompleted ?? true)) {
          _connectedCompleter!.complete();
        }
      },
      onError: (error) {
        debugPrint('[Reverb] Erreur: $error');
        if (!(_connectedCompleter?.isCompleted ?? true)) {
          _connectedCompleter!.completeError(error);
        }
      },
      onReconnecting: () => debugPrint('[Reverb] Reconnexion...'),
    );
    _client!.connect();

    await _connectedCompleter!.future;

    return _client!;
  }

  /// À appeler quand un écran de chat se ferme, pour ne pas garder l'abonnement
  /// actif indéfiniment en arrière-plan.
  void unsubscribe(String channelName) {
    _client?.unsubscribeFromChannel(channelName);
  }

  Future<Map<String, String>> _authorizer(String channelName, String socketId) async {
    final token = await DioClient.readToken();
    return {if (token != null) 'Authorization': 'Bearer $token'};
  }
}

final reverbServiceProvider = Provider<ReverbService>((ref) => ReverbService());
