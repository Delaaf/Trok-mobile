import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/notifications/push_notification_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

/// Gestionnaire des messages reçus quand l'app est en arrière-plan ou fermée.
/// Doit être une fonction top-level (pas une méthode de classe) et annotée
/// @pragma('vm:entry-point') pour être accessible depuis l'isolate dédié FCM.
/// FCM affiche déjà la notification système tout seul dans ce cas (le payload
/// contient un bloc "notification") -> rien à faire ici pour l'instant.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: TrokApp()));
}

class TrokApp extends ConsumerStatefulWidget {
  const TrokApp({super.key});

  @override
  ConsumerState<TrokApp> createState() => _TrokAppState();
}

class _TrokAppState extends ConsumerState<TrokApp> {
  @override
  void initState() {
    super.initState();
    ref.read(pushNotificationServiceProvider).initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Trok',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
