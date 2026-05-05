import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/pet_controller.dart';
import '../controllers/pet_expense_controller.dart';
import '../models/pet_expense_model.dart';

class PetExpenseTrackerScreen extends ConsumerStatefulWidget {
  const PetExpenseTrackerScreen({super.key});

  @override
  ConsumerState<PetExpenseTrackerScreen> createState() =>
      _PetExpenseTrackerScreenState();
}

class _PetExpenseTrackerScreenState
    extends ConsumerState<PetExpenseTrackerScreen> {
  String _selectedPeriod = 'This Month';

  void _showAddExpenseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddExpenseModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petProvider);
    final expenseState = ref.watch(petExpenseProvider);
    final expenses = expenseState.expenses;
    final totalSpent = expenseState.totalSpent;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            title: const Text('Expense Tracker',
                style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton.filledTonal(
                  onPressed: () {}, icon: const Icon(Icons.file_download_rounded)),
              const SizedBox(width: 8),
            ],
          ),
          if (expenseState.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BudgetDashboard(
                        totalSpent: totalSpent,
                        budget: petState.activePet?.monthlyBudget ?? 1000.00,
                        petName: petState.activePet?.name ?? 'Pet'),
                    const SizedBox(height: 32),
                    _CategoryBreakdown(expenses: expenses),
                    const SizedBox(height: 32),
                    _UpcomingBills(),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Transactions',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        _PeriodSelector(
                            selected: _selectedPeriod,
                            onSelected: (val) =>
                                setState(() => _selectedPeriod = val)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (expenses.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  size: 64,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant),
                              const SizedBox(height: 16),
                              Text('No expenses logged yet',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant)),
                            ],
                          ),
                        ),
                      )
                    else
                      ...expenses.map((tx) => _TransactionCard(tx: tx)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseModal(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
      ),
    );
  }
}

class _AddExpenseModal extends ConsumerStatefulWidget {
  const _AddExpenseModal();

  @override
  ConsumerState<_AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends ConsumerState<_AddExpenseModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.food;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        top: 32,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add Expense',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                prefixIcon: const Icon(Icons.title_rounded),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixIcon: const Icon(Icons.attach_money_rounded),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              validator: (v) {
                if (v?.isEmpty == true) return 'Required';
                if (double.tryParse(v!) == null) return 'Invalid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExpenseCategory>(
              initialValue: _category,
              decoration: InputDecoration(
                labelText: 'Category',
                prefixIcon: const Icon(Icons.category_rounded),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              items: ExpenseCategory.values
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.label),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _date = d);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outline),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 20),
                    const SizedBox(width: 12),
                    Text(DateFormat('MMM dd, yyyy').format(_date)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await ref.read(petExpenseProvider.notifier).addExpense(
                        title: _titleController.text,
                        amount: double.parse(_amountController.text),
                        date: _date,
                        category: _category,
                      );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetDashboard extends ConsumerWidget {
  final double totalSpent;
  final double budget;
  final String petName;

  const _BudgetDashboard(
      {required this.totalSpent, required this.budget, required this.petName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (totalSpent / budget).clamp(0.0, 1.0);
    final NumberFormat currencyFormat = NumberFormat.currency(symbol: r'$');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Spending for $petName',
                      style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(currencyFormat.format(totalSpent),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 32)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => _showEditBudgetDialog(context, ref),
                    icon: const Icon(Icons.edit_note_rounded, color: Colors.white70),
                    tooltip: 'Edit Budget',
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Row(
                      children: [
                        Icon(Icons.trending_up_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('12%',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(6)),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(color: Colors.white.withAlpha(100), blurRadius: 8)
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Budget: ${currencyFormat.format(budget)}',
                  style: TextStyle(
                      color: Colors.white.withAlpha(200),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              Text('${(progress * 100).toInt()}% used',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: budget.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Budget Amount',
            prefixText: r'$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final newBudget = double.tryParse(controller.text);
              if (newBudget != null) {
                final activePet = ref.read(activePetProvider);
                if (activePet != null) {
                  await ref
                      .read(petProvider.notifier)
                      .updatePet(activePet.id, {'monthly_budget': newBudget});
                }
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final List<PetExpense> expenses;
  const _CategoryBreakdown({required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category Breakdown',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
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
          itemCount: ExpenseCategory.values.length,
          itemBuilder: (context, index) {
            final cat = ExpenseCategory.values[index];
            final amount = expenses
                .where((e) => e.category == cat)
                .fold<double>(0.0, (sum, e) => sum + e.amount);
            return _CategoryCard(
                name: cat.label, icon: cat.icon, color: cat.color, amount: amount);
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

  const _CategoryCard(
      {required this.name,
      required this.icon,
      required this.color,
      required this.amount});

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
            decoration:
                BoxDecoration(color: color.withAlpha(40), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(name,
              style:
                  TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          Text('\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
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
              Text('Upcoming Bills',
                  style: TextStyle(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          const _BillItem(
              title: 'Insurance Premium', date: 'May 04', amount: '45.00'),
          const Divider(height: 24),
          const _BillItem(
              title: 'Food Subscription', date: 'May 12', amount: '85.00'),
        ],
      ),
    );
  }
}

class _BillItem extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  const _BillItem(
      {required this.title, required this.date, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('Due $date',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        Text('\$$amount',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
      ],
    );
  }
}

class _TransactionCard extends ConsumerWidget {
  final PetExpense tx;
  const _TransactionCard({required this.tx});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(petExpenseProvider.notifier).deleteExpense(tx.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: tx.category.color.withAlpha(30), shape: BoxShape.circle),
              child: Icon(tx.category.icon, color: tx.category.color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(
                      '${DateFormat('MMM dd').format(tx.date)} • ${tx.category.label}',
                      style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Text('-\$${tx.amount.toStringAsFixed(2)}',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: colorScheme.error)),
          ],
        ),
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
      itemBuilder: (context) => ['This Month', 'Last 3 Months', 'This Year']
          .map((p) => PopupMenuItem(value: p, child: Text(p)))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Text(selected,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

