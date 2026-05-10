import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';

class EmergencyCareScreen extends ConsumerStatefulWidget {
  const EmergencyCareScreen({super.key});

  @override
  ConsumerState<EmergencyCareScreen> createState() =>
      _EmergencyCareScreenState();
}

class _EmergencyCareScreenState extends ConsumerState<EmergencyCareScreen> {
  final List<String> _emergencyNumbers = ['855-764-7661', '888-426-4435'];

  Future<void> _callNumber(String number) async {
    final url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pet = ref.watch(petProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            title: const Text(
              'Emergency Care',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: colorScheme.errorContainer.withAlpha(50),
            foregroundColor: colorScheme.error,
            actions: [
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.share_location_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.error.withAlpha(40),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EmergencyHero(),
                  const SizedBox(height: 24),
                  _MedicalIdCard(petName: pet.activePet?.name ?? 'Pet'),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Immediate Actions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.search_rounded, size: 18),
                        label: const Text('Symptoms Checker'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ActionGrid(),
                  const SizedBox(height: 32),
                  Text(
                    '24/7 Hotlines',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _EmergencyContactCard(
                    title: 'Pet Poison Helpline',
                    phone: _emergencyNumbers[0],
                    description: '24/7 Poisoning Emergency Center',
                    icon: Icons.warning_amber_rounded,
                  ),
                  const SizedBox(height: 12),
                  _EmergencyContactCard(
                    title: 'ASPCA Poison Control',
                    phone: _emergencyNumbers[1],
                    description: 'Specialized Animal Toxicology',
                    icon: Icons.medical_services_rounded,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Toxic Food Items',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ToxicItemsList(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () => _callNumber(_emergencyNumbers.first),
        backgroundColor: colorScheme.error,
        foregroundColor: colorScheme.onError,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sos_rounded, size: 40),
            Text(
              'SOS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.error, colorScheme.error.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colorScheme.error.withAlpha(60),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nearby Emergency Vet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find open hospitals near you instantly.',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: colorScheme.error,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Open Maps',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.map_rounded, color: Colors.white, size: 48),
          ),
        ],
      ),
    );
  }
}

class _MedicalIdCard extends StatelessWidget {
  const _MedicalIdCard({required this.petName});
  final String petName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              size: 48,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$petName\'s Digital ID',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Instant medical access for vets.',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: () {},
            icon: const Icon(Icons.visibility_rounded),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyContactCard extends StatelessWidget {

  const _EmergencyContactCard({
    required this.title,
    required this.phone,
    required this.description,
    required this.icon,
  });
  final String title;
  final String phone;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => launchUrl(Uri.parse('tel:$phone')),
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: colorScheme.error.withAlpha(40)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withAlpha(100),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: colorScheme.error, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      phone,
                      style: TextStyle(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.call_rounded, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final actions = [
      {
        'title': 'CPR & Choking',
        'icon': Icons.heart_broken_rounded,
        'color': colorScheme.error,
      },
      {
        'title': 'Bleeding',
        'icon': Icons.bloodtype_rounded,
        'color': colorScheme.error,
      },
      {
        'title': 'Heatstroke',
        'icon': Icons.wb_sunny_rounded,
        'color': colorScheme.secondary,
      },
      {
        'title': 'Fractures',
        'icon': Icons.settings_accessibility_rounded,
        'color': colorScheme.tertiary,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        final color = action['color'] as Color;
        return Material(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: color.withAlpha(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(action['icon'] as IconData, color: color, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    action['title'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ToxicItemsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      'Chocolate',
      'Grapes',
      'Onions',
      'Xylitol',
      'Lilies',
      'Antifreeze',
      'Macadamia',
      'Avocado',
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withAlpha(150),
            ),
          ),
          child: Text(
            item,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        );
      }).toList(),
    );
  }
}
