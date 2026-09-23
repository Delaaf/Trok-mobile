import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/listing_model.dart';
import '../../../home/data/repositories/listing_repository.dart';
import '../providers/my_listings_providers.dart';

class EditListingScreen extends ConsumerStatefulWidget {
  const EditListingScreen({super.key, required this.listing});

  final ListingModel listing;

  @override
  ConsumerState<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends ConsumerState<EditListingScreen> {
  late final _titleController = TextEditingController(text: widget.listing.title);
  late final _descriptionController = TextEditingController(text: widget.listing.description ?? '');
  late final _priceController = TextEditingController(text: widget.listing.isFree ? '' : widget.listing.price.toStringAsFixed(0));
  late final _cityController = TextEditingController(text: widget.listing.city ?? '');
  late final _communeController = TextEditingController(text: widget.listing.commune ?? '');

  late String _condition = widget.listing.condition;
  late bool _isNegotiable = widget.listing.isNegotiable;
  late bool _acceptsExchange = widget.listing.acceptsExchange;

  bool _isSubmitting = false;
  String? _errorMessage;

  static const _conditions = [
    ('new', 'Neuf'),
    ('like_new', 'Comme neuf'),
    ('good', 'Bon état'),
    ('fair', 'État correct'),
    ('for_parts', 'Pour pièces'),
  ];

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref.read(listingRepositoryProvider).updateListing(widget.listing.id, {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        if (!widget.listing.isFree) 'price': double.tryParse(_priceController.text.trim()) ?? widget.listing.price,
        'condition': _condition,
        'is_negotiable': _isNegotiable,
        'accepts_exchange': _acceptsExchange,
        'city': _cityController.text.trim(),
        'commune': _communeController.text.trim(),
      });

      if (!mounted) return;
      ref.invalidate(myListingsProvider);
      context.pop(true);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _cityController.dispose();
    _communeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
                  Text('Modifier l\'annonce', style: textTheme.titleLarge),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFFBF1D8), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.accentGold, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Les photos ne peuvent pas encore être modifiées ici. Toute modification repasse par la modération.',
                              style: textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Titre')),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
                    ),
                    const SizedBox(height: 16),

                    Text('État de l\'article', style: textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _conditions.map((c) {
                        final isSelected = _condition == c.$1;
                        return ChoiceChip(
                          label: Text(c.$2),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _condition = c.$1),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceMuted,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    if (!widget.listing.isFree) ...[
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Prix (FCFA)'),
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _isNegotiable,
                        onChanged: (v) => setState(() => _isNegotiable = v),
                        activeThumbColor: AppColors.primary,
                        title: const Text('Prix négociable'),
                      ),
                    ],
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _acceptsExchange,
                      onChanged: (v) => setState(() => _acceptsExchange = v),
                      activeThumbColor: AppColors.primary,
                      title: const Text('Ouvert au troc/échange'),
                    ),
                    const SizedBox(height: 12),

                    TextField(controller: _cityController, decoration: const InputDecoration(labelText: 'Ville')),
                    const SizedBox(height: 8),
                    TextField(controller: _communeController, decoration: const InputDecoration(labelText: 'Commune / Quartier')),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                        child: Text(_errorMessage!, style: textTheme.bodySmall?.copyWith(color: AppColors.error)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Enregistrer les modifications'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
