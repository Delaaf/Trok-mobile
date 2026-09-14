import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/listing_model.dart';

class ListingImageCarousel extends StatefulWidget {
  const ListingImageCarousel({
    super.key,
    required this.images,
    required this.isFavorited,
    required this.onBackTap,
    required this.onFavoriteTap,
  });

  final List<ListingImageModel> images;
  final bool isFavorited;
  final VoidCallback onBackTap;
  final VoidCallback onFavoriteTap;

  @override
  State<ListingImageCarousel> createState() => _ListingImageCarouselState();
}

class _ListingImageCarouselState extends State<ListingImageCarousel> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    // Récupération de la hauteur de la barre de statut top (ex: 24 à 48dp)
    final topPadding = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 340 + topPadding, // On ajuste la hauteur globale avec l'encoche
      child: Stack(
        fit: StackFit.expand,
        children: [
          images.isEmpty
              ? Container(
                  color: AppColors.surfaceMuted,
                  child: const Icon(Icons.image_outlined, size: 48, color: AppColors.textMuted),
                )
              : PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: images[index].url,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: AppColors.surfaceMuted,
                        highlightColor: AppColors.background,
                        child: Container(color: AppColors.surfaceMuted),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surfaceMuted,
                        child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted),
                      ),
                    );
                  },
                ),

          // 1. Dégradé : Enveloppé dans IgnorePointer pour ne PAS intercepter les clics
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100 + topPadding,
            child: const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black38, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

          // Indicateurs de page
          if (images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),

          // 2. Boutons flottants : Positionnés SOUS la barre de statut (topPadding)
          Positioned(
            top: topPadding + 8,
            left: 16,
            child: _FloatingCircleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () {
                debugPrint('[ListingImageCarousel] Tap RETOUR');
                widget.onBackTap();
              },
            ),
          ),
          Positioned(
            top: topPadding + 8,
            right: 16,
            child: _FloatingCircleButton(
              icon: widget.isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              iconColor: widget.isFavorited ? AppColors.primary : AppColors.textPrimary,
              onTap: () {
                debugPrint('[ListingImageCarousel] Tap FAVORI (isFavorited=${widget.isFavorited})');
                widget.onFavoriteTap();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingCircleButton extends StatelessWidget {
  const _FloatingCircleButton({required this.icon, required this.onTap, this.iconColor = AppColors.textPrimary});

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
}