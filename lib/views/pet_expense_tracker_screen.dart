import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/pet_controller.dart';

class PetExpenseTrackerScreen extends ConsumerStatefulWidget {
  const PetExpenseTrackerScreen({super.key});

  @override
  ConsumerState<PetExpenseTrackerScreen> createState() => _PetExpenseTrackerScreenState();
}

class _PetExpenseTrackerScreenState extends ConsumerState<PetExpenseTrackerScreen> {
  String _selectedPeriod = 'This Month';
  
  final List<Map<String, dynamic>> _expenses = [
    {'title': 'Premium Kibble', 'category': 'Food', 'amount': 85.00, 'date': DateTime.now().subtract(const Duration(days: 2)), 'icon': Icons.restaurant_rounded, 'color': Colors.orange},
    {'title': 'Annual Vaccination', 'category': 'Health', 'amount': 120.50, 'date': DateTime.now().subtract(const Duration(days: 5)), 'icon': Icons.medical_services_rounded, 'color': Colors.redAccent},
    {'title': 'Squeaky Toy', 'category': 'Toys', 'amount': 15.20, 'date': DateTime.now().subtract(const Duration(days: 7)), 'icon': Icons.toys_rounded, 'color': Colors.purpleAccent},
    {'title': 'Grooming Session', 'category': 'Grooming', 'amount': 65.00, 'date': DateTime.now().subtract(const Duration(days: 10)), 'icon': Icons.content_cut_rounded, 'color': Colors.blueAccent},
  ];

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petProvider);
    final totalSpent = _expenses.fold<double>(0.0, (sum, e) => sum + (e['amount'] as double));

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            title: const Text('Expense Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.file_download_rounded)),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BudgetDashboard(totalSpent: totalSpent, budget: 800.00, petName: pet.activePet?.name ?? 'Pet'),
                  const SizedBox(height: 32),
                  _CategoryBreakdown(expenses: _expenses),
                  const SizedBox(height: 32),
                  _UpcomingBills(),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Transactions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      _PeriodSelector(selected: _selectedPeriod, onSelected: (val) => setState(() => _selectedPeriod = val)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._expenses.map((tx) => _TransactionCard(tx: tx)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
      ),
    );
  }
}

class _BudgetDashboard extends StatelessWidget {
  final double totalSpent;
  final double budget;
  final String petName;

  const _BudgetDashboard({required this.totalSpent, required this.budget, required this.petName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (totalSpent / budget).clamp(0.0, 1.0);
    final NumberFormat currencyFormat = NumberFormat.currency(symbol: r'$');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Spending for $petName', style: TextStyle(color: Colors.white.withAlpha(200), fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(currencyFormat.format(totalSpent), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withAlpha(40), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('12%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white.withAlpha(40), borderRadius: BorderRadius.circular(6)),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [BoxShadow(color: Colors.white.withAlpha(100), blurRadius: 8)],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Budget: ${currencyFormat.format(budget)}', style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13, fontWeight: FontWeight.w600)),
              Text('${(progress * 100).toInt()}% used', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;
  const _CategoryBreakdown({required this.expenses});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Food', 'icon': Icons.restaurant_rounded, 'color': Colors.orange},
      {'name': 'Health', 'icon': Icons.medical_services_rounded, 'color': Colors.redAccent},
      {'name': 'Toys', 'icon': Icons.toys_rounded, 'color': Colors.purpleAccent},
      {'name': 'Grooming', 'icon': Icons.content_cut_rounded, 'color': Colors.blueAccent},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category Breakdown', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final amount = expenses.where((e) => e['category'] == cat['name']).fold<double>(0.0, (sum, e) => sum + (e['amount'] as double));
            return _CategoryCard(name: cat['name'] as String, icon: cat['icon'] as IconData, color: cat['color'] as Color, amount: amount);
          },
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final double amount;

  const _CategoryCard({required this.name, required this.icon, required this.color, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withAlpha(40), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(name, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        ],
      ),
    );
  }
}

class _UpcomingBills extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withAlpha(100),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_repeat_rounded, color: colorScheme.secondary),
              const SizedBox(width: 12),
              Text('Upcoming Bills', style: TextStyle(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          _BillItem(title: 'Insurance Premium', date: 'May 04', amount: '45.00'),
          const Divider(height: 24),
          _BillItem(title: 'Food Subscription', date: 'May 12', amount: '85.00'),
        ],
      ),
    );
  }
}

class _BillItem extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  const _BillItem({required this.title, required this.date, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('Due $date', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        Text('\$$amount', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Map<String, dynamic> tx;
  const _TransactionCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: (tx['color'] as Color).withAlpha(30), shape: BoxShape.circle),
            child: Icon(tx['icon'] as IconData, color: tx['color'] as Color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('${DateFormat('MMM dd').format(tx['date'] as DateTime)} • ${tx['category']}', 
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text('-\$${(tx['amount'] as double).toStringAsFixed(2)}', 
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.redAccent)),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const _PeriodSelector({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: selected,
      onSelected: onSelected,
      itemBuilder: (context) => ['This Month', 'Last 3 Months', 'This Year'].map((p) => PopupMenuItem(value: p, child: Text(p))).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Text(selected, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
