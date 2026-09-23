import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/data/models/listing_model.dart';
import '../../../home/data/repositories/favorite_repository.dart';

final myFavoritesProvider = FutureProvider<PaginatedListings>((ref) {
  return ref.watch(favoriteRepositoryProvider).getMyFavorites();
});
