import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_dating_app/controllers/match_controller.dart';
import 'package:pet_dating_app/views/components/pet_avatar.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchState = ref.watch(matchProvider);
    final myRequests = matchState.myRequests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(matchProvider.notifier).refresh(),
        child: myRequests.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No new requests.')),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: myRequests.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                final req = myRequests[index];
                
                // Usually would load sender pet dynamically from a stream/future
                final senderPet = req.senderPet; 
                
                if (senderPet == null) return const SizedBox.shrink();

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: PetAvatar(imageUrl: senderPet.profileImageUrl, radius: 24),
                  title: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: senderPet.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' liked your pet for breeding.'),
                      ],
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: req.status == 'pending'
                        ? Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  ref.read(matchProvider.notifier).acceptRequest(req.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('You matched with ${senderPet.name}!')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  minimumSize: const Size(0, 36),
                                ),
                                child: const Text('Like Back'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () {
                                  ref.read(matchProvider.notifier).declineRequest(req.id);
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  minimumSize: const Size(0, 36),
                                ),
                                child: const Text('Decline'),
                              ),
                            ],
                          )
                        : Text(
                            req.status == 'matched' ? 'You matched!' : 'Declined',
                            style: TextStyle(
                              color: req.status == 'matched' ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                );
              },
            ),
      ),
    );
  }
}
