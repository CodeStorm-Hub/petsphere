import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:petfolio/features/health/presentation/controllers/appointment_controller.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/features/health/data/models/pet_health_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Vet Booking Screen — #33 Fully backed by pet_vet_appointments table
// ─────────────────────────────────────────────────────────────────────────────

class VetBookingScreen extends ConsumerStatefulWidget {
  const VetBookingScreen({super.key});

  @override
  ConsumerState<VetBookingScreen> createState() => _VetBookingScreenState();
}

class _VetBookingScreenState extends ConsumerState<VetBookingScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _query = '';

  final List<String> _categories = [
    'All',
    'General',
    'Dental',
    'Surgery',
    'Emergency',
    'Specialist',
  ];

  // Static vet data (discovery layer — real booking writes to pet_vet_appointments)
  final List<Map<String, dynamic>> _allVets = [
    {
      'name': 'Dr. Sarah Wilson',
      'clinic': 'Paws & Claws Clinic',
      'rating': 4.9,
      'distance': '1.2 km',
      'specialty': 'General',
      'image': 'https://i.pravatar.cc/150?u=sarah',
      'price': r'$$',
      'bio': 'Specializes in preventive care and wellness for dogs and cats.',
    },
    {
      'name': 'Dr. Michael Chen',
      'clinic': 'City Pet Hospital',
      'rating': 4.7,
      'distance': '2.5 km',
      'specialty': 'Dental',
      'image': 'https://i.pravatar.cc/150?u=michael',
      'price': r'$$$',
      'bio': 'Board-certified dental surgeon with 12 years of experience.',
    },
    {
      'name': 'Dr. Emily Brown',
      'clinic': 'Green Valley Vets',
      'rating': 4.8,
      'distance': '3.8 km',
      'specialty': 'Emergency',
      'image': 'https://i.pravatar.cc/150?u=emily',
      'price': r'$$',
      'bio': '24/7 emergency care specialist. Available on short notice.',
    },
    {
      'name': 'Dr. James Okafor',
      'clinic': 'Harbour Animal Hospital',
      'rating': 4.6,
      'distance': '4.1 km',
      'specialty': 'Surgery',
      'image': 'https://i.pravatar.cc/150?u=james',
      'price': r'$$$',
      'bio': 'Soft tissue and orthopaedic surgeon for companion animals.',
    },
    {
      'name': 'Dr. Priya Nair',
      'clinic': 'Meadow Vet Clinic',
      'rating': 4.9,
      'distance': '5.0 km',
      'specialty': 'Specialist',
      'image': 'https://i.pravatar.cc/150?u=priya',
      'price': r'$',
      'bio': 'Dermatology and allergy specialist. Telemedicine available.',
    },
  ];

  List<Map<String, dynamic>> get _filteredVets {
    return _allVets.where((v) {
      final matchesCategory =
          _selectedCategory == 'All' || v['specialty'] == _selectedCategory;
      final matchesQuery =
          _query.isEmpty ||
          (v['name'] as String).toLowerCase().contains(_query) ||
          (v['clinic'] as String).toLowerCase().contains(_query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appointmentState = ref.watch(appointmentProvider);
    final upcoming = appointmentState.upcomingAppointments;

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
              backgroundColor: WidgetStateProperty.all(
                colorScheme.surfaceContainerHighest.withAlpha(100),
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Upcoming appointments banner ─────────────────────────────────
          if (upcoming.isNotEmpty) _UpcomingBanner(appointments: upcoming),

          // ── Category chips ───────────────────────────────────────────────
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
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontSize: 12,
                    ),
                    selectedColor: colorScheme.primary,
                  ),
                );
              },
            ),
          ),

          // ── Vet list ──────────────────────────────────────────────────────
          Expanded(
            child: _filteredVets.isEmpty
                ? const Center(child: Text('No vets match your search.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredVets.length,
                    itemBuilder: (context, index) {
                      return _VetCard(
                        vet: _filteredVets[index],
                        onBook: () => _openBookingSheet(_filteredVets[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _openBookingSheet(Map<String, dynamic> vet) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _VetBookingSheet(vet: vet),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Upcoming appointments compact banner
// ─────────────────────────────────────────────────────────────────────────────

class _UpcomingBanner extends StatelessWidget {
  final List<PetVetAppointment> appointments;
  const _UpcomingBanner({required this.appointments});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final next = appointments.first;
    final isOverdue = next.scheduledAt.isBefore(DateTime.now());
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOverdue
            ? colorScheme.errorContainer
            : colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? Icons.warning_amber_rounded : Icons.event_available,
            color: isOverdue
                ? colorScheme.onErrorContainer
                : colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOverdue
                      ? 'Overdue: ${next.title}'
                      : 'Upcoming: ${next.title}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isOverdue
                        ? colorScheme.onErrorContainer
                        : colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  '${DateFormat('MMM d, y • h:mm a').format(next.scheduledAt)}'
                  '${next.doctor != null ? ' — ${next.doctor}' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOverdue
                        ? colorScheme.onErrorContainer
                        : colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          if (appointments.length > 1)
            Chip(
              label: Text('+${appointments.length - 1}'),
              backgroundColor: colorScheme.surface,
              side: BorderSide.none,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vet card
// ─────────────────────────────────────────────────────────────────────────────

class _VetCard extends StatelessWidget {
  final Map<String, dynamic> vet;
  final VoidCallback onBook;
  const _VetCard({required this.vet, required this.onBook});

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
        onTap: onBook,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  vet['image'] as String,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 80,
                    height: 80,
                    color: colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.person),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vet['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      vet['clinic'] as String,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: colorScheme.tertiary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${vet['rating']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.location_on,
                          color: colorScheme.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          vet['distance'] as String,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        vet['specialty'] as String,
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    vet['price'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: onBook,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('Book'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking bottom sheet — saves to pet_vet_appointments
// ─────────────────────────────────────────────────────────────────────────────

class _VetBookingSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> vet;
  const _VetBookingSheet({required this.vet});

  @override
  ConsumerState<_VetBookingSheet> createState() => _VetBookingSheetState();
}

class _VetBookingSheetState extends ConsumerState<_VetBookingSheet> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  String _selectedType = 'routine';
  bool _isSaving = false;
  final _notesController = TextEditingController();

  final List<String> _timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
  ];

  final List<Map<String, String>> _apptTypes = [
    {'value': 'routine', 'label': 'Routine'},
    {'value': 'emergency', 'label': 'Emergency'},
    {'value': 'specialist', 'label': 'Specialist'},
    {'value': 'dental', 'label': 'Dental'},
    {'value': 'surgery', 'label': 'Surgery'},
    {'value': 'follow_up', 'label': 'Follow-up'},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    final activePet = ref.read(activePetProvider);
    if (activePet == null || _selectedTime == null) return;

    setState(() => _isSaving = true);

    // Parse time string to DateTime
    final timeParts = _selectedTime!
        .replaceAll(' AM', '')
        .replaceAll(' PM', '')
        .split(':');
    var hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    if (_selectedTime!.contains('PM') && hour != 12) hour += 12;
    if (_selectedTime!.contains('AM') && hour == 12) hour = 0;

    final scheduledAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      minute,
    );

    final appt = PetVetAppointment(
      id: const Uuid().v4(),
      petId: activePet.id,
      title: '${widget.vet['name']} — ${widget.vet['clinic']}',
      doctor: widget.vet['name'] as String,
      scheduledAt: scheduledAt,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),

      appointmentType: _selectedType,
      location: widget.vet['clinic'] as String,
    );

    await ref.read(appointmentProvider.notifier).upsertAppointment(appt);

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Appointment booked for ${DateFormat('MMM d').format(_selectedDate)} at $_selectedTime',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      maxChildSize: 0.95,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ───────────────────────────────────────────────────
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(widget.vet['image'] as String),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.vet['name'] as String,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        widget.vet['clinic'] as String,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        widget.vet['bio'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            // ── Appointment type ─────────────────────────────────────────
            Text(
              'Appointment Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _apptTypes.map((t) {
                final isSelected = _selectedType == t['value'];
                return ChoiceChip(
                  label: Text(t['label']!),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _selectedType = t['value']!),
                  selectedColor: colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),

            const Divider(height: 28),

            // ── Date picker ──────────────────────────────────────────────
            Text('Select Date', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 14,
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index + 1));
                  final isSelected =
                      date.day == _selectedDate.day &&
                      date.month == _selectedDate.month;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () => setState(() => _selectedDate = date),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 60,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('E').format(date),
                              style: TextStyle(
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
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

            // ── Time slots ───────────────────────────────────────────────
            Text(
              'Available Time Slots',
              style: Theme.of(context).textTheme.titleMedium,
            ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.secondary
                          : colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.secondary
                            : colorScheme.outlineVariant,
                      ),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        color: isSelected
                            ? colorScheme.onSecondary
                            : colorScheme.onSurface,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── Notes ────────────────────────────────────────────────────
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Describe symptoms or reason for visit...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            // ── Confirm button ───────────────────────────────────────────
            FilledButton(
              onPressed: (_selectedTime == null || _isSaving)
                  ? null
                  : _confirmBooking,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
