class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? profileImageUrl;
  final String? bio;
  final String? location;
  final List<String> publicCareBadgeSlugs;
  final bool showCareBadgesOnProfile;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.profileImageUrl,
    this.bio,
    this.location,
    this.publicCareBadgeSlugs = const [],
    this.showCareBadgesOnProfile = true,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    String? bio,
    String? location,
    List<String>? publicCareBadgeSlugs,
    bool? showCareBadgesOnProfile,
    bool clearProfileImage = false,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl:
          clearProfileImage ? null : (profileImageUrl ?? this.profileImageUrl),
      bio: bio ?? this.bio,
      location: location ?? this.location,
      publicCareBadgeSlugs: publicCareBadgeSlugs ?? this.publicCareBadgeSlugs,
      showCareBadgesOnProfile:
          showCareBadgesOnProfile ?? this.showCareBadgesOnProfile,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      publicCareBadgeSlugs: (json['public_care_badge_slugs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      showCareBadgesOnProfile:
          json['show_care_badges_on_profile'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'profile_image_url': profileImageUrl,
        'bio': bio,
        'location': location,
        'public_care_badge_slugs': publicCareBadgeSlugs,
        'show_care_badges_on_profile': showCareBadgesOnProfile,
      };

  /// Returns initials for avatar fallback (e.g. "JD" for "John Doe")
  String get initials {
    final n = name?.trim() ?? '';
    if (n.isEmpty) return email.isNotEmpty ? email[0].toUpperCase() : '?';
    final parts = n.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
