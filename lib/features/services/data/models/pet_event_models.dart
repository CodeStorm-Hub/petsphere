class PetEvent {

  PetEvent({
    required this.id,
    required this.title,
    required this.description,
    this.location,
    required this.eventDate,
    this.imageUrl,
    required this.eventType,
    this.maxAttendees,
    this.organizerId,
    this.isActive = true,
  });

  factory PetEvent.fromJson(Map<String, dynamic> json) {
    return PetEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      location: json['location'] as String?,
      eventDate: DateTime.parse(json['event_date'] as String),
      imageUrl: json['image_url'] as String?,
      eventType: (json['event_type'] as String?) ?? 'meetup',
      maxAttendees: json['max_attendees'] as int?,
      organizerId: json['organizer_id'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
    );
  }
  final String id;
  final String title;
  final String description;
  final String? location;
  final DateTime eventDate;
  final String? imageUrl;
  final String eventType; // 'meetup', 'workshop', 'show', 'charity'
  final int? maxAttendees;
  final String? organizerId;
  final bool isActive;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'event_date': eventDate.toIso8601String(),
      'image_url': imageUrl,
      'event_type': eventType,
      'max_attendees': maxAttendees,
      'organizer_id': organizerId,
      'is_active': isActive,
    };
  }

  PetEvent copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    DateTime? eventDate,
    String? imageUrl,
    String? eventType,
    int? maxAttendees,
    String? organizerId,
    bool? isActive,
  }) {
    return PetEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      eventDate: eventDate ?? this.eventDate,
      imageUrl: imageUrl ?? this.imageUrl,
      eventType: eventType ?? this.eventType,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      organizerId: organizerId ?? this.organizerId,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          location == other.location &&
          eventDate == other.eventDate &&
          imageUrl == other.imageUrl &&
          eventType == other.eventType &&
          maxAttendees == other.maxAttendees &&
          organizerId == other.organizerId &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      location.hashCode ^
      eventDate.hashCode ^
      imageUrl.hashCode ^
      eventType.hashCode ^
      maxAttendees.hashCode ^
      organizerId.hashCode ^
      isActive.hashCode;
}
