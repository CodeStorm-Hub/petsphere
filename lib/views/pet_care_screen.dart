import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../controllers/pet_controller.dart';

class PetCareScreen extends ConsumerStatefulWidget {
  const PetCareScreen({super.key});

  @override
  ConsumerState<PetCareScreen> createState() => _PetCareScreenState();
}

class _PetCareScreenState extends ConsumerState<PetCareScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Care'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryAccent,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryAccent,
          tabs: const [
            Tab(text: 'Care Diary'),
            Tab(text: 'Health'),
            Tab(text: 'Feeding'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _DashboardTab(),
          _HealthLogTab(),
          _FeedingTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. DASHBOARD (CARE DIARY)
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardTab extends ConsumerStatefulWidget {
  const _DashboardTab();

  @override
  ConsumerState<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<_DashboardTab> {
  final Map<int, bool> _tasksCompleted = {
    0: false,
    1: true,
    2: false,
  };
  String _selectedMood = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myPets = ref.watch(petProvider).myPets;
    final activePet = ref.watch(activePetProvider);
    final completedCount = _tasksCompleted.values.where((v) => v).length;
    final totalTasks = _tasksCompleted.length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet Selector (List of owned pets)
          if (myPets.isNotEmpty) ...[
            SizedBox(
              height: 72,
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: myPets.map((pet) {
                      final isSelected = pet.id == activePet?.id;
                      return GestureDetector(
                        onTap: () {
                          ref.read(petProvider.notifier).setActivePet(pet);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryAccent : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: AppTheme.surface,
                            backgroundImage: pet.profileImageUrl.isNotEmpty
                                ? NetworkImage(pet.profileImageUrl)
                                : null,
                            child: pet.profileImageUrl.isEmpty
                                ? const Icon(Icons.pets, color: AppTheme.textSecondary)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Animated Rings (Tasks / Calories / Water)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProgressRing('Tasks', completedCount / totalTasks, AppTheme.primaryAccent, '$completedCount/$totalTasks'),
              _buildProgressRing('Calories', 0.65, Colors.orange, '450\nkcal'),
              _buildProgressRing('Water', 0.4, Colors.blue, '2/5\ncups'),
            ],
          ),
          const SizedBox(height: 24),
          
          // 5-day streak banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text('5-Day Streak!', style: theme.textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    final isComplete = index < 4;
                    return Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isComplete ? AppTheme.primaryAccent.withValues(alpha: 0.2) : AppTheme.surface,
                        border: Border.all(color: isComplete ? AppTheme.primaryAccent : AppTheme.border),
                      ),
                      alignment: Alignment.center,
                      child: isComplete
                          ? const Icon(Icons.check, size: 16, color: AppTheme.primaryAccent)
                          : Text('D${index+1}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Daily Checklist
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Daily Checklist', style: theme.textTheme.titleLarge),
              Text('${(completedCount / totalTasks * 100).toInt()}%', style: TextStyle(color: AppTheme.primaryAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completedCount / totalTasks,
            backgroundColor: AppTheme.border,
            color: AppTheme.primaryAccent,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 16),
          
          _buildTaskCard(0, 'Morning Walk', '30 minutes', Icons.pets),
          _buildTaskCard(1, 'Give Medication', 'Heartworm pill', Icons.medical_services),
          _buildTaskCard(2, 'Brush Coat', 'Keep it shiny', Icons.brush),
          
          const SizedBox(height: 24),
          // Mood Selector
          Text('How is your pet feeling?', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMoodBtn('😴', 'Sleepy'),
              _buildMoodBtn('😊', 'Happy'),
              _buildMoodBtn('🤪', 'Playful'),
              _buildMoodBtn('🤒', 'Sick'),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildProgressRing(String label, double progress, Color color, String centerText) {
    return Column(
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: AppTheme.border,
                color: color,
              ),
              Center(
                child: Text(
                  centerText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      ],
    );
  }

  Widget _buildTaskCard(int index, String title, String subtitle, IconData icon) {
    final isDone = _tasksCompleted[index]!;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tasksCompleted[index] = !isDone;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDone ? AppTheme.secondaryAccent.withValues(alpha: 0.1) : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDone ? AppTheme.secondaryAccent : AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDone ? AppTheme.secondaryAccent : AppTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: isDone ? AppTheme.secondaryAccent : AppTheme.border),
              ),
              child: Icon(icon, color: isDone ? Colors.white : AppTheme.textSecondary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? AppTheme.textSecondary : AppTheme.textPrimary,
                    ),
                  ),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone ? AppTheme.secondaryAccent : AppTheme.border,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodBtn(String emoji, String label) {
    final isSelected = _selectedMood == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryAccent.withValues(alpha: 0.2) : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppTheme.primaryAccent : AppTheme.border),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryAccent : AppTheme.textSecondary,
            )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. HEALTH LOG
// ─────────────────────────────────────────────────────────────────────────────
class _HealthLogTab extends StatelessWidget {
  const _HealthLogTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live weight chart (mockup)
          Text('Weight Tracking', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Current Weight', style: TextStyle(color: AppTheme.textSecondary)),
                    Row(
                      children: const [
                        Icon(Icons.arrow_drop_up, color: Colors.red),
                        Text('0.2 lbs vs yes.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('42.5 lbs', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
                // Mock bar chart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBar(0.4, 'M'),
                    _buildBar(0.5, 'T'),
                    _buildBar(0.45, 'W'),
                    _buildBar(0.6, 'T'),
                    _buildBar(0.55, 'F'),
                    _buildBar(0.7, 'S'),
                    _buildBar(0.8, 'S', isToday: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Log weight prompt
          GestureDetector(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.monitor_weight, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text('Log weight for today', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const Icon(Icons.chevron_right, color: AppTheme.primaryAccent),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          Text('Upcoming Vet Appointments', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: const Border(
                top: BorderSide(color: AppTheme.border),
                right: BorderSide(color: AppTheme.border),
                bottom: BorderSide(color: AppTheme.border),
                left: BorderSide(color: AppTheme.secondaryAccent, width: 4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text('OCT', style: TextStyle(color: AppTheme.secondaryAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('24', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Annual Checkup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Dr. Smith • 10:00 AM', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          Text('Vaccination Timeline', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          _buildVaxItem('Rabies', 'Completed - Oct 2025', true),
          _buildVaxItem('Bordetella', 'Scheduled - Nov 2026', false),
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor, String label, {bool isToday = false}) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 100 * heightFactor,
          decoration: BoxDecoration(
            color: isToday ? AppTheme.primaryAccent : AppTheme.border,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: AppTheme.textSecondary, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
  
  Widget _buildVaxItem(String name, String dateStr, bool isComplete) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isComplete ? AppTheme.secondaryAccent : Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(dateStr, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isComplete ? AppTheme.secondaryAccent.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              isComplete ? 'Completed' : 'Scheduled',
              style: TextStyle(
                color: isComplete ? AppTheme.secondaryAccent : Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. FEEDING LOG
// ─────────────────────────────────────────────────────────────────────────────
class _FeedingTab extends StatefulWidget {
  const _FeedingTab();

  @override
  State<_FeedingTab> createState() => _FeedingTabState();
}

class _FeedingTabState extends State<_FeedingTab> {
  bool _breakfastFed = true;
  bool _dinnerFed = false;
  int _waterCups = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCals = (_breakfastFed ? 250 : 0) + (_dinnerFed ? 250 : 0);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calorie Ring
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: totalCals / 500,
                    strokeWidth: 12,
                    backgroundColor: AppTheme.border,
                    color: Colors.orange,
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$totalCals', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                        const Text('/ 500 kcal', style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          Text('Meals', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          _buildMealCard('Breakfast', '8:00 AM', 250, 'Dry Kibble - 1 cup', _breakfastFed, (val) => setState(() => _breakfastFed = val)),
          _buildMealCard('Dinner', '6:00 PM', 250, 'Wet Food - 1/2 can', _dinnerFed, (val) => setState(() => _dinnerFed = val)),
          
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Water Intake', style: theme.textTheme.titleLarge),
              Text('$_waterCups / 8 cups', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(8, (index) {
              final isFilled = index < _waterCups;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isFilled && index == _waterCups - 1) {
                      _waterCups--; // untap last
                    } else {
                      _waterCups = index + 1; // tap up to
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isFilled ? Colors.blue.withValues(alpha: 0.2) : AppTheme.cardColor,
                    border: Border.all(color: isFilled ? Colors.blue : AppTheme.border, width: 2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.water_drop,
                    color: isFilled ? Colors.blue : AppTheme.border,
                    size: 28,
                  ),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildMealCard(String mealName, String time, int cals, String foodDesc, bool isFed, ValueChanged<bool> onChanged) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isFed ? AppTheme.primaryAccent : AppTheme.border),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(mealName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$time • $cals kcal'),
            trailing: Switch(
              value: isFed,
              onChanged: onChanged,
              activeThumbColor: AppTheme.primaryAccent,
            ),
          ),
          if (isFed) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.restaurant, color: AppTheme.textSecondary, size: 20),
                  const SizedBox(width: 12),
                  Text(foodDesc, style: const TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}
