import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/auth_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Le premier frame doit être rendu avant toute navigation, sinon GoRouter
    // peut se plaindre de naviguer pendant le build initial.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuthAndRedirect());
  }

  Future<void> _checkAuthAndRedirect() async {
    final hasToken = await DioClient.hasToken();

    if (!hasToken) {
      if (mounted) context.go('/welcome');
      return;
    }

    try {
      // Le token existe localement mais peut avoir été révoqué côté serveur
      // (déconnexion à distance, expiration, compte suspendu...) -> on vérifie.
      await ref.read(authRepositoryProvider).me();
      if (mounted) context.go('/');
    } catch (_) {
      // /auth/me a échoué (401 le plus souvent) -> le token est invalide.
      // DioClient l'a déjà purgé via son intercepteur onError, mais on s'assure :
      await DioClient.clearToken();
      if (mounted) context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Trok',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
