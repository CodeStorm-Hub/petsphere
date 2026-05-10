import 'package:flutter/foundation.dart';

@immutable
class KnowledgeArticle {

  const KnowledgeArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrl,
    this.readTime,
    this.isExpertVerified = false,
    this.isFeatured = false,
    required this.createdAt,
  });

  factory KnowledgeArticle.fromJson(Map<String, dynamic> json) =>
      KnowledgeArticle(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        category: json['category'] as String,
        imageUrl: json['image_url'] as String?,
        readTime: json['read_time'] as String?,
        isExpertVerified: json['is_expert_verified'] as bool? ?? false,
        isFeatured: json['is_featured'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      );
  final String id;
  final String title;
  final String content;
  final String category;
  final String? imageUrl;
  final String? readTime;
  final bool isExpertVerified;
  final bool isFeatured;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'category': category,
    'image_url': imageUrl,
    'read_time': readTime,
    'is_expert_verified': isExpertVerified,
    'is_featured': isFeatured,
    'created_at': createdAt.toUtc().toIso8601String(),
  };

  KnowledgeArticle copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    String? imageUrl,
    String? readTime,
    bool? isExpertVerified,
    bool? isFeatured,
    DateTime? createdAt,
  }) {
    return KnowledgeArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      readTime: readTime ?? this.readTime,
      isExpertVerified: isExpertVerified ?? this.isExpertVerified,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KnowledgeArticle &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          content == other.content &&
          category == other.category &&
          imageUrl == other.imageUrl &&
          readTime == other.readTime &&
          isExpertVerified == other.isExpertVerified &&
          isFeatured == other.isFeatured &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      category.hashCode ^
      imageUrl.hashCode ^
      readTime.hashCode ^
      isExpertVerified.hashCode ^
      isFeatured.hashCode ^
      createdAt.hashCode;
}
