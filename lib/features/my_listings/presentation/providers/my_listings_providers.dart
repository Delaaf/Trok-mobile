import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/data/models/listing_model.dart';
import '../../../home/data/repositories/listing_repository.dart';

final myListingsProvider = FutureProvider<PaginatedListings>((ref) {
  return ref.watch(listingRepositoryProvider).getMyListings();
});
