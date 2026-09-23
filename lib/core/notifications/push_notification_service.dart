import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dio_provider.dart';
import '../router/app_router.dart';

class PushNotificationService {
  PushNotificationService(this._dio);

  final Dio _dio;
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channel = AndroidNotificationChannel(
    'trok_default',
    'Notifications Trok',
    description: 'Messages et mises à jour de vos annonces',
    importance: Importance.high,
  );

  /// À appeler UNE FOIS au démarrage de l'app (indépendamment de l'auth) —
  /// prépare l'affichage local. La permission système n'est demandée que plus
  /// tard, dans registerDeviceToken(), pour ne pas la réclamer dès l'écran de
  /// bienvenue avant même que l'utilisateur ait un compte.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Notification reçue alors que l'app est AU PREMIER PLAN -> FCM ne l'affiche
    // pas tout seul sur Android, il faut le faire manuellement.
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // Tap sur une notification qui a ramené l'app depuis l'arrière-plan.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // App totalement fermée, relancée en tapant sur la notification.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _handleNotificationTap(initialMessage);
  }

  /// À appeler juste après une connexion réussie (login, OTP, auto-login au
  /// démarrage) — demande la permission puis enregistre le token côté backend.
  Future<void> registerDeviceToken() async {
    final settings = await _messaging.requestPermission(alert: true, badge: true, sound: true);
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[Push] Permission refusée par l\'utilisateur.');
      return;
    }

    final token = await _messaging.getToken();
    if (token != null) await _sendTokenToBackend(token);

    _messaging.onTokenRefresh.listen(_sendTokenToBackend);
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      await _dio.post('/me/device-tokens', data: {
        'token': token,
        'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
      });
    } catch (e) {
      debugPrint('[Push] Echec enregistrement token: $e');
    }
  }

  /// À appeler à la déconnexion, pour ne plus recevoir de push sur cet appareil.
  Future<void> unregisterDeviceToken() async {
    final token = await _messaging.getToken();
    if (token == null) return;
    try {
      await _dio.delete('/me/device-tokens', data: {'token': token});
    } catch (_) {
      // Pas grave si ça échoue ici : le token finira invalide côté FCM et sera
      // nettoyé automatiquement au prochain envoi (voir PushNotificationService backend).
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    if (response.payload == null || response.payload!.isEmpty) return;
    final data = jsonDecode(response.payload!) as Map<String, dynamic>;
    _navigateFromData(data);
  }

  void _handleNotificationTap(RemoteMessage message) {
    _navigateFromData(message.data);
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    switch (type) {
      case 'message':
        // TODO: charger directement la conversation via son id pour ouvrir le
        // chat précis plutôt que la liste -> nécessite un fetch avant de
        // pouvoir construire un ChatScreenArgs.existing(...).
        appRouter.push('/messages');
      case 'listing_published':
      case 'listing_rejected':
        final listingId = data['listing_id'] as String?;
        if (listingId != null) appRouter.push('/listing/$listingId');
    }
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(ref.watch(dioProvider));
});
