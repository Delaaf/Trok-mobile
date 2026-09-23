import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../messaging/presentation/providers/messaging_providers.dart';

class TrokBottomNav extends ConsumerWidget {
  const TrokBottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // .whenOrNull(data: ...) pour ne pas déclencher de refetch depuis un simple
    // widget de navigation -> se contente de la valeur déjà en cache, si dispo.
    final unreadCount = ref.watch(conversationsProvider).whenOrNull(
              data: (conversations) => conversations.fold<int>(0, (sum, c) => sum + c.unreadCount),
            ) ??
        0;

    return Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home_rounded, label: 'Accueil', isActive: currentIndex == 0, onTap: () => onTap(0)),
            _NavItem(icon: Icons.favorite_border_rounded, label: 'Favoris', isActive: currentIndex == 1, onTap: () => onTap(1)),
            _SellButton(onTap: () => onTap(2)),
            _NavItem(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Messages',
              isActive: currentIndex == 3,
              onTap: () => onTap(3),
              badgeCount: unreadCount,
            ),
            _NavItem(icon: Icons.person_outline_rounded, label: 'Profil', isActive: currentIndex == 4, onTap: () => onTap(4)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.isActive, required this.onTap, this.badgeCount = 0});

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 24),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      constraints: const BoxConstraints(minWidth: 16),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.surface, width: 1.5)),
                      child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _SellButton extends StatelessWidget {
  const _SellButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -14),
      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: AppColors.primary.withValues(alpha: 0.4),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
