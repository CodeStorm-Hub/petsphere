import 'package:petfolio/core/constants/app_durations.dart';
import 'package:petfolio/core/constants/supabase_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

class CommunityGroup {
  CommunityGroup({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    this.coverUrl,
    required this.ownerId,
    required this.memberCount,
    required this.isPublic,
    required this.createdAt,
    this.isMember = false,
  });

  factory CommunityGroup.fromJson(Map<String, dynamic> json) => CommunityGroup(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    category: json['category'] as String? ?? 'general',
    coverUrl: json['cover_url'] as String?,
    ownerId: json['owner_id'] as String,
    memberCount: json['member_count'] as int? ?? 0,
    isPublic: json['is_public'] as bool? ?? true,
    createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
  );
  final String id;
  final String name;
  final String? description;
  final String category;
  final String? coverUrl;
  final String ownerId;
  final int memberCount;
  final bool isPublic;
  final DateTime createdAt;
  bool isMember;
}

// ─────────────────────────────────────────────────────────────────────────────
// Repository
// ─────────────────────────────────────────────────────────────────────────────

class CommunityGroupRepository {
  final _db = supabase;

  Future<List<CommunityGroup>> fetchGroups({String? category}) async {
    final query = _db
        .from('community_groups')
        .select()
        .eq('is_public', true)
        .order('member_count', ascending: false)
        .limit(50);
    final rows = await query.timeout(AppDurations.defaultNetworkTimeout);
    var groups = (rows as List)
        .map((r) => CommunityGroup.fromJson(r as Map<String, dynamic>))
        .toList();
    if (category != null && category != 'All') {
      groups = groups.where((g) => g.category == category).toList();
    }
    // Mark membership
    final userId = _db.auth.currentUser?.id;
    if (userId != null && groups.isNotEmpty) {
      final ids = groups.map((g) => g.id).toList();
      final memberships = await _db
          .from('community_group_members')
          .select('group_id')
          .eq('user_id', userId)
          .inFilter('group_id', ids)
          .timeout(AppDurations.defaultNetworkTimeout);
      final memberSet = (memberships as List)
          .map((r) => r['group_id'] as String)
          .toSet();
      for (final g in groups) {
        g.isMember = memberSet.contains(g.id);
      }
    }
    return groups;
  }

  Future<void> joinGroup(String groupId) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return;
    await _db
        .from('community_group_members')
        .upsert({
          'group_id': groupId,
          'user_id': userId,
        }, onConflict: 'group_id,user_id')
        .timeout(AppDurations.defaultNetworkTimeout);
  }

  Future<void> leaveGroup(String groupId) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return;
    await _db
        .from('community_group_members')
        .delete()
        .eq('group_id', groupId)
        .eq('user_id', userId)
        .timeout(AppDurations.defaultNetworkTimeout);
  }

  Future<CommunityGroup> createGroup(CommunityGroup g) async {
    final row = await _db
        .from('community_groups')
        .insert({
          'name': g.name,
          if (g.description != null) 'description': g.description,
          'category': g.category,
          if (g.coverUrl != null) 'cover_url': g.coverUrl,
          'owner_id': g.ownerId,
          'is_public': g.isPublic,
        })
        .select()
        .single()
        .timeout(AppDurations.defaultNetworkTimeout);
    return CommunityGroup.fromJson(row);
  }
}

final communityGroupRepository = CommunityGroupRepository();
