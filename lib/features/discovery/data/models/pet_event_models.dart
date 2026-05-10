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
      description: json['description'] as String? ?? '',
      location: json['location'] as String?,
      eventDate: DateTime.parse(json['event_date'] as String).toLocal(),
      imageUrl: json['image_url'] as String?,
      eventType: json['event_type'] as String? ?? 'meetup',
      maxAttendees: (json['max_attendees'] as num?)?.toInt(),
      organizerId: json['organizer_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
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
}
