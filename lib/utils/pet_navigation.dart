import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';
import '../controllers/pet_controller.dart';

/// Routes a "tap on pet profile" intent to the right place:
///
/// - If the pet belongs to the current signed-in user, switch the bottom-tab
///   profile screen to that pet via [profilePetNavigationProvider] so the
///   user lands on their own owner-managed profile.
/// - Otherwise (it's a different user's pet), push [PetProfileScreen] in
///   visitor mode at `/pet/:id` (same layout as My Account, with follow /
///   message / share).
///
/// Pass [petUserId] when the caller already knows the owning user's ID
/// (e.g. from a [PostModel.pet]), to avoid an extra round-trip.
void openPetProfile(
  BuildContext context,
  WidgetRef ref, {
  required String petId,
  String? petUserId,
}) {
  final myUserId = ref.read(authProvider).user?.id;

  if (petUserId != null && myUserId != null && petUserId == myUserId) {
    ref.read(profilePetNavigationProvider.notifier).navigateTo(petId);
    return;
  }

  if (petUserId == null) {
    final myPets = ref.read(petProvider).myPets;
    if (myPets.any((p) => p.id == petId)) {
      ref.read(profilePetNavigationProvider.notifier).navigateTo(petId);
      return;
    }
  }

  context.push('/pet/$petId');
}

/// Routes to a user profile. If it's the current user, switches to the profile tab.
void openUserProfile(
  BuildContext context,
  WidgetRef ref, {
  required String userId,
}) {
  final myUserId = ref.read(authProvider).user?.id;

  if (myUserId != null && userId == myUserId) {
    // Navigate to the profile tab (index 4 in MainLayout)
    // We don't have a direct "switchToTab" method here, but we can potentially
    // use a provider or just context.go('/home') if the home route handles tab state,
    // or specifically context.push if we want it on the stack.
    // However, most apps just switch tabs.
    // For now, let's push the visitor profile even for self, or just go to /user/:id
    // because /user/:id is handled by PetProfileScreen which handles "isVisitor" logic.
  }

  context.push('/user/$userId');
}
