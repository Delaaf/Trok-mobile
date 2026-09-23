import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category_model.dart';
import '../../data/models/listing_model.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/listing_repository.dart';

/// Catégories racines avec leurs enfants — mises en cache côté backend (6h),
/// donc pas besoin de refetch agressif ici.
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  return ref.watch(catalogRepositoryProvider).getCategories();
});

/// Annonces "près de chez vous" pour la home. La clé combine ville, commune
/// et localisation libre (record Dart, comparé par valeur -> fonctionne
/// nativement comme clé de family). Tous nuls -> aucune localisation choisie.
final nearbyListingsProvider = FutureProvider.family<PaginatedListings, ({String? city, String? commune, String? location})>((ref, filter) {
  return ref.watch(listingRepositoryProvider).getListings(
        city: filter.city,
        commune: filter.commune,
        location: filter.location,
        sort: 'recent',
      );
});

/// Détail d'une annonce précise (écran de détail).
final listingDetailProvider = FutureProvider.family<ListingModel, String>((ref, listingId) {
  return ref.watch(listingRepositoryProvider).getListing(listingId);
});
