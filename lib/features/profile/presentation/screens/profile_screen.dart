import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/notifications/push_notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../home/presentation/widgets/trok_bottom_nav.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_stat.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Se déconnecter ?'),
        content: const Text('Vous devrez vous reconnecter pour accéder à votre compte.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Se déconnecter', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // IMPORTANT: avant logout() -> la requête DELETE /me/device-tokens a besoin
    // du token Sanctum, qui est révoqué/purgé par logout() juste après.
    await ref.read(pushNotificationServiceProvider).unregisterDeviceToken();
    await ref.read(authRepositoryProvider).logout();
    // PAS de clearUserScopedCache() ici : cet écran observe encore activement
    // myProfileProvider à cet instant -> l'invalider déclenche un refetch
    // IMMÉDIAT avec un token déjà supprimé -> 401 mis en cache, qui refait
    // surface brièvement au prochain compte connecté. L'invalidation faite à
    // la CONNEXION (login/OTP) suffit : à ce moment-là, aucun écran ne
    // regarde encore ces providers, donc pas de refetch prématuré.
    if (context.mounted) context.go('/welcome');
  }

  void _notImplementedYet(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bientôt disponible'), behavior: SnackBarBehavior.floating),
    );
  }

  void _handleNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        context.go('/favorites');
      case 2:
        context.push('/create-listing'); // flux à part, reste en push
      case 3:
        context.go('/messages');
      case 4:
        break; // déjà sur Profil
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: TrokBottomNav(currentIndex: 4, onTap: (index) => _handleNavTap(context, index)),
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) => RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(myProfileProvider);
              await ref.read(myProfileProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Row(
                  children: [
                    Text('Profil', style: textTheme.displayMedium),
                    const Spacer(),
                    IconButton(onPressed: () => _notImplementedYet(context), icon: const Icon(Icons.settings_outlined)),
                  ],
                ),
                const SizedBox(height: 20),

                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.surfaceMuted,
                        backgroundImage: profile.avatarUrl != null ? CachedNetworkImageProvider(profile.avatarUrl!) : null,
                        child: profile.avatarUrl == null
                            ? Text(
                                profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(profile.fullName, style: textTheme.headlineLarge),
                          if (profile.isVerifiedSeller) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_rounded, color: AppColors.accentGreen, size: 20),
                          ],
                        ],
                      ),
                      if (profile.username != null) ...[
                        const SizedBox(height: 2),
                        Text('@${profile.username}', style: textTheme.bodyMedium),
                      ],
                      if (profile.accountType != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(color: const Color(0xFFFBE9DD), borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            profile.accountType == 'seller' ? 'Vendeur' : 'Acheteur',
                            style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ProfileStat(value: '${profile.listingsCount}', label: 'Annonces'),
                      _VerticalDivider(),
                      ProfileStat(value: '${profile.followersCount}', label: 'Abonnés'),
                      _VerticalDivider(),
                      ProfileStat(value: '${profile.followingCount}', label: 'Suivis'),
                      _VerticalDivider(),
                      ProfileStat(
                        value: profile.ratingAverage > 0 ? profile.ratingAverage.toStringAsFixed(1) : '—',
                        label: 'Note',
                      ),
                    ],
                  ),
                ),

                if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(profile.bio!, style: textTheme.bodyMedium, textAlign: TextAlign.center),
                ],

                const SizedBox(height: 28),

                _MenuTile(icon: Icons.storefront_outlined, label: 'Mes annonces', onTap: () => context.push('/my-listings')),
                _MenuTile(icon: Icons.favorite_border_rounded, label: 'Mes favoris', onTap: () => context.push('/favorites')),
                _MenuTile(icon: Icons.edit_outlined, label: 'Modifier mon profil', onTap: () => _notImplementedYet(context)),
                _MenuTile(icon: Icons.shield_outlined, label: 'Sécurité du compte', onTap: () => _notImplementedYet(context)),
                _MenuTile(icon: Icons.help_outline_rounded, label: 'Aide & support', onTap: () => _notImplementedYet(context)),

                const SizedBox(height: 20),

                _MenuTile(
                  icon: Icons.logout_rounded,
                  label: 'Se déconnecter',
                  color: AppColors.error,
                  onTap: () => _confirmLogout(context, ref),
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text('Impossible de charger votre profil.', style: textTheme.bodyMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => ref.invalidate(myProfileProvider), child: const Text('Réessayer')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: AppColors.border);
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, required this.onTap, this.color = AppColors.textPrimary});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color))),
            if (color == AppColors.textPrimary) const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
