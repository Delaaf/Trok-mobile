import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../data/models/public_profile_model.dart';
import '../../data/repositories/profile_repository.dart';

/// Le endpoint /auth/me renvoie peu de champs (voir AuthUserResource).
/// Les vraies statistiques (annonces, followers, note...) viennent de
/// PublicProfileResource via GET /users/{id} -> on enchaîne les deux appels.
final myProfileProvider = FutureProvider<PublicProfileModel>((ref) async {
  final authUser = await ref.watch(authRepositoryProvider).me();
  return ref.watch(profileRepositoryProvider).getPublicProfile(authUser.id);
});
