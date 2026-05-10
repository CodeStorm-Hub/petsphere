import re

file_path = 'lib/features/health/presentation/screens/health_tab.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    text = f.read()

# _VitalsSection
text = re.sub(r'class _VitalsSection extends ConsumerStatefulWidget \{\s*final PetCareState careState;\s*const _VitalsSection\(\{super\.key, required this\.careState\}\);', r'class _VitalsSection extends ConsumerStatefulWidget {\n  const _VitalsSection({super.key});', text)
text = re.sub(r'class _VitalsSection extends ConsumerStatefulWidget \{\s*final PetCareState careState;\s*const _VitalsSection\(\{required this\.careState\}\);', r'class _VitalsSection extends ConsumerStatefulWidget {\n  const _VitalsSection();', text)

# _MedicationsSection
text = re.sub(r'(class _MedicationsSection extends ConsumerWidget \{.*?Widget build\(BuildContext context, WidgetRef ref\) \{\s*final colorScheme = Theme\.of\(context\)\.colorScheme;)', r'\1\n    final medications = ref.watch(medicationProvider).activeMedications;', text, flags=re.DOTALL)
text = text.replace('healthState.todayDoses', 'ref.watch(medicationProvider).todayDoses')

# _AppointmentsSection
text = re.sub(r'(class _AppointmentsSection extends ConsumerWidget \{.*?Widget build\(BuildContext context, WidgetRef ref\) \{\s*final colorScheme = Theme\.of\(context\)\.colorScheme;)', r'\1\n    final appointments = ref.watch(appointmentProvider).upcomingAppointments;', text, flags=re.DOTALL)

# _VaccinationsSection
text = re.sub(r'(class _VaccinationsSection extends ConsumerWidget \{.*?Widget build\(BuildContext context, WidgetRef ref\) \{\s*final colorScheme = Theme\.of\(context\)\.colorScheme;)', r'\1\n    final vaccinations = ref.watch(vaccinationProvider).vaccinations;', text, flags=re.DOTALL)

# _ParasiteSection
text = re.sub(r'(class _ParasiteSection extends ConsumerWidget \{.*?Widget build\(BuildContext context, WidgetRef ref\) \{\s*final colorScheme = Theme\.of\(context\)\.colorScheme;)', r'\1\n    final entries = ref.watch(parasiteProvider).latestPerType;', text, flags=re.DOTALL)

# _DentalSection
text = re.sub(r'(class _DentalSection extends ConsumerWidget \{.*?Widget build\(BuildContext context, WidgetRef ref\) \{\s*final colorScheme = Theme\.of\(context\)\.colorScheme;)', r'\1\n    final logs = ref.watch(dentalProvider).dentalLogs;', text, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(text)

print('Done 3')
