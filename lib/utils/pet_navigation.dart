import 'package:flutter/scheduler.dart';
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
    context.go('/home');
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref.read(mainLayoutTabRequestProvider.notifier).request(4);
    });
    return;
  }

  context.push('/user/$userId');
}
