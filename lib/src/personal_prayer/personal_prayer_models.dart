import "dart:convert";

import "package:flutter/material.dart";

class PrayerCalendarEvent {
  const PrayerCalendarEvent({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.title,
    required this.details,
    required this.createdAt,
  });

  factory PrayerCalendarEvent.fromJson(Map<String, dynamic> json) {
    final DateTime fallbackDate = DateTime.parse(
      (json["startDate"] ?? json["date"]) as String,
    );
    return PrayerCalendarEvent(
      id: json["id"] as String,
      startDate: fallbackDate,
      endDate: DateTime.parse(
        (json["endDate"] ?? json["date"] ?? json["startDate"]) as String,
      ),
      title: json["title"] as String? ?? "",
      details: json["details"] as String? ?? "",
      createdAt: DateTime.parse(json["createdAt"] as String),
    );
  }

  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String title;
  final String details;
  final DateTime createdAt;

  DateTimeRange get range => DateTimeRange(start: startDate, end: endDate);

  bool includesDay(DateTime day) {
    final DateTime dateOnly = _dateOnly(day);
    return !dateOnly.isBefore(startDate) && !dateOnly.isAfter(endDate);
  }

  bool overlaps(DateTimeRange targetRange) {
    return !endDate.isBefore(_dateOnly(targetRange.start)) &&
        !startDate.isAfter(_dateOnly(targetRange.end));
  }

  PrayerCalendarEvent copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    String? title,
    String? details,
    DateTime? createdAt,
  }) {
    return PrayerCalendarEvent(
      id: id ?? this.id,
      startDate: _dateOnly(startDate ?? this.startDate),
      endDate: _dateOnly(endDate ?? this.endDate),
      title: title ?? this.title,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": id,
      "startDate": _dateOnly(startDate).toIso8601String(),
      "endDate": _dateOnly(endDate).toIso8601String(),
      "title": title,
      "details": details,
      "createdAt": createdAt.toIso8601String(),
    };
  }
}

class PrayerReflectionEntry {
  const PrayerReflectionEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.body,
    required this.createdAt,
    this.linkedEventId,
  });

  factory PrayerReflectionEntry.fromJson(Map<String, dynamic> json) {
    return PrayerReflectionEntry(
      id: json["id"] as String,
      date: DateTime.parse(json["date"] as String),
      title: json["title"] as String? ?? "",
      body: json["body"] as String? ?? "",
      createdAt: DateTime.parse(json["createdAt"] as String),
      linkedEventId: json["linkedEventId"] as String?,
    );
  }

  final String id;
  final DateTime date;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? linkedEventId;

  bool get isLinkedToEvent => linkedEventId != null && linkedEventId!.isNotEmpty;

  PrayerReflectionEntry copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? body,
    DateTime? createdAt,
    String? linkedEventId,
    bool clearLinkedEventId = false,
  }) {
    return PrayerReflectionEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      linkedEventId: clearLinkedEventId
          ? null
          : (linkedEventId ?? this.linkedEventId),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": id,
      "date": _dateOnly(date).toIso8601String(),
      "title": title,
      "body": body,
      "createdAt": createdAt.toIso8601String(),
      "linkedEventId": linkedEventId,
    };
  }
}

class PersonalPrayerSnapshot {
  const PersonalPrayerSnapshot({
    required this.events,
    required this.reflections,
  });

  factory PersonalPrayerSnapshot.empty() {
    return const PersonalPrayerSnapshot(
      events: <PrayerCalendarEvent>[],
      reflections: <PrayerReflectionEntry>[],
    );
  }

  factory PersonalPrayerSnapshot.fromStorage(String raw) {
    final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
    final List<dynamic> events = json["events"] as List<dynamic>? ?? <dynamic>[];
    final List<dynamic> reflections =
        json["reflections"] as List<dynamic>? ?? <dynamic>[];

    return PersonalPrayerSnapshot(
      events: events
          .whereType<Map<String, dynamic>>()
          .map(PrayerCalendarEvent.fromJson)
          .toList(growable: false),
      reflections: reflections
          .whereType<Map<String, dynamic>>()
          .map(PrayerReflectionEntry.fromJson)
          .toList(growable: false),
    );
  }

  final List<PrayerCalendarEvent> events;
  final List<PrayerReflectionEntry> reflections;

  String toStorage() {
    return jsonEncode(<String, dynamic>{
      "events": events.map((PrayerCalendarEvent item) => item.toJson()).toList(),
      "reflections": reflections
          .map((PrayerReflectionEntry item) => item.toJson())
          .toList(),
    });
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
