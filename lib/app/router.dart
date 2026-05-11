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
import 'package:petfolio/features/profile/presentation/screens/owner_profile_screen.dart';
import 'package:petfolio/features/profile/presentation/screens/manage_pets_screen.dart';
import 'package:petfolio/features/social/presentation/screens/create_post_screen.dart';
import 'package:petfolio/features/social/presentation/screens/create_story_screen.dart';
import 'package:petfolio/features/pet/presentation/screens/add_pet_screen.dart';
import 'package:petfolio/features/messaging/presentation/screens/messages_list_screen.dart';
import 'package:petfolio/features/messaging/presentation/screens/chat_screen.dart';
import 'package:petfolio/features/marketplace/presentation/screens/product_detail_screen.dart';
import 'package:petfolio/features/social/presentation/screens/post_detail_screen.dart';
import 'package:petfolio/features/marketplace/presentation/screens/cart_screen.dart';
import 'package:petfolio/features/marketplace/presentation/screens/order_history_screen.dart';
import 'package:petfolio/features/marketplace/presentation/screens/checkout_screen.dart';
import 'package:petfolio/features/marketplace/presentation/screens/order_detail_screen.dart';
import 'package:petfolio/features/social/presentation/screens/pet_followers_screen.dart';
import 'package:petfolio/features/pet/presentation/screens/visitor_pet_profile_screen.dart';
import 'package:petfolio/features/pet/presentation/screens/pet_profile_screen.dart';
import 'package:petfolio/features/social/presentation/screens/visitor_user_profile_screen.dart';
import 'package:petfolio/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:petfolio/features/pet/presentation/screens/liked_pets_screen.dart';
import 'package:petfolio/features/auth/presentation/screens/login_screen.dart';
import 'package:petfolio/features/auth/presentation/screens/registration_screen.dart';
import 'package:petfolio/features/settings/presentation/screens/settings_screen.dart';
import 'package:petfolio/features/settings/presentation/screens/edit_owner_profile_screen.dart';
import 'package:petfolio/features/settings/presentation/screens/password_settings_screen.dart';
import 'package:petfolio/features/settings/presentation/screens/notification_preferences_screen.dart';
import 'package:petfolio/features/settings/presentation/screens/privacy_settings_screen.dart';
import 'package:petfolio/features/settings/presentation/screens/blocked_users_screen.dart';
import 'package:petfolio/features/settings/presentation/screens/security_settings_screen.dart';
import 'package:petfolio/features/auth/presentation/screens/splash_screen.dart';
import 'package:petfolio/features/auth/presentation/screens/onboarding_screen.dart';
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
import 'package:petfolio/features/social/presentation/screens/create_memorial_tribute_screen.dart';
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
import 'package:petfolio/features/services/presentation/screens/lost_found_detail_screen.dart';
import 'package:petfolio/features/services/presentation/screens/adoption_detail_screen.dart';
import 'package:petfolio/features/services/presentation/screens/event_detail_screen.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';

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
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
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
                builder: (context, state) => const OwnerProfileScreen(),
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
        path: AppRoutes.petProfile,
        builder: (context, state) {
          final petId = state.pathParameters['id'];
          if (petId == null) {
            return const InvalidRouteErrorScreen(missingParam: 'pet ID');
          }
          return Consumer(
            builder: (context, ref, child) {
              final myPets = ref.watch(petProvider).myPets;
              final isMyPet = myPets.any((p) => p.id == petId);
              
              if (isMyPet) {
                return PetProfileScreen(petId: petId);
              }
              return VisitorPetProfileScreen(petId: petId);
            },
          );
        },
        routes: [
          GoRoute(
            path: 'care',
            builder: (context, state) => const PetCareScreen(),
          ),
          GoRoute(
            path: 'care/onboarding',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              if (id == null || id.isEmpty) {
                return const Scaffold(body: Center(child: Text('Missing pet')));
              }
              return PetCareOnboardingScreen(petId: id);
            },
          ),
          GoRoute(
            path: 'followers',
            builder: (context, state) {
              final petId = state.pathParameters['id'];
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
            path: 'achievements',
            builder: (context, state) => const GamificationScreen(),
          ),
          GoRoute(
            path: 'medical_records',
            builder: (context, state) => const PetHealthRecordScreen(),
          ),
          GoRoute(
            path: 'medical_records/export',
            builder: (context, state) => const PetHealthRecordExportScreen(),
          ),
          GoRoute(
            path: 'expenses',
            builder: (context, state) => const PetExpenseTrackerScreen(),
          ),
          GoRoute(
            path: 'growth',
            builder: (context, state) => const PetGrowthChartScreen(),
          ),
          GoRoute(
            path: 'nutrition',
            builder: (context, state) => const PetNutritionPlannerScreen(),
          ),
          GoRoute(
            path: 'timeline',
            builder: (context, state) => const PetSocialTimelineScreen(),
          ),
          GoRoute(
            path: 'training',
            builder: (context, state) => const PetTrainingScreen(),
          ),
          GoRoute(
            path: 'vet_booking',
            builder: (context, state) => const VetBookingScreen(),
          ),
          GoRoute(
            path: 'emergency_care',
            builder: (context, state) => const EmergencyCareScreen(),
          ),
          GoRoute(
            path: 'insurance',
            builder: (context, state) => const PetInsuranceHubScreen(),
          ),
          GoRoute(
            path: 'memorial',
            builder: (context, state) => const PetMemorialScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) {
                  final id = state.pathParameters['id'];
                  if (id == null) {
                    return const InvalidRouteErrorScreen(missingParam: 'pet ID');
                  }
                  return CreateMemorialTributeScreen(petId: id);
                },
              ),
              GoRoute(
                path: ':memorialId',
                builder: (context, state) {
                  final id = safePathParam(state, 'memorialId');
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
        ],
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
        path: AppRoutes.userProfile,
        builder: (context, state) {
          final userId = state.pathParameters['id'];
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
        path: AppRoutes.chat,
        builder: (context, state) {
          final threadId = state.pathParameters['threadId'];
          if (threadId == null) {
            return const InvalidRouteErrorScreen(missingParam: 'thread ID');
          }
          return ChatScreen(threadId: threadId);
        },
      ),
      GoRoute(
        path: AppRoutes.post,
        builder: (context, state) {
          final postId = state.pathParameters['id'];
          if (postId == null) {
            return const InvalidRouteErrorScreen(missingParam: 'post ID');
          }
          return PostDetailScreen(postId: postId);
        },
      ),
      GoRoute(
        path: AppRoutes.story,
        builder: (context, state) {
          final petId = state.pathParameters['petId'];
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
        path: AppRoutes.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderDetail,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId'];
          if (orderId == null) {
            return const InvalidRouteErrorScreen(missingParam: 'order ID');
          }
          return OrderDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: AppRoutes.product,
        builder: (context, state) {
          final productId = state.pathParameters['id'];
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
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditOwnerProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (context, state) => const PasswordSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationPreferences,
        builder: (context, state) => const NotificationPreferencesScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacySettings,
        builder: (context, state) => const PrivacySettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.blockedUsers,
        builder: (context, state) => const BlockedUsersScreen(),
      ),
      GoRoute(
        path: AppRoutes.securitySettings,
        builder: (context, state) => const SecuritySettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.userFollowers,
        builder: (context, state) {
          final userId = state.pathParameters['id'];
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
          final userId = state.pathParameters['id'];
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
        path: AppRoutes.communityGroups,
        builder: (context, state) => const CommunityGroupsScreen(),
      ),
      GoRoute(
        path: AppRoutes.lostAndFound,
        builder: (context, state) => const LostAndFoundScreen(),
      ),
      GoRoute(
        path: AppRoutes.lostFoundDetailById(':id'),
        builder: (context, state) => LostFoundDetailScreen(
          reportId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.adoptionCenter,
        builder: (context, state) => const AdoptionCenterScreen(),
      ),
      GoRoute(
        path: AppRoutes.adoptionDetailById(':id'),
        builder: (context, state) => AdoptionDetailScreen(
          listingId: state.pathParameters['id']!,
        ),
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
        path: AppRoutes.eventDetailById(':id'),
        builder: (context, state) => EventDetailScreen(
          eventId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.sitters,
        builder: (context, state) => const PetSitterDashboardScreen(),
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
      GoRoute(
        path: AppRoutes.managePets,
        builder: (context, state) => const ManagePetsScreen(),
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

