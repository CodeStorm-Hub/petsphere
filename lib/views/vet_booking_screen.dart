import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class VetBookingScreen extends ConsumerStatefulWidget {
  const VetBookingScreen({super.key});

  @override
  ConsumerState<VetBookingScreen> createState() => _VetBookingScreenState();
}

class _VetBookingScreenState extends ConsumerState<VetBookingScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'General', 'Dental', 'Surgery', 'Emergency'];

  final List<Map<String, dynamic>> _vets = [
    {
      'name': 'Dr. Sarah Wilson',
      'clinic': 'Paws & Claws Clinic',
      'rating': 4.9,
      'distance': '1.2 km',
      'specialty': 'General Practice',
      'image': 'https://i.pravatar.cc/150?u=sarah',
      'price': r'$$',
    },
    {
      'name': 'Dr. Michael Chen',
      'clinic': 'City Pet Hospital',
      'rating': 4.7,
      'distance': '2.5 km',
      'specialty': 'Dental Surgeon',
      'image': 'https://i.pravatar.cc/150?u=michael',
      'price': r'$$$',
    },
    {
      'name': 'Dr. Emily Brown',
      'clinic': 'Green Valley Vets',
      'rating': 4.8,
      'distance': '3.8 km',
      'specialty': 'Emergency Care',
      'image': 'https://i.pravatar.cc/150?u=emily',
      'price': r'$$',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Vet'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search clinic or doctor...',
              leading: const Icon(Icons.search),
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(colorScheme.surfaceContainerHighest.withAlpha(100)),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                    labelStyle: TextStyle(
                      color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                      fontSize: 12,
                    ),
                    selectedColor: colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _vets.length,
              itemBuilder: (context, index) {
                final vet = _vets[index];
                return _VetCard(vet: vet);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VetCard extends StatelessWidget {
  final Map<String, dynamic> vet;
  const _VetCard({required this.vet});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () => _showBookingDetails(context, vet),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  vet['image'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vet['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      vet['clinic'],
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${vet['rating']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.location_on, color: colorScheme.primary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          vet['distance'],
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vet['specialty'],
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(vet['price'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 8),
                  Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDetails(BuildContext context, Map<String, dynamic> vet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _VetDetailSheet(vet: vet),
    );
  }
}

class _VetDetailSheet extends StatefulWidget {
  final Map<String, dynamic> vet;
  const _VetDetailSheet({required this.vet});

  @override
  State<_VetDetailSheet> createState() => _VetDetailSheetState();
}

class _VetDetailSheetState extends State<_VetDetailSheet> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;

  final List<String> _timeSlots = [
    '09:00 AM', '10:00 AM', '11:00 AM', '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM'
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(widget.vet['image']),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.vet['name'], style: Theme.of(context).textTheme.titleLarge),
                    Text(widget.vet['clinic'], style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Text('Select Date', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 14,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index + 1));
                final isSelected = date.day == _selectedDate.day;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () => setState(() => _selectedDate = date),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: isSelected ? colorScheme.primary : colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? colorScheme.primary : colorScheme.outlineVariant),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('E').format(date),
                            style: TextStyle(
                              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text('Available Time Slots', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _timeSlots.map((time) {
              final isSelected = _selectedTime == time;
              return InkWell(
                onTap: () => setState(() => _selectedTime = time),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.secondary : colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? colorScheme.secondary : colorScheme.outlineVariant),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      color: isSelected ? colorScheme.onSecondary : colorScheme.onSurface,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _selectedTime == null ? null : () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Appointment requested for ${DateFormat('MMM d').format(_selectedDate)} at $_selectedTime')),
              );
            },
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }
}
