import 'pet_model.dart';

class StoryModel {
  final String id;
  final PetModel pet;
  final String mediaUrl;
  final String caption;
  final DateTime createdAt;
  final DateTime expiresAt;

  const StoryModel({
    required this.id,
    required this.pet,
    required this.mediaUrl,
    this.caption = '',
    required this.createdAt,
    required this.expiresAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final petJson = json['pets'] as Map<String, dynamic>;
    return StoryModel(
      id: json['id'] as String,
      pet: PetModel.fromJson(petJson),
      mediaUrl: json['media_url'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      expiresAt: DateTime.parse(json['expires_at'] as String).toLocal(),
    );
  }
}
