import 'package:petfolio/features/pet/data/models/pet_model.dart';

class CommentModel {
  final String id;
  final String petId;
  final String petName;

  /// From joined `pets.profile_image_url` when present (empty if unknown).
  final String petProfileImageUrl;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.petId,
    required this.petName,
    this.petProfileImageUrl = '',
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Comments are joined with the pets table via a Supabase select
    final petJson = json['pets'] as Map<String, dynamic>?;
    return CommentModel(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      petName: petJson?['name'] as String? ?? 'Unknown',
      petProfileImageUrl: petJson?['profile_image_url'] as String? ?? '',
      text: json['text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'pet_id': petId,
    'text': text,
    'created_at': createdAt.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          petId == other.petId &&
          petName == other.petName &&
          petProfileImageUrl == other.petProfileImageUrl &&
          text == other.text &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      petId.hashCode ^
      petName.hashCode ^
      petProfileImageUrl.hashCode ^
      text.hashCode ^
      createdAt.hashCode;
}

class PostModel {
  final String id;
  final PetModel pet;
  final String mediaUrl;
  final String caption;
  final String location;
  final List<String> taggedPetIds;
  final List<String> taggedPetNames;
  final List<String> likedByPetIds;
  final List<CommentModel> comments;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.pet,
    required this.mediaUrl,
    required this.caption,
    this.location = '',
    this.taggedPetIds = const [],
    this.taggedPetNames = const [],
    required this.likedByPetIds,
    this.comments = const [],
    required this.createdAt,
  });

  PostModel copyWith({
    String? id,
    PetModel? pet,
    String? mediaUrl,
    String? caption,
    String? location,
    List<String>? taggedPetIds,
    List<String>? taggedPetNames,
    List<String>? likedByPetIds,
    List<CommentModel>? comments,
    DateTime? createdAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      pet: pet ?? this.pet,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      caption: caption ?? this.caption,
      location: location ?? this.location,
      taggedPetIds: taggedPetIds ?? this.taggedPetIds,
      taggedPetNames: taggedPetNames ?? this.taggedPetNames,
      likedByPetIds: likedByPetIds ?? this.likedByPetIds,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Parses from a Supabase joined query:
  /// posts.*, pets(*), post_likes(pet_id), comments(*, pets(name))
  factory PostModel.fromJson(Map<String, dynamic> json) {
    final petJson = json['pets'] as Map<String, dynamic>;
    final likesJson = json['post_likes'] as List<dynamic>? ?? [];
    final commentsJson = json['comments'] as List<dynamic>? ?? [];

    return PostModel(
      id: json['id'] as String,
      pet: PetModel.fromJson(petJson),
      mediaUrl: json['media_url'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      location: json['location'] as String? ?? '',
      taggedPetIds:
          (json['tagged_pet_ids'] as List<dynamic>?)
              ?.map((id) => id as String)
              .toList() ??
          [],
      taggedPetNames:
          (json['tagged_pet_names'] as List<dynamic>?)
              ?.map((name) => name as String)
              .toList() ??
          [],
      likedByPetIds: likesJson
          .map((l) => (l as Map<String, dynamic>)['pet_id'] as String)
          .toList(),
      comments: commentsJson
          .map((c) => CommentModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'pets': pet.toJson(),
    'media_url': mediaUrl,
    'caption': caption,
    'location': location,
    'tagged_pet_ids': taggedPetIds,
    'tagged_pet_names': taggedPetNames,
    'post_likes': likedByPetIds.map((id) => {'pet_id': id}).toList(),
    'comments': comments.map((c) => c.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          pet == other.pet &&
          mediaUrl == other.mediaUrl &&
          caption == other.caption &&
          location == other.location &&
          taggedPetIds == other.taggedPetIds &&
          taggedPetNames == other.taggedPetNames &&
          likedByPetIds == other.likedByPetIds &&
          comments == other.comments &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      pet.hashCode ^
      mediaUrl.hashCode ^
      caption.hashCode ^
      location.hashCode ^
      taggedPetIds.hashCode ^
      taggedPetNames.hashCode ^
      likedByPetIds.hashCode ^
      comments.hashCode ^
      createdAt.hashCode;
}
