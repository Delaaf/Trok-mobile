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

/// Annonces "près de chez vous" pour la home. `commune` est nullable :
/// null tant que l'utilisateur n'a pas choisi de quartier -> montre les plus récentes.
final nearbyListingsProvider = FutureProvider.family<PaginatedListings, String?>((ref, commune) {
  return ref.watch(listingRepositoryProvider).getListings(commune: commune, sort: 'recent');
});

/// Détail d'une annonce précise (écran de détail).
final listingDetailProvider = FutureProvider.family<ListingModel, String>((ref, listingId) {
  return ref.watch(listingRepositoryProvider).getListing(listingId);
});
