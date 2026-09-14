import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/listing_model.dart';
import '../../data/repositories/favorite_repository.dart';

/// Source de vérité unique pour l'état "favori" d'une annonce, partagée par
/// TOUS les écrans (accueil, détail, futur écran favoris...). Sans ça, chaque
/// écran garde son propre state local qui s'oublie dès qu'on change de page.
///
/// `state` ne contient que les annonces dont l'état a été BASCULÉ localement
/// (mise à jour optimiste) ; pour toute annonce absente de la map, on se fie
/// simplement à `listing.isFavoritedByViewer` renvoyé par l'API.
class FavoriteOverridesNotifier extends StateNotifier<Map<String, bool>> {
  FavoriteOverridesNotifier(this._ref) : super({});

  final Ref _ref;

  bool isFavorited(ListingModel listing) => state[listing.id] ?? listing.isFavoritedByViewer;

  Future<void> toggle(ListingModel listing) async {
    final current = isFavorited(listing);
    final next = !current;

    // Mise à jour optimiste immédiate, visible instantanément sur TOUS les
    // écrans qui observent ce provider (pas seulement celui où on a tapé).
    state = {...state, listing.id: next};

    try {
      final repo = _ref.read(favoriteRepositoryProvider);
      if (current) {
        await repo.remove(listing.id);
      } else {
        await repo.add(listing.id);
      }
    } catch (_) {
      // Échec réseau -> on annule pour rester cohérent avec le serveur.
      state = {...state, listing.id: current};
    }
  }
}

final favoriteOverridesProvider = StateNotifierProvider<FavoriteOverridesNotifier, Map<String, bool>>(
  (ref) => FavoriteOverridesNotifier(ref),
);
