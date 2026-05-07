import 'package:flutter/foundation.dart';

@immutable
class KnowledgeArticle {
  final String id;
  final String title;
  final String content;
  final String category;
  final String? imageUrl;
  final String? readTime;
  final bool isExpertVerified;
  final bool isFeatured;
  final DateTime createdAt;

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

  factory KnowledgeArticle.fromJson(Map<String, dynamic> json) => KnowledgeArticle(
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
}
