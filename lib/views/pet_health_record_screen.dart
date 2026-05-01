import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/pet_controller.dart';

class PetHealthRecordScreen extends ConsumerStatefulWidget {
  const PetHealthRecordScreen({super.key});

  @override
  ConsumerState<PetHealthRecordScreen> createState() => _PetHealthRecordScreenState();
}

class _PetHealthRecordScreenState extends ConsumerState<PetHealthRecordScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            title: const Text('Health Records', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.share_rounded)),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HealthStatusHeader(petName: pet.activePet?.name ?? 'Pet', status: 'Excellent', lastCheckup: 'Oct 12, 2023'),
                  const SizedBox(height: 32),
                  Text('Vitals Summary', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _VitalsGrid(),
                  const SizedBox(height: 32),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                    tabs: const [
                      Tab(text: 'History'),
                      Tab(text: 'Vaccines'),
                      Tab(text: 'Meds'),
                      Tab(text: 'Labs'),
                    ],
                    onTap: (index) => setState(() {}),
                  ),
                  const SizedBox(height: 24),
                  _buildTabContent(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text('Scan Document'),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_tabController.index) {
      case 0: return _MedicalTimeline();
      case 1: return _VaccineList();
      default: return const _EmptyState(text: 'No specific records in this category yet.');
    }
  }
}

class _HealthStatusHeader extends StatelessWidget {
  final String petName;
  final String status;
  final String lastCheckup;

  const _HealthStatusHeader({required this.petName, required this.status, required this.lastCheckup});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primaryContainer, colorScheme.primaryContainer.withAlpha(150)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colorScheme.primaryContainer),
        boxShadow: [BoxShadow(color: colorScheme.primary.withAlpha(20), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: colorScheme.primary.withAlpha(100), blurRadius: 10)],
            ),
            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$petName is $status', style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 4),
                Text('Last professional checkup: $lastCheckup', style: TextStyle(color: colorScheme.onPrimaryContainer.withAlpha(180), fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: const [
        _VitalCard(label: 'Weight', value: '12.4 kg', icon: Icons.monitor_weight_outlined, trend: '-0.2', color: Colors.blue),
        _VitalCard(label: 'Heart Rate', value: '82 bpm', icon: Icons.favorite_outline_rounded, trend: 'Normal', color: Colors.red),
        _VitalCard(label: 'Temperature', value: '38.5 °C', icon: Icons.thermostat_rounded, trend: 'Stable', color: Colors.orange),
        _VitalCard(label: 'Activity', value: '8.4k steps', icon: Icons.directions_run_rounded, trend: '+12%', color: Colors.green),
      ],
    );
  }
}

class _VitalCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String trend;
  final Color color;

  const _VitalCard({required this.label, required this.value, required this.icon, required this.trend, required this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(6)),
                child: Text(trend, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _MedicalTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _TimelineItem(date: 'Oct 12, 2023', title: 'Annual Checkup', doctor: 'Dr. Sarah Jenkins', type: 'Clinical Visit'),
        _TimelineItem(date: 'Aug 24, 2023', title: 'Dental Cleaning', doctor: 'Dr. Mike Ross', type: 'Surgery'),
        _TimelineItem(date: 'Jun 15, 2023', title: 'Ear Infection Treatment', doctor: 'Dr. Sarah Jenkins', type: 'Acute Care'),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String date;
  final String title;
  final String doctor;
  final String type;

  const _TimelineItem({required this.date, required this.title, required this.doctor, required this.type});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12, 
                height: 12, 
                decoration: BoxDecoration(
                  color: colorScheme.primary, 
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 2),
                  boxShadow: [BoxShadow(color: colorScheme.primary.withAlpha(100), blurRadius: 4)],
                ),
              ),
              Expanded(child: Container(width: 2, color: colorScheme.outlineVariant)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(date, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 12)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(8)),
                        child: Text(type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.onSecondaryContainer)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Attended by $doctor', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VaccineList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _VaccineCard(name: 'Rabies', date: 'Sept 20, 2023', nextDue: 'Sept 20, 2024', status: 'Up to date'),
        SizedBox(height: 12),
        _VaccineCard(name: 'Distemper', date: 'Jan 15, 2023', nextDue: 'Jan 15, 2024', status: 'Due Soon'),
      ],
    );
  }
}

class _VaccineCard extends StatelessWidget {
  final String name;
  final String date;
  final String nextDue;
  final String status;

  const _VaccineCard({required this.name, required this.date, required this.nextDue, required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDueSoon = status == 'Due Soon';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDueSoon ? Colors.orange.withAlpha(30) : Colors.green.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(isDueSoon ? Icons.priority_high_rounded : Icons.verified_user_rounded, color: isDueSoon ? Colors.orange : Colors.green),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Administered on $date', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Next Due', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
              Text(nextDue, style: TextStyle(color: isDueSoon ? Colors.orange : colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.folder_open_rounded, size: 64, color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
