import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';

class StepPhotos extends StatelessWidget {
  const StepPhotos({super.key, required this.images, required this.onAddTap, required this.onRemove});

  final List<XFile> images;
  final VoidCallback onAddTap;
  final ValueChanged<int> onRemove;

  static const _maxImages = 10;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ajoutez des photos', style: textTheme.headlineLarge),
          const SizedBox(height: 6),
          Text(
            'La première photo sera la couverture de votre annonce. Jusqu\'à $_maxImages photos.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: images.length < _maxImages ? images.length + 1 : images.length,
            itemBuilder: (context, index) {
              if (index == images.length) {
                return InkWell(
                  onTap: onAddTap,
                  borderRadius: BorderRadius.circular(14),
                  child: DottedBorderBox(
                    child: const Center(
                      child: Icon(Icons.add_photo_alternate_outlined, color: AppColors.textMuted, size: 28),
                    ),
                  ),
                );
              }

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox.expand(
                      child: Image.file(File(images[index].path), fit: BoxFit.cover),
                    ),
                  ),
                  if (index == 0)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                        child: const Text('Couverture', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => onRemove(index),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.close_rounded, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.5),
        color: AppColors.surfaceMuted,
      ),
      child: child,
    );
  }
}
