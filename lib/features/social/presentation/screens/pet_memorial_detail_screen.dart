import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/pet_memorial_controller.dart';
import 'package:petfolio/features/social/data/models/pet_memorial_models.dart';

class PetMemorialDetailScreen extends ConsumerWidget {
  const PetMemorialDetailScreen({super.key, required this.memorialId});
  final String memorialId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(memorialEntryProvider(memorialId));

    return entryAsync.when(
      data: (entry) {
        if (entry == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Memorial not found')),
          );
        }
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              entry.petName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share_rounded),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              _MemorialBackground(imageUrl: entry.petImageUrl),
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 120, 24, 40),
                      child: Column(
                        children: [
                          _MemorialProfile(entry: entry),
                          const SizedBox(height: 40),
                          _MemorialQuote(quote: entry.message),
                          const SizedBox(height: 48),
                          _MemorialMessageBoard(),
                          const SizedBox(height: 60),
                          FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.favorite_rounded),
                            label: const Text('Light a Candle'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white.withAlpha(50),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(200, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                                side: const BorderSide(color: Colors.white30),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}

class _MemorialBackground extends StatelessWidget {
  const _MemorialBackground({this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.network(
                imageUrl ??
                    'https://images.unsplash.com/photo-1470770841072-f978cf4d019e',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withAlpha(100),
                  Colors.transparent,
                  Colors.black.withAlpha(100),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemorialProfile extends StatelessWidget {
  const _MemorialProfile({required this.entry});
  final PetMemorialEntry entry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Hero(
          tag: 'memorial_${entry.id}',
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(80), width: 2),
            ),
            child: CircleAvatar(
              radius: 90,
              backgroundImage: NetworkImage(
                entry.petImageUrl ??
                    'https://images.unsplash.com/photo-1518717758536-85ae29035b6d',
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          entry.petName,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(40),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white30),
          ),
          child: Text(
            '${entry.birthYear} — ${entry.passingYear}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 4,
            ),
          ),
        ),
      ],
    );
  }
}

class _MemorialQuote extends StatelessWidget {
  const _MemorialQuote({this.quote});
  final String? quote;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.format_quote_rounded,
            color: Colors.white70,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            quote ??
                'Until we meet again at the Rainbow Bridge. You left paw prints on our hearts forever.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Rest in Peace, Sweet Friend',
            style: TextStyle(
              color: Colors.white.withAlpha(150),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MemorialMessageBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Messages of Love',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 20),
        _MessageBubble(
          name: 'Community',
          message: 'Thinking of you during this difficult time. Sending love.',
          date: 'Just now',
        ),
        _MessageBubble(
          name: 'Friend',
          message: 'A beautiful tribute for a beautiful soul.',
          date: '2h ago',
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.name,
    required this.message,
    required this.date,
  });
  final String name;
  final String message;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Text(
                date,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.white, height: 1.5),
          ),
        ],
      ),
    );
  }
}
