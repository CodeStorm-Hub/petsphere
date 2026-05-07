class PetEvent {
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
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      location: json['location'],
      eventDate: DateTime.parse(json['event_date']),
      imageUrl: json['image_url'],
      eventType: json['event_type'] ?? 'meetup',
      maxAttendees: json['max_attendees'],
      organizerId: json['organizer_id'],
      isActive: json['is_active'] ?? true,
    );
  }

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
