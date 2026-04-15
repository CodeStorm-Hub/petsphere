import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';
import '../views/main_layout.dart';
import '../views/create_post_screen.dart';
import '../views/messages_list_screen.dart';
import '../views/chat_screen.dart';
import '../views/match_pet_profile_screen.dart';
import '../views/product_detail_screen.dart';
import '../views/cart_screen.dart';
import '../views/notifications_screen.dart';
import '../views/create_pet_screen.dart';
import '../views/login_screen.dart';
import '../views/registration_screen.dart';
import '../views/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final status = authState.status;
      final isGoingToAuth =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isAtSplash = state.matchedLocation == '/splash';

      if (status == AuthStatus.initial) {
        return isAtSplash ? null : '/splash';
      }

      if (status == AuthStatus.unauthenticated) {
        return isGoingToAuth ? null : '/login';
      }

      if (status == AuthStatus.authenticated) {
        if (isGoingToAuth || isAtSplash) {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const MainLayout()),
      GoRoute(
        path: '/create_post',
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: '/create_pet',
        builder: (context, state) => const CreatePetScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/pet/:id',
        builder: (context, state) {
          final petId = state.pathParameters['id']!;
          return MatchPetProfileScreen(petId: petId);
        },
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => const MessagesListScreen(),
      ),
      GoRoute(
        path: '/chat/:threadId',
        builder: (context, state) {
          final threadId = state.pathParameters['threadId']!;
          return ChatScreen(threadId: threadId);
        },
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailScreen(productId: productId);
        },
      ),
    ],
  );
});
