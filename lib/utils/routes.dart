import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';
import '../views/main_layout.dart';
import '../views/create_post_screen.dart';
import '../views/create_story_screen.dart';
import '../views/add_pet_screen.dart';
import '../views/messages_list_screen.dart';
import '../views/chat_screen.dart';
import '../views/pet_profile_screen.dart';
import '../views/product_detail_screen.dart';
import '../views/post_detail_screen.dart';
import '../views/cart_screen.dart';
import '../views/order_history_screen.dart';
import '../views/notifications_screen.dart';
import '../views/liked_pets_screen.dart';
import '../views/login_screen.dart';
import '../views/registration_screen.dart';
import '../views/settings_screen.dart';
import '../views/splash_screen.dart';
import '../views/pet_care_screen.dart';
import '../views/story_viewer_screen.dart';

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
        path: '/create_story',
        builder: (context, state) {
          final petId = state.uri.queryParameters['petId'];
          return CreateStoryScreen(initialPetId: petId);
        },
      ),
      GoRoute(
        path: '/add_pet',
        builder: (context, state) => const AddPetScreen(),
      ),
      GoRoute(
        path: '/pet_care',
        builder: (context, state) => const PetCareScreen(),
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
          return PetProfileScreen(visitPetId: petId);
        },
      ),
      GoRoute(
        path: '/user/:id',
        builder: (context, state) {
          final userId = state.pathParameters['id']!;
          return PetProfileScreen(visitUserId: userId);
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
        path: '/story/:petId',
        builder: (context, state) {
          final petId = state.pathParameters['petId']!;
          return StoryViewerScreen(petId: petId);
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
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                'We could not find what you were looking for.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.uri.toString(),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Go home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});
