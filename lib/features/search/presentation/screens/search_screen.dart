import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/listing_model.dart';
import '../../../home/data/repositories/listing_repository.dart';
import '../../../home/presentation/providers/favorite_overrides_provider.dart';
import '../../../home/presentation/widgets/listing_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;
  List<ListingModel> _results = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
    _controller.addListener(_onQueryChanged);
  }

  void _onQueryChanged() {
    setState(() {}); // pour rafraîchir la croix "effacer" et l'état vide/résultats

    _debounce?.cancel();
    final query = _controller.text.trim();

    if (query.isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() => _isLoading = true);
    _debounce = Timer(const Duration(milliseconds: 450), () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    try {
      final paginated = await ref.read(listingRepositoryProvider).getListings(query: query, sort: 'relevance');
      if (!mounted) return;
      setState(() {
        _results = paginated.items;
        _hasSearched = true;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Une erreur est survenue. Réessayez.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteOverrides = ref.watch(favoriteOverridesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Que recherchez-vous ?',
                          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                          suffixIcon: _controller.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                                  onPressed: _controller.clear,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody(favoriteOverrides)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(Map<String, bool> favoriteOverrides) {
    final textTheme = Theme.of(context).textTheme;

    if (_controller.text.trim().isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_rounded, size: 40, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text('Recherchez parmi toutes les annonces de Trok', style: textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 36, color: AppColors.error),
            const SizedBox(height: 10),
            Text(_errorMessage!, style: textTheme.bodyMedium),
          ],
        ),
      );
    }

    if (_hasSearched && _results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, size: 40, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text('Aucun résultat pour "${_controller.text.trim()}"', style: textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.68,
      ),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final listing = _results[index];
        return ListingCard(
          listing: listing,
          isFavorited: favoriteOverrides[listing.id] ?? listing.isFavoritedByViewer,
          onTap: () => context.push('/listing/${listing.id}'),
          onFavoriteTap: () => ref.read(favoriteOverridesProvider.notifier).toggle(listing),
        );
      },
    );
  }
}
