import 'package:flutter/material.dart';
import 'package:petfolio/core/widgets/petfolio_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/pet_memorial_controller.dart';
import 'package:petfolio/features/social/data/models/pet_memorial_models.dart';

class PetMemorialScreen extends ConsumerWidget {
  const PetMemorialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memorialsAsync = ref.watch(memorialEntriesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Wall of Remembrance'),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&q=80&w=1000',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withAlpha(150),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          memorialsAsync.when(
            data: (memorials) => SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: memorials.isEmpty
                  ? const SliverFillRemaining(
                      child: PetfolioEmptyState(
                        icon: Icons.auto_awesome_rounded,
                        title: 'No Tributes Yet',
                        message:
                            'The Wall of Remembrance is currently peaceful. Create a tribute to honor a pet\'s memory.',
                      ),
                    )
                  : SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final entry = memorials[index];
                        return _MemorialGridCard(entry: entry);
                      }, childCount: memorials.length),
                    ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) =>
                SliverFillRemaining(child: Center(child: Text('Error: $err'))),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Create a Tribute'),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _MemorialGridCard extends StatelessWidget {
  const _MemorialGridCard({required this.entry});
  final PetMemorialEntry entry;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/memorial/${entry.id}'),
      borderRadius: BorderRadius.circular(24),
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              entry.petImageUrl ??
                  'https://images.unsplash.com/photo-1518717758536-85ae29035b6d',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withAlpha(200), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.6],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.petName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.birthYear} — ${entry.passingYear}',
                    style: TextStyle(
                      color: Colors.white.withAlpha(180),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
