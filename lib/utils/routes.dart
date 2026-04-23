import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';
import '../views/main_layout.dart';
import '../views/create_post_screen.dart';
import '../views/add_pet_screen.dart';
import '../views/messages_list_screen.dart';
import '../views/chat_screen.dart';
import '../views/match_pet_profile_screen.dart';
import '../views/product_detail_screen.dart';
import '../views/post_detail_screen.dart';
import '../views/cart_screen.dart';
import '../views/order_history_screen.dart';
import '../views/notifications_screen.dart';
import '../views/liked_pets_screen.dart';
import '../views/login_screen.dart';
import '../views/registration_screen.dart';
import '../views/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<AuthState>(ref.read(authProvider));
  ref.listen<AuthState>(authProvider, (_, next) {
    authNotifier.value = next;
  });
  ref.onDispose(() => authNotifier.dispose());

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final status = authNotifier.value.status;
      final isGoingToAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register';
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
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainLayout(),
      ),
      GoRoute(
        path: '/create_post',
        builder: (context, state) {
          final petId = state.uri.queryParameters['petId'];
          return CreatePostScreen(initialPetId: petId);
        },
      ),
      GoRoute(
        path: '/add_pet',
        builder: (context, state) => const AddPetScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/liked_pets',
        builder: (context, state) => const LikedPetsScreen(),
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
      GoRoute(
        path: '/post/:id',
        builder: (context, state) {
          final postId = state.pathParameters['id']!;
          return PostDetailScreen(postId: postId);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
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
