import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';

class PetHealthRecordExportScreen extends ConsumerStatefulWidget {
  const PetHealthRecordExportScreen({super.key});

  @override
  ConsumerState<PetHealthRecordExportScreen> createState() =>
      _PetHealthRecordExportScreenState();
}

class _PetHealthRecordExportScreenState
    extends ConsumerState<PetHealthRecordExportScreen> {
  final Map<String, bool> _options = {
    'Medical History': true,
    'Vaccination Records': true,
    'Growth Charts': false,
    'Expense Summaries': false,
    'Lab Results': true,
    'Prescriptions': true,
    'Vitals Log': false,
  };

  bool _isGenerating = false;

  Future<void> _handleExport(String action) async {
    setState(() => _isGenerating = true);
    // Simulate generation delay
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Health record successfully ${action == "share" ? "shared" : "downloaded"}!',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activePet = ref.watch(petProvider).activePet;
    final petName = activePet?.name ?? 'Pet';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Health Records'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _ExportPreviewCard(
                  petName: petName,
                  isGenerating: _isGenerating,
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Text(
                      'Select Categories',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          final allSelected = _options.values.every((v) => v);
                          _options.updateAll((k, v) => !allSelected);
                        });
                      },
                      icon: Icon(
                        _options.values.every((v) => v)
                            ? Icons.deselect_rounded
                            : Icons.select_all_rounded,
                        size: 18,
                      ),
                      label: Text(
                        _options.values.every((v) => v)
                            ? 'Deselect All'
                            : 'Select All',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh.withAlpha(150),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withAlpha(150),
                    ),
                  ),
                  child: Column(
                    children: _options.keys.map((key) {
                      final isLast = _options.keys.last == key;
                      return Column(
                        children: [
                          CheckboxListTile(
                            value: _options[key],
                            onChanged: (v) =>
                                setState(() => _options[key] = v ?? false),
                            title: Text(
                              key,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            activeColor: colorScheme.primary,
                            checkboxShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            controlAffinity: ListTileControlAffinity.trailing,
                          ),
                          if (!isLast)
                            Divider(
                              indent: 20,
                              endIndent: 20,
                              height: 1,
                              color: colorScheme.outlineVariant.withAlpha(100),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                _FormatSelector(),
              ],
            ),
          ),
          _ExportActions(isGenerating: _isGenerating, onAction: _handleExport),
        ],
      ),
    );
  }
}

class _ExportPreviewCard extends StatelessWidget {

  const _ExportPreviewCard({required this.petName, required this.isGenerating});
  final String petName;
  final bool isGenerating;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withAlpha(40),
            colorScheme.secondary.withAlpha(40),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: colorScheme.primary.withAlpha(80),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isGenerating)
            const SizedBox(
              height: 72,
              width: 72,
              child: CircularProgressIndicator(
                strokeWidth: 8,
                strokeCap: StrokeCap.round,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.picture_as_pdf_rounded,
                size: 56,
                color: colorScheme.primary,
              ),
            ),
          const SizedBox(height: 28),
          Text(
            '${petName}_Health_Record_${DateTime.now().year}.pdf',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isGenerating
                  ? 'Generating document...'
                  : 'Approx. 2.4 MB • 12 Pages',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: isGenerating ? null : () {},
            icon: const Icon(Icons.visibility_rounded, size: 18),
            label: const Text(
              'Preview Content',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormatSelector extends StatefulWidget {
  @override
  State<_FormatSelector> createState() => _FormatSelectorState();
}

class _FormatSelectorState extends State<_FormatSelector> {
  String _format = 'PDF';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'File Format',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'PDF',
              label: Text('PDF'),
              icon: Icon(Icons.picture_as_pdf, size: 16),
            ),
            ButtonSegment(
              value: 'CSV',
              label: Text('CSV'),
              icon: Icon(Icons.table_chart, size: 16),
            ),
            ButtonSegment(
              value: 'JSON',
              label: Text('JSON'),
              icon: Icon(Icons.code, size: 16),
            ),
          ],
          selected: {_format},
          onSelectionChanged: (set) => setState(() => _format = set.first),
        ),
      ],
    );
  }
}

class _ExportActions extends StatelessWidget {

  const _ExportActions({required this.isGenerating, required this.onAction});
  final bool isGenerating;
  final void Function(String) onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isGenerating ? null : () => onAction('share'),
              icon: const Icon(Icons.share_rounded, size: 20),
              label: const Text(
                'Share',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton.icon(
              onPressed: isGenerating ? null : () => onAction('download'),
              icon: const Icon(Icons.download_rounded, size: 20),
              label: const Text(
                'Download',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
