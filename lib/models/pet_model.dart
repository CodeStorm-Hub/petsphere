class PetModel {
  final String id;
  final String userId;
  final String name;
  final String breed;
  final String animalType;
  final int age;
  final String bio;
  final String profileImageUrl;
  final List<String> images;
  final bool isPublicOwner;
  final bool isBreedingListed;
  final bool isVerified;

  PetModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.breed,
    required this.animalType,
    required this.age,
    required this.bio,
    required this.profileImageUrl,
    this.images = const [],
    this.isPublicOwner = true,
    this.isBreedingListed = false,
    this.isVerified = false,
  });

  PetModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? breed,
    String? animalType,
    int? age,
    String? bio,
    String? profileImageUrl,
    List<String>? images,
    bool? isPublicOwner,
    bool? isBreedingListed,
    bool? isVerified,
  }) {
    return PetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      animalType: animalType ?? this.animalType,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      images: images ?? this.images,
      isPublicOwner: isPublicOwner ?? this.isPublicOwner,
      isBreedingListed: isBreedingListed ?? this.isBreedingListed,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      breed: json['breed'] as String,
      animalType: json['animal_type'] as String,
      age: (json['age'] as num).toInt(),
      bio: json['bio'] as String? ?? '',
      profileImageUrl: json['profile_image_url'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isPublicOwner: json['is_public_owner'] as bool? ?? true,
      isBreedingListed: json['is_breeding_listed'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'breed': breed,
        'animal_type': animalType,
        'age': age,
        'bio': bio,
        'profile_image_url': profileImageUrl,
        'images': images,
        'is_public_owner': isPublicOwner,
        'is_breeding_listed': isBreedingListed,
        'is_verified': isVerified,
      };
}
