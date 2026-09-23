import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/social_icon_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: 'https://images.unsplash.com/photo-1523805009345-7448845a9e53?w=900',
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => Container(color: AppColors.textPrimary),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.45, 1.0],
                colors: [Colors.black38, Colors.black26, Colors.black87],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: 'Trok',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900),
                        ),
                      ]),
                    ),
                  ),

                  const Spacer(),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Vendez, achetez, troquez en toute confiance.',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Rejoignez la plus grande communauté de Côte d'Ivoire pour des échanges simples, rapides et sécurisés.",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/register'),
                      child: const Text('Commencer'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.push('/login'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: const BorderSide(color: Colors.white54),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Se connecter', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.white24)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OU CONTINUER AVEC', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54, letterSpacing: 0.5)),
                      ),
                      const Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialIconButton(
                        onTap: () {},
                        child: Image.network(
                          'https://www.google.com/favicon.ico',
                          errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, color: Colors.red),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SocialIconButton(onTap: () {}, backgroundColor: Colors.black, child: const Icon(Icons.apple, color: Colors.white)),
                      const SizedBox(width: 16),
                      SocialIconButton(onTap: () {}, backgroundColor: const Color(0xFF1877F2), child: const Icon(Icons.facebook, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
