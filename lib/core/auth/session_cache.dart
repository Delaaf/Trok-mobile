import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/favorites/presentation/providers/favorites_providers.dart';
import '../../features/home/presentation/providers/favorite_overrides_provider.dart';
import '../../features/home/presentation/providers/home_providers.dart';
import '../../features/messaging/presentation/providers/messaging_providers.dart';
import '../../features/my_listings/presentation/providers/my_listings_providers.dart';
import '../../features/profile/presentation/providers/profile_providers.dart';

/// Invalide tout le cache Riverpod SPÉCIFIQUE à un utilisateur connecté.
///
/// Sans ça, se déconnecter puis se reconnecter avec un autre compte affiche
/// encore les données du compte précédent (profil, conversations, favoris,
/// annonces...) jusqu'à ce que chaque écran soit individuellement rafraîchi
/// à la main -> à appeler impérativement juste après un login/OTP réussi ET
/// juste avant/après une déconnexion.
///
/// `categoriesProvider` n'a pas besoin d'être invalidé ici : son contenu est
/// identique pour tout le monde, ce n'est pas une donnée liée au compte.
void clearUserScopedCache(WidgetRef ref) {
  ref.invalidate(myProfileProvider);
  ref.invalidate(conversationsProvider);
  ref.invalidate(myFavoritesProvider);
  ref.invalidate(myListingsProvider);
  ref.invalidate(favoriteOverridesProvider);
  // nearbyListingsProvider est un FutureProvider.family : invalider la
  // famille (sans argument) invalide TOUTES ses instances déjà en cache
  // (une par filtre de localisation déjà consulté), pas juste une seule.
  ref.invalidate(nearbyListingsProvider);
}
