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
  final bool isVaccinated;
  final bool isCareListed;

  /// Care goals & current vitals — `null` if the owner hasn't set them yet
  /// (the UI then falls back to sensible defaults).
  final int? dailyCalorieGoal;
  final int? dailyWaterGoalCups;
  final double? weightLbs;
  final double monthlyBudget;

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
    this.isVaccinated = false,
    this.isCareListed = false,
    this.dailyCalorieGoal,
    this.dailyWaterGoalCups,
    this.weightLbs,
    this.monthlyBudget = 1000.0,
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
    bool? isVaccinated,
    bool? isCareListed,
    int? dailyCalorieGoal,
    int? dailyWaterGoalCups,
    double? weightLbs,
    double? monthlyBudget,
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
      isVaccinated: isVaccinated ?? this.isVaccinated,
      isCareListed: isCareListed ?? this.isCareListed,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      dailyWaterGoalCups: dailyWaterGoalCups ?? this.dailyWaterGoalCups,
      weightLbs: weightLbs ?? this.weightLbs,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
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
      isVaccinated: json['is_vaccinated'] as bool? ?? false,
      isCareListed: json['is_care_listed'] as bool? ?? false,
      dailyCalorieGoal: (json['daily_calorie_goal'] as num?)?.toInt(),
      dailyWaterGoalCups: (json['daily_water_goal_cups'] as num?)?.toInt(),
      weightLbs: (json['weight_lbs'] as num?)?.toDouble(),
      monthlyBudget: (json['monthly_budget'] as num?)?.toDouble() ?? 1000.0,
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
        'is_vaccinated': isVaccinated,
        'is_care_listed': isCareListed,
        if (dailyCalorieGoal != null) 'daily_calorie_goal': dailyCalorieGoal,
        if (dailyWaterGoalCups != null)
          'daily_water_goal_cups': dailyWaterGoalCups,
        if (weightLbs != null) 'weight_lbs': weightLbs,
        'monthly_budget': monthlyBudget,
      };
}
