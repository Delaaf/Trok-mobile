import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/category_model.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../data/repositories/create_listing_repository.dart';
import '../widgets/step_category.dart';
import '../widgets/step_details.dart';
import '../widgets/step_location_review.dart';
import '../widgets/step_photos.dart';
import '../widgets/wizard_progress_bar.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  static const _totalSteps = 4;
  static const _stepLabels = ['Catégorie', 'Photos', 'Détails', 'Localisation & publication'];

  final _pageController = PageController();
  int _step = 0;

  CategoryModel? _selectedCategory;
  final List<XFile> _images = [];

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _cityController = TextEditingController();
  final _communeController = TextEditingController();

  String _condition = 'good';
  bool _isFree = false;
  bool _isNegotiable = false;
  bool _acceptsExchange = false;
  final Map<String, dynamic> _attributeValues = {};

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Sans ces listeners, _canGoNext ne serait jamais réévalué pendant la
    // frappe -> le bouton "Continuer" resterait figé sur son état initial
    // (voir le même bug déjà rencontré sur les écrans d'authentification).
    for (final controller in [_titleController, _descriptionController, _priceController]) {
      controller.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() => setState(() {});

  bool get _canGoNext {
    switch (_step) {
      case 0:
        return _selectedCategory != null;
      case 1:
        return _images.isNotEmpty;
      case 2:
        return _titleController.text.trim().length >= 5 &&
            _descriptionController.text.trim().length >= 20 &&
            (_isFree || double.tryParse(_priceController.text.trim()) != null);
      default:
        return true;
    }
  }

  void _goToStep(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(step, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  void _handleBack() {
    if (_step == 0) {
      context.pop();
    } else {
      _goToStep(_step - 1);
    }
  }

  void _handleNext() {
    if (_step == _totalSteps - 1) {
      _submit();
    } else {
      _goToStep(_step + 1);
    }
  }

  Future<void> _pickImages() async {
    final remaining = 10 - _images.length;
    if (remaining <= 0) return;

    final picked = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;

    setState(() => _images.addAll(picked.take(remaining)));
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref.read(createListingRepositoryProvider).create(
            categoryId: _selectedCategory!.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            isFree: _isFree,
            price: _isFree ? null : double.tryParse(_priceController.text.trim()),
            isNegotiable: _isNegotiable,
            acceptsExchange: _acceptsExchange,
            condition: _condition,
            attributes: _attributeValues,
            city: _cityController.text.trim(),
            commune: _communeController.text.trim(),
            images: _images,
          );

      if (!mounted) return;

      // L'annonce doit passer la modération avant d'apparaître -> pas la peine
      // d'invalider maintenant, mais on le fait pour que "Mes annonces" (à venir)
      // la voie immédiatement en statut "en attente".
      ref.invalidate(nearbyListingsProvider);

      _showSuccessAndExit();
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Erreur inattendue : $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessAndExit() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.check_circle_rounded, color: AppColors.accentGreen, size: 48),
        title: const Text('Annonce envoyée !', textAlign: TextAlign.center),
        content: const Text(
          'Votre annonce est en cours de modération et sera publiée dans quelques minutes.',
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // ferme le dialog
                context.pop(); // ferme le wizard, retour à l'accueil
              },
              child: const Text('Retour à l\'accueil'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in [_titleController, _descriptionController, _priceController]) {
      controller.removeListener(_onFieldChanged);
    }
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _cityController.dispose();
    _communeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 20, 0),
              child: Row(
                children: [
                  IconButton(onPressed: _handleBack, icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
                  Text('Nouvelle annonce', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
            WizardProgressBar(currentStep: _step, totalSteps: _totalSteps, stepLabel: _stepLabels[_step]),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  categoriesAsync.when(
                    data: (categories) => StepCategory(
                      categories: categories,
                      selected: _selectedCategory,
                      onSelected: (category) => setState(() => _selectedCategory = category),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    error: (e, _) => Center(
                      child: TextButton(onPressed: () => ref.invalidate(categoriesProvider), child: const Text('Réessayer')),
                    ),
                  ),
                  StepPhotos(
                    images: _images,
                    onAddTap: _pickImages,
                    onRemove: (index) => setState(() => _images.removeAt(index)),
                  ),
                  StepDetails(
                    category: _selectedCategory,
                    titleController: _titleController,
                    descriptionController: _descriptionController,
                    priceController: _priceController,
                    condition: _condition,
                    isFree: _isFree,
                    isNegotiable: _isNegotiable,
                    acceptsExchange: _acceptsExchange,
                    attributeValues: _attributeValues,
                    onConditionChanged: (c) => setState(() => _condition = c),
                    onIsFreeChanged: (v) => setState(() => _isFree = v),
                    onIsNegotiableChanged: (v) => setState(() => _isNegotiable = v),
                    onAcceptsExchangeChanged: (v) => setState(() => _acceptsExchange = v),
                    onAttributeChanged: (key, value) => setState(() => _attributeValues[key] = value),
                  ),
                  StepLocationReview(
                    cityController: _cityController,
                    communeController: _communeController,
                    category: _selectedCategory,
                    title: _titleController.text,
                    images: _images,
                    isFree: _isFree,
                    price: _priceController.text,
                  ),
                ],
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                  child: Text(_errorMessage!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_canGoNext && !_isSubmitting) ? _handleNext : null,
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_step == _totalSteps - 1 ? 'Publier l\'annonce' : 'Continuer'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
