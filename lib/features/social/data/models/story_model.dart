import 'package:petsphere/core/utils/media_utils.dart';
import 'package:petsphere/features/pet/data/models/pet_model.dart';

/// Story rules enforced by this model and the backend:
///   • Still images display for 7 seconds per frame (enforced in viewer).
///   • Video slides play for up to 60 seconds maximum (enforced in viewer).
///   • Each story frame expires 24 hours after it was posted.
class StoryModel {
  final String id;
  final PetModel pet;
  final String mediaUrl;
  final String caption;
  final DateTime createdAt;

  /// Always `createdAt + 24 hours`; enforced by DB default + CHECK constraint.
  final DateTime expiresAt;

  const StoryModel({
    required this.id,
    required this.pet,
    required this.mediaUrl,
    this.caption = '',
    required this.createdAt,
    required this.expiresAt,
  });

  // ── Derived helpers ──────────────────────────────────────────────────────

  /// Whether this story's media is a video.
  bool get isVideo => isVideoMedia(mediaUrl);

  /// How long until this frame disappears from public view.
  Duration get remainingTime {
    final diff = expiresAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// True if the 24-hour window has passed.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  // ── Serialisation ────────────────────────────────────────────────────────

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'pets': pet.toJson(),
    'media_url': mediaUrl,
    'caption': caption,
    'created_at': createdAt.toUtc().toIso8601String(),
    'expires_at': expiresAt.toUtc().toIso8601String(),
  };

  StoryModel copyWith({
    String? id,
    PetModel? pet,
    String? mediaUrl,
    String? caption,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return StoryModel(
      id: id ?? this.id,
      pet: pet ?? this.pet,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          pet == other.pet &&
          mediaUrl == other.mediaUrl &&
          caption == other.caption &&
          createdAt == other.createdAt &&
          expiresAt == other.expiresAt;

  @override
  int get hashCode =>
      id.hashCode ^
      pet.hashCode ^
      mediaUrl.hashCode ^
      caption.hashCode ^
      createdAt.hashCode ^
      expiresAt.hashCode;
}
