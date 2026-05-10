import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petfolio/core/constants/app_routes.dart';
import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petfolio/core/utils/safe_route_params.dart';
import 'package:petfolio/app/main_layout.dart';
import 'package:petfolio/features/home/presentation/screens/home_screen.dart';
import 'package:petfolio/features/match/presentation/screens/discovery_screen.dart';
import 'package:petfolio/features/marketplace/presentation/screens/marketplace_screen.dart';
import 'package:petfolio/features/pet/presentation/screens/pet_profile_screen.dart';
import 'package:petfolio/features/social/presentation/screens/create_post_screen.dart';
import 'package:petfolio/features/social/presentation/screens/create_story_screen.dart';
import 'package:petfolio/features/pet/presentation/screens/add_pet_screen.dart';
import 'package:petfolio/features/messaging/presentation/screens/messages_list_screen.dart';
import 'package:petfolio/features/messaging/presentation/screens/chat_screen.dart';
import 'package:petfolio/features/marketplace/presentation/screens/product_detail_screen.dart';
import 'package:petfolio/features/social/presentation/screens/post_detail_screen.dart';
import 'package:petfolio/features/marketplace/presentation/screens/cart_screen.dart';
import 'package:petfolio/features/marketplace/presentation/screens/order_history_screen.dart';
import 'package:petfolio/features/social/presentation/screens/pet_followers_screen.dart';
import 'package:petfolio/features/pet/presentation/screens/visitor_pet_profile_screen.dart';
import 'package:petfolio/features/social/presentation/screens/visitor_user_profile_screen.dart';
import 'package:petfolio/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:petfolio/features/pet/presentation/screens/liked_pets_screen.dart';
import 'package:petfolio/features/auth/presentation/screens/login_screen.dart';
import 'package:petfolio/features/auth/presentation/screens/registration_screen.dart';
import 'package:petfolio/features/settings/presentation/screens/settings_screen.dart';
import 'package:petfolio/features/auth/presentation/screens/splash_screen.dart';
import 'package:petfolio/features/care/presentation/screens/pet_care_screen.dart';
import 'package:petfolio/features/care/presentation/screens/pet_care_onboarding_screen.dart';
import 'package:petfolio/features/social/presentation/screens/story_viewer_screen.dart';
import 'package:petfolio/features/services/presentation/screens/article_detail_screen.dart';
import 'package:petfolio/features/services/data/models/knowledge_base_models.dart';
import 'package:petfolio/features/discovery/presentation/screens/search_screen.dart';
import 'package:petfolio/features/care/presentation/screens/gamification_screen.dart';
import 'package:petfolio/features/health/presentation/screens/vet_booking_screen.dart';
import 'package:petfolio/features/health/presentation/screens/emergency_care_screen.dart';
import 'package:petfolio/features/community/presentation/screens/community_groups_screen.dart';
import 'package:petfolio/features/services/presentation/screens/lost_and_found_screen.dart';
import 'package:petfolio/features/services/presentation/screens/adoption_center_screen.dart';
import 'package:petfolio/features/care/presentation/screens/pet_training_screen.dart';
import 'package:petfolio/features/services/presentation/screens/pet_insurance_hub_screen.dart';
import 'package:petfolio/features/care/presentation/screens/pet_expense_tracker_screen.dart';
import 'package:petfolio/features/health/presentation/screens/pet_growth_chart_screen.dart';
import 'package:petfolio/features/social/presentation/screens/pet_memorial_screen.dart';
import 'package:petfolio/features/social/presentation/screens/pet_memorial_detail_screen.dart';
import 'package:petfolio/features/services/presentation/screens/pet_friendly_places_screen.dart';
import 'package:petfolio/features/services/presentation/screens/pet_event_discovery_screen.dart';
import 'package:petfolio/features/health/presentation/screens/pet_health_record_export_screen.dart';
import 'package:petfolio/features/health/presentation/screens/pet_health_record_screen.dart';
import 'package:petfolio/features/services/presentation/screens/pet_sitter_dashboard_screen.dart';
import 'package:petfolio/features/care/presentation/screens/pet_nutrition_planner_screen.dart';
import 'package:petfolio/features/social/presentation/screens/pet_social_timeline_screen.dart';
import 'package:petfolio/features/services/presentation/screens/pet_breed_identifier_screen.dart';
import 'package:petfolio/features/services/presentation/screens/pet_knowledge_base_screen.dart';
import 'package:petfolio/features/marketplace/presentation/screens/pet_gear_reviews_screen.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<AuthState>(ref.read(authProvider));
  ref.listen<AuthState>(authProvider, (_, next) {
    authNotifier.value = next;
  });
  ref.onDispose(() => authNotifier.dispose());

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final status = authNotifier.value.status;
      final isGoingToAuth =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;
      final isAtSplash = state.matchedLocation == AppRoutes.splash;

      if (status == AuthStatus.initial) {
        return isAtSplash ? null : AppRoutes.splash;
      }

      if (status == AuthStatus.unauthenticated) {
        return isGoingToAuth ? null : AppRoutes.login;
      }

      if (status == AuthStatus.authenticated) {
        if (isGoingToAuth || isAtSplash) {
          return AppRoutes.home;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegistrationScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            MainLayout(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.discover,
                builder: (context, state) => const DiscoveryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.shop,
                builder: (context, state) => const MarketplaceScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const PetProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.createPost,
        builder: (context, state) {
          final petId = state.uri.queryParameters['petId'];
          return CreatePostScreen(initialPetId: petId);
        },
      ),
      GoRoute(
        path: AppRoutes.createStory,
        builder: (context, state) {
          final petId = state.uri.queryParameters['petId'];
          return CreateStoryScreen(initialPetId: petId);
        },
      ),
      GoRoute(
        path: AppRoutes.addPet,
        builder: (context, state) {
          final pet = state.extra as PetModel?;
          return AddPetScreen(pet: pet);
        },
      ),
      GoRoute(
        path: AppRoutes.petCare,
        builder: (context, state) => const PetCareScreen(),
      ),
      GoRoute(
        path: AppRoutes.petCareOnboarding,
        builder: (context, state) {
          final id = state.uri.queryParameters['petId'];
          if (id == null || id.isEmpty) {
            return const Scaffold(body: Center(child: Text('Missing pet')));
          }
          return PetCareOnboardingScreen(petId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.likedPets,
        builder: (context, state) => const LikedPetsScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.petProfile}/:id',
        builder: (context, state) {
          final petId = safePathParam(state, 'id');
          if (petId == null) {
            return const InvalidRouteErrorScreen(missingParam: 'pet ID');
          }
          return VisitorPetProfileScreen(petId: petId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.userProfile}/:id',
        builder: (context, state) {
          final userId = safePathParam(state, 'id');
          if (userId == null) {
            return const InvalidRouteErrorScreen(missingParam: 'user ID');
          }
          return VisitorUserProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: AppRoutes.messages,
        builder: (context, state) => const MessagesListScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.chat}/:threadId',
        builder: (context, state) {
          final threadId = safePathParam(state, 'threadId');
          if (threadId == null) {
            return const InvalidRouteErrorScreen(missingParam: 'thread ID');
          }
          return ChatScreen(threadId: threadId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.post}/:id',
        builder: (context, state) {
          final postId = safePathParam(state, 'id');
          if (postId == null) {
            return const InvalidRouteErrorScreen(missingParam: 'post ID');
          }
          return PostDetailScreen(postId: postId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.story}/:petId',
        builder: (context, state) {
          final petId = safePathParam(state, 'petId');
          if (petId == null) {
            return const InvalidRouteErrorScreen(missingParam: 'pet ID');
          }
          return StoryViewerScreen(petId: petId);
        },
      ),
      GoRoute(
        path: AppRoutes.cart,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.orders,
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.product}/:id',
        builder: (context, state) {
          final productId = safePathParam(state, 'id');
          if (productId == null) {
            return const InvalidRouteErrorScreen(missingParam: 'product ID');
          }
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.petFollowers,
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
        path: AppRoutes.userFollowers,
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
        path: AppRoutes.userFollowing,
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
        path: AppRoutes.achievements,
        builder: (context, state) => const GamificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.vetBooking,
        builder: (context, state) => const VetBookingScreen(),
      ),
      GoRoute(
        path: AppRoutes.emergencyCare,
        builder: (context, state) => const EmergencyCareScreen(),
      ),
      GoRoute(
        path: AppRoutes.communityGroups,
        builder: (context, state) => const CommunityGroupsScreen(),
      ),
      GoRoute(
        path: AppRoutes.lostAndFound,
        builder: (context, state) => const LostAndFoundScreen(),
      ),
      GoRoute(
        path: AppRoutes.adoptionCenter,
        builder: (context, state) => const AdoptionCenterScreen(),
      ),
      GoRoute(
        path: AppRoutes.training,
        builder: (context, state) => const PetTrainingScreen(),
      ),
      GoRoute(
        path: AppRoutes.insurance,
        builder: (context, state) => const PetInsuranceHubScreen(),
      ),
      GoRoute(
        path: AppRoutes.expenses,
        builder: (context, state) => const PetExpenseTrackerScreen(),
      ),
      GoRoute(
        path: AppRoutes.growthCharts,
        builder: (context, state) => const PetGrowthChartScreen(),
      ),
      GoRoute(
        path: AppRoutes.memorial,
        builder: (context, state) => const PetMemorialScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = safePathParam(state, 'id');
              if (id == null) {
                return const InvalidRouteErrorScreen(
                  missingParam: 'memorial ID',
                );
              }
              return PetMemorialDetailScreen(memorialId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.petFriendlyPlaces,
        builder: (context, state) => const PetFriendlyPlacesScreen(),
      ),
      GoRoute(
        path: AppRoutes.events,
        builder: (context, state) => const PetEventDiscoveryScreen(),
      ),
      GoRoute(
        path: AppRoutes.medicalRecords,
        builder: (context, state) => const PetHealthRecordScreen(),
      ),
      GoRoute(
        path: AppRoutes.exportRecords,
        builder: (context, state) => const PetHealthRecordExportScreen(),
      ),
      GoRoute(
        path: AppRoutes.sitters,
        builder: (context, state) => const PetSitterDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.nutritionPlanner,
        builder: (context, state) => const PetNutritionPlannerScreen(),
      ),
      GoRoute(
        path: AppRoutes.petTimeline,
        builder: (context, state) => const PetSocialTimelineScreen(),
      ),
      GoRoute(
        path: AppRoutes.breedIdentifier,
        builder: (context, state) => const PetBreedIdentifierScreen(),
      ),
      GoRoute(
        path: AppRoutes.knowledgeBase,
        builder: (context, state) => const PetKnowledgeBaseScreen(),
      ),
      GoRoute(
        path: AppRoutes.articleDetail,
        builder: (context, state) {
          final article = state.extra as KnowledgeArticle?;
          if (article == null) {
            return const InvalidRouteErrorScreen(missingParam: 'article data');
          }
          return ArticleDetailScreen(article: article);
        },
      ),
      GoRoute(
        path: AppRoutes.gearReviews,
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
              Icon(
                Icons.error_outline,
                size: 56,
                color: Theme.of(context).colorScheme.error,
              ),
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
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.home),
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

