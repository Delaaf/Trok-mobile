import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/trok_bottom_nav.dart';
import '../providers/messaging_providers.dart';
import '../widgets/conversation_tile.dart';
import 'chat_screen_args.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  void _handleNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        context.go('/favorites');
      case 2:
        context.push('/create-listing'); // flux à part, reste en push
      case 3:
        break; // déjà ici
      case 4:
        context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    debugPrint('[ConversationsScreen] build() — état: ${conversationsAsync.runtimeType}, isLoading=${conversationsAsync.isLoading}, hasValue=${conversationsAsync.hasValue}');
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: TrokBottomNav(currentIndex: 3, onTap: (index) => _handleNavTap(context, index)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text('Messages', style: textTheme.displayMedium),
            ),
            Expanded(
              child: conversationsAsync.when(
                data: (conversations) {
                  if (conversations.isEmpty) return const _EmptyConversations();

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      ref.invalidate(conversationsProvider);
                      await ref.read(conversationsProvider.future);
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: conversations.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        return ConversationTile(
                          conversation: conversation,
                          onTap: () => context.push('/messages/chat', extra: ChatScreenArgs.existing(conversation)),
                        );
                      },
                    ),
                  );
                },
                loading: () => const _ConversationsShimmer(),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text('Impossible de charger tes messages.', style: textTheme.bodyMedium, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: () => ref.invalidate(conversationsProvider), child: const Text('Réessayer')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyConversations extends StatelessWidget {
  const _EmptyConversations();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, size: 44, color: AppColors.textMuted),
            const SizedBox(height: 14),
            Text('Aucune conversation', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              'Contacte un vendeur depuis une annonce pour démarrer une discussion.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationsShimmer extends StatelessWidget {
  const _ConversationsShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceMuted,
      highlightColor: AppColors.background,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 6,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              const CircleAvatar(radius: 26, backgroundColor: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 12, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 180, height: 10, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
