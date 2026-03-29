class PetModel {
  final String id;
  final String userId;
  final String name;
  final String breed;
  final int age;
  final String bio;
  final String profileImageUrl;
  final List<String> images;
  final bool isPublicOwner;

  PetModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.breed,
    required this.age,
    required this.bio,
    required this.profileImageUrl,
    this.images = const [],
    this.isPublicOwner = true,
  });

  PetModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? breed,
    int? age,
    String? bio,
    String? profileImageUrl,
    List<String>? images,
    bool? isPublicOwner,
  }) {
    return PetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      images: images ?? this.images,
      isPublicOwner: isPublicOwner ?? this.isPublicOwner,
    );
  }
}
