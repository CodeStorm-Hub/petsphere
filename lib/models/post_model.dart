import 'pet_model.dart';

class CommentModel {
  final String id;
  final String petId;
  final String petName;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.petId,
    required this.petName,
    required this.text,
    required this.createdAt,
  });
}

class PostModel {
  final String id;
  final PetModel pet;
  final String mediaUrl;
  final String caption;
  final List<String> likedByPetIds;
  final List<CommentModel> comments;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.pet,
    required this.mediaUrl,
    required this.caption,
    required this.likedByPetIds,
    this.comments = const [],
    required this.createdAt,
  });

  PostModel copyWith({
    String? id,
    PetModel? pet,
    String? mediaUrl,
    String? caption,
    List<String>? likedByPetIds,
    List<CommentModel>? comments,
    DateTime? createdAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      pet: pet ?? this.pet,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      caption: caption ?? this.caption,
      likedByPetIds: likedByPetIds ?? this.likedByPetIds,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
