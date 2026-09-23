import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/create_listing/presentation/screens/create_listing_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/home/data/models/listing_model.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/listing_detail/presentation/screens/listing_detail_screen.dart';
import '../../features/messaging/presentation/screens/chat_screen.dart';
import '../../features/messaging/presentation/screens/chat_screen_args.dart';
import '../../features/messaging/presentation/screens/conversations_screen.dart';
import '../../features/my_listings/presentation/screens/edit_listing_screen.dart';
import '../../features/my_listings/presentation/screens/my_listings_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', name: 'splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/welcome', name: 'welcome', builder: (context, state) => const WelcomeScreen()),
    GoRoute(path: '/login', name: 'login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', name: 'register', builder: (context, state) => const RegisterScreen()),
    GoRoute(
      path: '/otp',
      name: 'otp',
      builder: (context, state) {
        final identifier = state.uri.queryParameters['identifier'] ?? '';
        final purpose = state.uri.queryParameters['purpose'] ?? 'registration';
        return OtpVerificationScreen(identifier: identifier, purpose: purpose);
      },
    ),
    GoRoute(path: '/', name: 'home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/listing/:id',
      name: 'listing-detail',
      builder: (context, state) => ListingDetailScreen(listingId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/create-listing',
      name: 'create-listing',
      builder: (context, state) => const CreateListingScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/favorites',
      name: 'favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/messages',
      name: 'messages',
      builder: (context, state) => const ConversationsScreen(),
    ),
    GoRoute(
      path: '/messages/chat',
      name: 'chat',
      builder: (context, state) => ChatScreen(args: state.extra as ChatScreenArgs),
    ),
    GoRoute(
      path: '/my-listings',
      name: 'my-listings',
      builder: (context, state) => const MyListingsScreen(),
    ),
    GoRoute(
      path: '/listing/:id/edit',
      name: 'listing-edit',
      builder: (context, state) => EditListingScreen(listing: state.extra as ListingModel),
    ),
    // Routes à venir : /category/:id...
  ],
);

