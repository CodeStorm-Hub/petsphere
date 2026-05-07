import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';
import 'safe_route_params.dart';
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
import '../views/pet_care_onboarding_screen.dart';
import '../views/story_viewer_screen.dart';
import '../views/search_screen.dart';
import '../views/gamification_screen.dart';
import '../views/vet_booking_screen.dart';
import '../views/emergency_care_screen.dart';
import '../views/community_groups_screen.dart';
import '../views/lost_and_found_screen.dart';
import '../views/adoption_center_screen.dart';
import '../views/pet_training_screen.dart';
import '../views/pet_insurance_hub_screen.dart';
import '../views/pet_expense_tracker_screen.dart';
import '../views/pet_growth_chart_screen.dart';
import '../views/pet_memorial_screen.dart';
import '../views/pet_memorial_detail_screen.dart';
import '../views/pet_friendly_places_screen.dart';
import '../views/pet_event_discovery_screen.dart';
import '../views/pet_health_record_export_screen.dart';
import '../views/pet_health_record_screen.dart';
import '../views/pet_sitter_dashboard_screen.dart';
import '../views/pet_nutrition_planner_screen.dart';
import '../views/pet_social_timeline_screen.dart';
import '../views/pet_breed_identifier_screen.dart';
import '../views/pet_knowledge_base_screen.dart';
import '../views/pet_gear_reviews_screen.dart';
import '../views/pet_followers_screen.dart';

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
      final isGoingToAuth = state.matchedLocation == '/login' ||
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
        path: '/pet_care_onboarding',
        builder: (context, state) {
          final id = state.uri.queryParameters['petId'];
          if (id == null || id.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Missing pet')),
            );
          }
          return PetCareOnboardingScreen(petId: id);
        },
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
          final petId = safePathParam(state, 'id');
          if (petId == null) {
            return const InvalidRouteErrorScreen(missingParam: 'pet ID');
          }
          return PetProfileScreen(visitPetId: petId);
        },
      ),
      GoRoute(
        path: '/user/:id',
        builder: (context, state) {
          final userId = safePathParam(state, 'id');
          if (userId == null) {
            return const InvalidRouteErrorScreen(missingParam: 'user ID');
          }
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
          final threadId = safePathParam(state, 'threadId');
          if (threadId == null) {
            return const InvalidRouteErrorScreen(missingParam: 'thread ID');
          }
          return ChatScreen(threadId: threadId);
        },
      ),
      GoRoute(
        path: '/post/:id',
        builder: (context, state) {
          final postId = safePathParam(state, 'id');
          if (postId == null) {
            return const InvalidRouteErrorScreen(missingParam: 'post ID');
          }
          return PostDetailScreen(postId: postId);
        },
      ),
      GoRoute(
        path: '/story/:petId',
        builder: (context, state) {
          final petId = safePathParam(state, 'petId');
          if (petId == null) {
            return const InvalidRouteErrorScreen(missingParam: 'pet ID');
          }
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
          final productId = safePathParam(state, 'id');
          if (productId == null) {
            return const InvalidRouteErrorScreen(missingParam: 'product ID');
          }
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/pet/:id/followers',
        builder: (context, state) {
          final petId = safePathParam(state, 'id');
          if (petId == null) {
            return const InvalidRouteErrorScreen(missingParam: 'pet ID');
          }
          return PetFollowersScreen(
            petId: petId,
            type: FollowListType.petFollowers,
          );
        },
      ),
      GoRoute(
        path: '/user/:id/followers',
        builder: (context, state) {
          final userId = safePathParam(state, 'id');
          if (userId == null) {
            return const InvalidRouteErrorScreen(missingParam: 'user ID');
          }
          return PetFollowersScreen(
            userId: userId,
            type: FollowListType.ownerFollowers,
          );
        },
      ),
      GoRoute(
        path: '/user/:id/following',
        builder: (context, state) {
          final userId = safePathParam(state, 'id');
          if (userId == null) {
            return const InvalidRouteErrorScreen(missingParam: 'user ID');
          }
          return PetFollowersScreen(
            userId: userId,
            type: FollowListType.following,
          );
        },
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const GamificationScreen(),
      ),
      GoRoute(
        path: '/vet_booking',
        builder: (context, state) => const VetBookingScreen(),
      ),
      GoRoute(
        path: '/emergency_care',
        builder: (context, state) => const EmergencyCareScreen(),
      ),
      GoRoute(
        path: '/community_groups',
        builder: (context, state) => const CommunityGroupsScreen(),
      ),
      GoRoute(
        path: '/lost_and_found',
        builder: (context, state) => const LostAndFoundScreen(),
      ),
      GoRoute(
        path: '/adoption_center',
        builder: (context, state) => const AdoptionCenterScreen(),
      ),
      GoRoute(
        path: '/training',
        builder: (context, state) => const PetTrainingScreen(),
      ),
      GoRoute(
        path: '/insurance',
        builder: (context, state) => const PetInsuranceHubScreen(),
      ),
      GoRoute(
        path: '/expenses',
        builder: (context, state) => const PetExpenseTrackerScreen(),
      ),
      GoRoute(
        path: '/growth_charts',
        builder: (context, state) => const PetGrowthChartScreen(),
      ),
      GoRoute(
        path: '/memorial',
        builder: (context, state) => const PetMemorialScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = safePathParam(state, 'id');
              if (id == null) {
                return const InvalidRouteErrorScreen(missingParam: 'memorial ID');
              }
              return PetMemorialDetailScreen(memorialId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/pet_friendly_places',
        builder: (context, state) => const PetFriendlyPlacesScreen(),
      ),
      GoRoute(
        path: '/events',
        builder: (context, state) => const PetEventDiscoveryScreen(),
      ),
      GoRoute(
        path: '/medical_records',
        builder: (context, state) => const PetHealthRecordScreen(),
      ),
      GoRoute(
        path: '/export_records',
        builder: (context, state) => const PetHealthRecordExportScreen(),
      ),
      GoRoute(
        path: '/sitters',
        builder: (context, state) => const PetSitterDashboardScreen(),
      ),
      GoRoute(
        path: '/nutrition_planner',
        builder: (context, state) => const PetNutritionPlannerScreen(),
      ),
      GoRoute(
        path: '/pet_timeline',
        builder: (context, state) => const PetSocialTimelineScreen(),
      ),
      GoRoute(
        path: '/breed_identifier',
        builder: (context, state) => const PetBreedIdentifierScreen(),
      ),
      GoRoute(
        path: '/knowledge_base',
        builder: (context, state) => const PetKnowledgeBaseScreen(),
      ),
      GoRoute(
        path: '/gear_reviews',
        builder: (context, state) => const PetGearReviewsScreen(),
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
              Icon(Icons.error_outline,
                  size: 56, color: Theme.of(context).colorScheme.error),
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
