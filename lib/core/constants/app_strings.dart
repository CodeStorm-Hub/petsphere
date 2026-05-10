/// Application-wide string constants
/// Extracted from controllers to enable internationalization and reduce duplication
library;

class AppStrings {
  // Auth errors
  static const String authLoginFailed = 'Login failed. Please try again.';
  static const String authRegistrationFailed = 'Registration failed.';
  static const String authSessionCheckFailed = 'Session check failed.';
  static const String authSessionTimeout =
      'Session check timed out (profile fetch); using auth session only.';
  static const String authProfileFetchFailed =
      'Auth listener: profile fetch failed.';
  static const String authLogoutSuccess = 'Logged out successfully.';

  // Pet errors
  static const String petLoadFailed = 'Failed to load pets.';
  static const String petCreateFailed = 'Failed to create pet.';
  static const String petUpdateFailed = 'Failed to update pet.';
  static const String petDeleteFailed = 'Failed to delete pet.';
  static const String petImageUploadFailed = 'Failed to upload pet image.';

  // Profile errors
  static const String profileUpdateFailed = 'Failed to update profile.';
  static const String profileFetchFailed = 'Failed to fetch profile.';

  // Generic errors
  static const String unknownError = 'An unexpected error occurred.';
  static const String networkError = 'Network error. Please check your connection.';
  static const String timeoutError = 'Request timed out. Please try again.';

  // Success messages
  static const String savedSuccessfully = 'Saved successfully.';
  static const String deletedSuccessfully = 'Deleted successfully.';
  static const String loadedSuccessfully = 'Loaded successfully.';

  // Loading states
  static const String loading = 'Loading...';
  static const String saving = 'Saving...';
  static const String deleting = 'Deleting...';

  // Validation messages
  static const String fieldRequired = 'This field is required.';
  static const String invalidEmail = 'Please enter a valid email address.';
  static const String passwordTooShort = 'Password must be at least 8 characters.';

  // Dialog messages
  static const String confirmDelete = 'Are you sure you want to delete this?';
  static const String confirmLogout = 'Are you sure you want to log out?';

  // Bootstrap messages
  static const String bootstrapSkipHydrate = 'Skip hydrate (already hydrated)';
  static const String bootstrapHydratingData = 'Hydrating data for user';

  // Pet care messages
  static const String careLoadFailed = 'Failed to load care data.';
  static const String careLogSymptomFailed = 'Failed to log symptom.';
  static const String careResolveSymptomFailed = 'Failed to resolve symptom.';
  static const String careLogWeightFailed = 'Failed to log weight.';

  // Health messages
  static const String healthLoadFailed = 'Failed to load health data.';
  static const String healthMedicationAddFailed = 'Failed to add medication.';
  static const String healthMedicationUpdateFailed = 'Failed to update medication.';
  static const String healthMedicationDeleteFailed = 'Failed to delete medication.';
  static const String healthDoseActionFailed = 'Failed to update medication dose.';
  static const String healthAllergyAddFailed = 'Failed to add allergy.';
  static const String healthAllergyDeleteFailed = 'Failed to delete allergy.';
  static const String healthParasiteLogFailed = 'Failed to log parasite treatment.';
  static const String healthParasiteDeleteFailed = 'Failed to delete parasite entry.';
  static const String healthDentalLogFailed = 'Failed to log dental cleaning.';
  static const String healthAppointmentFailed = 'Failed to manage appointment.';
  static const String healthAppointmentCancelFailed = 'Failed to cancel appointment.';
  static const String healthVaccinationFailed = 'Failed to add vaccination.';
  static const String healthVaccinationMarkCompleteFailed =
      'Failed to mark vaccination complete.';
  static const String healthDoseMarkGivenFailed = 'Failed to mark dose as given.';
  static const String healthDoseSkipFailed = 'Failed to skip dose.';

  // Marketplace errors
  static const String marketplaceLoadFailed = 'Failed to load products.';
  static const String marketplaceSearchFailed = 'Search failed.';
  static const String cartAddItemFailed = 'Failed to add item to cart.';
  static const String cartRemoveItemFailed = 'Failed to remove item from cart.';
  static const String cartCheckoutFailed = 'Checkout failed.';
  static const String orderCreationFailed = 'Failed to create order.';

  // Social/Feed errors
  static const String feedLoadFailed = 'Failed to load feed.';
  static const String postCreateFailed = 'Failed to create post.';
  static const String postDeleteFailed = 'Failed to delete post.';
  static const String postLikeFailed = 'Failed to like post.';
  static const String commentCreateFailed = 'Failed to add comment.';
  static const String commentDeleteFailed = 'Failed to delete comment.';
  static const String storyCreateFailed = 'Failed to create story.';
  static const String storyDeleteFailed = 'Failed to delete story.';

  // Messaging errors
  static const String chatLoadFailed = 'Failed to load messages.';
  static const String messageSendFailed = 'Failed to send message.';
  static const String threadLoadFailed = 'Failed to load thread.';
  static const String chatThreadCreationFailed = 'Failed to start chat.';
  static const String chatHeaderLoadFailed = 'Failed to load conversation.';

  // Matching errors
  static const String matchLoadFailed = 'Failed to load matches.';
  static const String matchRequestSendFailed = 'Failed to send match request.';
  static const String matchRequestAcceptFailed = 'Failed to accept request.';
  static const String matchRequestRejectFailed = 'Failed to reject request.';
  static const String matchOwnPetError = 'You cannot like your own pet.';
  static const String matchDuplicateRequestError = 'You have already sent a request for this pet.';

  // Notification errors
  static const String notificationLoadFailed = 'Failed to load notifications.';
  static const String notificationMarkReadFailed = 'Failed to mark as read.';

  // Generic operation errors
  static const String operationFailed = 'Operation failed. Please try again.';
}
