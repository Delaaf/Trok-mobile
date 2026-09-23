import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/location_search_result.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/services/location_service.dart';
import '../utils/communes.dart';

/// `null` = fermé sans choisir (ne pas modifier le filtre actuel).
/// Un LocationPoint avec city/commune/freeText nuls = "Toutes les localités".
Future<LocationPoint?> showLocationPicker(BuildContext context, {LocationPoint? current}) {
  return showModalBottomSheet<LocationPoint?>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _LocationPickerSheet(current: current),
  );
}

const _allLocationsSentinel = LocationPoint(label: 'Toutes les localités', latitude: 0, longitude: 0);

class _LocationPickerSheet extends ConsumerStatefulWidget {
  const _LocationPickerSheet({required this.current});

  final LocationPoint? current;

  @override
  ConsumerState<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends ConsumerState<_LocationPickerSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  bool _isDetecting = false;
  bool _isSearching = false;
  String? _errorMessage;
  List<LocationSearchResult> _searchResults = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onQueryChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    setState(() {}); // rafraîchit la croix "effacer" + bascule vue par défaut/résultats

    _debounce?.cancel();
    final query = _searchController.text.trim();

    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 450), () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    try {
      final results = await ref.read(locationRepositoryProvider).search(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _hasSearched = true;
        _isSearching = false;
      });
    } on ApiException catch (_) {
      if (!mounted) return;
      setState(() => _isSearching = false);
    }
  }

  Future<void> _useMyLocation() async {
    setState(() {
      _isDetecting = true;
      _errorMessage = null;
    });

    final result = await ref.read(locationServiceProvider).detectNearestLocation();

    if (!mounted) return;

    if (!result.isSuccess) {
      setState(() {
        _isDetecting = false;
        _errorMessage = switch (result.error!) {
          LocationDetectionError.permissionDenied => 'Autorisation de localisation refusée. Active-la dans les paramètres.',
          LocationDetectionError.serviceDisabled => 'Le GPS est désactivé sur ton appareil.',
          LocationDetectionError.timeout => 'Impossible d\'obtenir ta position. Réessaie.',
          LocationDetectionError.unknown => 'Une erreur est survenue.',
        };
      });
      return;
    }

    Navigator.of(context).pop(result.point);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isAllSelected = widget.current == null || (widget.current!.city == null && widget.current!.freeText == null);
    final query = _searchController.text.trim();
    final showingSearch = query.length >= 2;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Text('Choisir une localisation', style: textTheme.headlineMedium),
                const SizedBox(height: 14),

                Container(
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      filled: false,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      hintText: 'Rechercher une ville, un village...',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                              onPressed: _searchController.clear,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      if (!showingSearch) ...[
                        const SizedBox(height: 6),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: _isDetecting
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                              : const Icon(Icons.my_location_rounded, color: AppColors.primary),
                          title: const Text('Utiliser ma position actuelle', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                          onTap: _isDetecting ? null : _useMyLocation,
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(_errorMessage!, style: textTheme.bodySmall?.copyWith(color: AppColors.error)),
                          ),
                        const Divider(height: 24),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.public, color: AppColors.textSecondary),
                          title: const Text('Toutes les localités'),
                          trailing: isAllSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                          onTap: () => Navigator.of(context).pop(_allLocationsSentinel),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 4),
                          child: Text('ABIDJAN', style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                        ),
                        ...abidjanCommunes.map((point) => _CuratedTile(
                              point: point,
                              isSelected: widget.current?.commune == point.commune,
                              onTap: () => Navigator.of(context).pop(point),
                            )),
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 4),
                          child: Text('GRANDES VILLES', style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                        ),
                        ...otherIvorianCities.map((point) => _CuratedTile(
                              point: point,
                              isSelected: widget.current?.city == point.city && widget.current?.commune == null,
                              onTap: () => Navigator.of(context).pop(point),
                            )),
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Text(
                            'Tape au moins 2 lettres ci-dessus pour chercher parmi toutes les autres villes et villages de Côte d\'Ivoire.',
                            style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                          ),
                        ),
                      ] else if (_isSearching) ...[
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                        ),
                      ] else if (_hasSearched && _searchResults.isEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Column(
                            children: [
                              const Icon(Icons.location_off_outlined, size: 32, color: AppColors.textMuted),
                              const SizedBox(height: 10),
                              Text('Aucun résultat pour "$query"', style: textTheme.bodyMedium, textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ] else
                        ..._searchResults.map((result) {
                          final point = LocationPoint(
                            label: result.name,
                            latitude: result.latitude,
                            longitude: result.longitude,
                            freeText: result.name,
                          );
                          return _CuratedTile(
                            point: point,
                            isSelected: widget.current?.freeText == result.name,
                            onTap: () => Navigator.of(context).pop(point),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CuratedTile extends StatelessWidget {
  const _CuratedTile({required this.point, required this.isSelected, required this.onTap});

  final LocationPoint point;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(point.commune != null ? Icons.location_on_outlined : Icons.location_city_outlined, color: AppColors.textSecondary),
      title: Text(point.label),
      subtitle: point.commune != null ? const Text('Abidjan', style: TextStyle(fontSize: 11, color: AppColors.textMuted)) : null,
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
      onTap: onTap,
    );
  }
}
