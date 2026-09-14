import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/listing_detail/presentation/screens/listing_detail_screen.dart';

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
    // Routes à venir : /search, /messages, /profile, /category/:id...
  ],
);
