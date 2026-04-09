class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? profileImageUrl;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.profileImageUrl,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'profile_image_url': profileImageUrl,
      };
}
