import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petfolio/features/community/data/community_group_repository.dart';
import 'package:petfolio/core/widgets/petfolio_empty_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final _groupsProvider = FutureProvider.family<List<CommunityGroup>, String>((
  ref,
  category,
) async {
  return communityGroupRepository.fetchGroups(
    category: category == 'All' ? null : category,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Community Groups Screen — #36
// ─────────────────────────────────────────────────────────────────────────────

class CommunityGroupsScreen extends ConsumerStatefulWidget {
  const CommunityGroupsScreen({super.key});

  @override
  ConsumerState<CommunityGroupsScreen> createState() =>
      _CommunityGroupsScreenState();
}

class _CommunityGroupsScreenState extends ConsumerState<CommunityGroupsScreen> {
  String _category = 'All';
  final List<String> _categories = [
    'All',
    'dogs',
    'cats',
    'birds',
    'training',
    'health',
    'adoption',
    'general',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final async = ref.watch(_groupsProvider(_category));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Create group',
            onPressed: () => _openCreateSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = _category == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat == 'All' ? 'All' : _capitalize(cat)),
                    selected: selected,
                    onSelected: (_) => setState(() => _category = cat),
                    selectedColor: colorScheme.primary,
                    labelStyle: TextStyle(
                      color: selected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),

          // Groups list
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (groups) => groups.isEmpty
                  ? const PetfolioEmptyState(
                      icon: Icons.group_rounded,
                      title: 'No Groups',
                      message: 'No groups yet.\nBe the first to create one!',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: groups.length,
                      itemBuilder: (_, i) => _GroupCard(
                        group: groups[i],
                        onToggle: () async {
                          final auth = ref.read(authProvider);
                          if (auth.user == null) return;
                          if (groups[i].isMember) {
                            await communityGroupRepository.leaveGroup(
                              groups[i].id,
                            );
                          } else {
                            await communityGroupRepository.joinGroup(
                              groups[i].id,
                            );
                          }
                          ref.invalidate(_groupsProvider(_category));
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _openCreateSheet(BuildContext context) {
    final auth = ref.read(authProvider);
    if (auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to create a group')),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CreateGroupSheet(
        ownerId: auth.user!.id,
        onCreated: () => ref.invalidate(_groupsProvider(_category)),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────────────────
// Group card
// ─────────────────────────────────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group, required this.onToggle});
  final CommunityGroup group;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Cover image / icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  image: group.coverUrl != null
                      ? DecorationImage(
                          image: NetworkImage(group.coverUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: group.coverUrl == null
                    ? Icon(
                        Icons.group_rounded,
                        color: colorScheme.onPrimaryContainer,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (group.description != null)
                      Text(
                        group.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${group.memberCount} members',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            group.category,
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: onToggle,
                style: FilledButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(fontSize: 12),
                  backgroundColor: group.isMember
                      ? colorScheme.errorContainer
                      : colorScheme.primaryContainer,
                  foregroundColor: group.isMember
                      ? colorScheme.onErrorContainer
                      : colorScheme.onPrimaryContainer,
                ),
                child: Text(group.isMember ? 'Leave' : 'Join'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Create group sheet
// ─────────────────────────────────────────────────────────────────────────────

class _CreateGroupSheet extends StatefulWidget {
  const _CreateGroupSheet({required this.ownerId, required this.onCreated});
  final String ownerId;
  final VoidCallback onCreated;

  @override
  State<_CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<_CreateGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'general';
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await communityGroupRepository.createGroup(
        CommunityGroup(
          id: '',
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          category: _category,
          ownerId: widget.ownerId,
          memberCount: 1,
          isPublic: true,
          createdAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      widget.onCreated();
      Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create Group',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Group Name *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: [
                'general',
                'dogs',
                'cats',
                'birds',
                'training',
                'health',
                'adoption',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}

