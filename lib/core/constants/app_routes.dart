class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String discover = '/discover';
  static const String shop = '/shop';
  static const String profile = '/profile';
  static const String createPost = '/create_post';
  static const String createStory = '/create_story';
  static const String addPet = '/add_pet';
  static const String notifications = '/notifications';
  static const String likedPets = '/liked_pets';
  
  // Pet-centric routes under /pet/:id
  static const String petProfile = '/pet/:id';
  static const String petCare = '/pet/:id/care';
  static const String petCareOnboarding = '/pet/:id/care/onboarding';
  static const String petFollowers = '/pet/:id/followers';
  static const String achievements = '/pet/:id/achievements';
  static const String medicalRecords = '/pet/:id/medical_records';
  static const String exportRecords = '/pet/:id/medical_records/export';
  static const String expenses = '/pet/:id/expenses';
  static const String growthCharts = '/pet/:id/growth';
  static const String nutritionPlanner = '/pet/:id/nutrition';
  static const String petTimeline = '/pet/:id/timeline';
  static const String training = '/pet/:id/training';
  static const String memorial = '/pet/:id/memorial';
  static const String createMemorial = '/pet/:id/memorial/create';
  static const String vetBooking = '/pet/:id/vet_booking';
  static const String emergencyCare = '/pet/:id/emergency_care';
  static const String insurance = '/pet/:id/insurance';
  
  // Other features
  static const String userProfile = '/user/:id';
  static const String userFollowers = '/user/:id/followers';
  static const String userFollowing = '/user/:id/following';
  
  static const String messages = '/messages';
  static const String chat = '/chat/:threadId';
  static const String post = '/post/:id';
  static const String story = '/story/:petId';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:orderId';
  static const String product = '/product/:id';
  static const String settings = '/settings';
  static const String editProfile = '/settings/edit_profile';
  static const String changePassword = '/change_password';
  static const String notificationPreferences = '/notification_preferences';
  static const String privacySettings = '/privacy_settings';
  static const String blockedUsers = '/blocked_users';
  static const String securitySettings = '/security';
  static const String search = '/search';
  
  static const String communityGroups = '/community_groups';
  static const String lostAndFound = '/lost_and_found';
  static const String lostFoundDetail = '/lost_and_found/:reportId';
  static const String adoptionCenter = '/adoption_center';
  static const String adoptionDetail = '/adoption/:listingId';
  static const String petFriendlyPlaces = '/pet_friendly_places';
  static const String events = '/events';
  static const String eventDetail = '/events/:eventId';
  static const String sitters = '/sitters';
  static const String breedIdentifier = '/breed_identifier';
  static const String knowledgeBase = '/knowledge_base';
  static const String articleDetail = '/article_detail';
  static const String gearReviews = '/gear_reviews';
  static const String managePets = '/manage_pets';

  // Navigation Helpers
  static String petProfileById(String id) => '/pet/$id';
  static String petCareById(String id) => '/pet/$id/care';
  static String petCareOnboardingById(String id) => '/pet/$id/care/onboarding';
  static String petFollowersById(String id) => '/pet/$id/followers';
  static String petAchievementsById(String id) => '/pet/$id/achievements';
  static String petMedicalRecordsById(String id) => '/pet/$id/medical_records';
  static String petExpensesById(String id) => '/pet/$id/expenses';
  static String petTimelineById(String id) => '/pet/$id/timeline';
  static String petGrowthById(String id) => '/pet/$id/growth';
  static String petNutritionById(String id) => '/pet/$id/nutrition';
  static String petTrainingById(String id) => '/pet/$id/training';
  static String petMemorialById(String id) => '/pet/$id/memorial';
  static String createPetMemorialById(String id) => '/pet/$id/memorial/create';
  static String petVetBookingById(String id) => '/pet/$id/vet_booking';
  static String petEmergencyById(String id) => '/pet/$id/emergency_care';
  static String petInsuranceById(String id) => '/pet/$id/insurance';
  
  static String userProfileById(String id) => '/user/$id';
  static String userFollowersById(String id) => '/user/$id/followers';
  static String userFollowingById(String id) => '/user/$id/following';
  
  static String chatByThreadId(String threadId) => '/chat/$threadId';
  static String orderDetailById(String orderId) => '/orders/$orderId';
  static String postById(String id) => '/post/$id';
  static String productById(String id) => '/product/$id';
  static String storyByPetId(String petId) => '/story/$petId';
  static String createStoryByPetId(String petId) => '/create_story?petId=$petId';
  static String lostFoundDetailById(String reportId) => '/lost_and_found/$reportId';
  static String adoptionDetailById(String listingId) => '/adoption/$listingId';
  static String eventDetailById(String eventId) => '/events/$eventId';
}
