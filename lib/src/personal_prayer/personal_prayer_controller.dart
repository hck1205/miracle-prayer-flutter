import "package:flutter/material.dart";

import "personal_prayer_models.dart";
import "personal_prayer_storage.dart";

class PersonalPrayerController extends ChangeNotifier {
  PersonalPrayerController({
    required String userId,
    PersonalPrayerStorage? storage,
  }) : _userId = userId,
       _storage = storage ?? const PersonalPrayerStorage();

  final String _userId;
  final PersonalPrayerStorage _storage;

  bool _isLoading = false;
  bool _didBootstrap = false;
  bool _isDisposed = false;
  List<PrayerCalendarEvent> _events = const <PrayerCalendarEvent>[];
  List<PrayerReflectionEntry> _reflections = const <PrayerReflectionEntry>[];
  Map<int, List<PrayerCalendarEvent>> _eventsByDay =
      const <int, List<PrayerCalendarEvent>>{};
  Map<int, List<PrayerReflectionEntry>> _reflectionsByDay =
      const <int, List<PrayerReflectionEntry>>{};
  Map<int, PersonalPrayerDayMarker> _dayMarkersByKey =
      const <int, PersonalPrayerDayMarker>{};
  Map<String, PrayerCalendarEvent> _eventsById =
      const <String, PrayerCalendarEvent>{};
  Set<int> _contentDayKeys = const <int>{};

  bool get isLoading => _isLoading;
  List<PrayerCalendarEvent> get events => _events;
  List<PrayerReflectionEntry> get reflections => _reflections;

  Future<void> bootstrap() async {
    if (_didBootstrap) {
      return;
    }

    _didBootstrap = true;
    _setLoading(true);

    try {
      final PersonalPrayerSnapshot snapshot = await _storage.read(_userId);
      if (_isDisposed) {
        return;
      }

      _replaceData(
        events: _sortEvents(snapshot.events),
        reflections: _sortReflections(snapshot.reflections),
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  List<PrayerCalendarEvent> eventsForDay(DateTime day) {
    return _eventsByDay[_dayKey(day)] ?? const <PrayerCalendarEvent>[];
  }

  List<PrayerCalendarEvent> eventsForRange(DateTimeRange range) {
    if (_isSameDay(range.start, range.end)) {
      return eventsForDay(range.start);
    }

    final Map<String, PrayerCalendarEvent> result =
        <String, PrayerCalendarEvent>{};
    DateTime cursor = _dateOnly(range.start);
    final DateTime end = _dateOnly(range.end);

    while (!cursor.isAfter(end)) {
      for (final PrayerCalendarEvent event in eventsForDay(cursor)) {
        result.putIfAbsent(event.id, () => event);
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    return _sortEvents(result.values.toList(growable: false));
  }

  List<PrayerReflectionEntry> reflectionsForDay(DateTime day) {
    return _reflectionsByDay[_dayKey(day)] ?? const <PrayerReflectionEntry>[];
  }

  List<PrayerReflectionEntry> reflectionsForRange(DateTimeRange range) {
    if (_isSameDay(range.start, range.end)) {
      return reflectionsForDay(range.start);
    }

    final Map<String, PrayerReflectionEntry> result =
        <String, PrayerReflectionEntry>{};
    DateTime cursor = _dateOnly(range.start);
    final DateTime end = _dateOnly(range.end);

    while (!cursor.isAfter(end)) {
      for (final PrayerReflectionEntry entry in reflectionsForDay(cursor)) {
        result.putIfAbsent(entry.id, () => entry);
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    return _sortReflections(result.values.toList(growable: false));
  }

  List<PrayerReflectionEntry> reflectionsForEvent(String eventId) {
    return _reflections.where((PrayerReflectionEntry entry) {
      return entry.linkedEventId == eventId;
    }).toList(growable: false);
  }

  PrayerCalendarEvent? findEventById(String? eventId) {
    if (eventId == null || eventId.isEmpty) {
      return null;
    }

    return _eventsById[eventId];
  }

  bool hasContentForDay(DateTime day) {
    return _contentDayKeys.contains(_dayKey(day));
  }

  PersonalPrayerDayMarker markerForDay(DateTime day) {
    return _dayMarkersByKey[_dayKey(day)] ?? PersonalPrayerDayMarker.empty;
  }

  Future<void> addEvent({
    required DateTime startDate,
    required DateTime endDate,
    required String title,
    required String details,
  }) async {
    final DateTime now = DateTime.now();
    final PrayerCalendarEvent event = PrayerCalendarEvent(
      id: now.microsecondsSinceEpoch.toString(),
      startDate: DateTime(startDate.year, startDate.month, startDate.day),
      endDate: DateTime(endDate.year, endDate.month, endDate.day),
      title: title.trim(),
      details: details.trim(),
      createdAt: now,
    );

    _replaceData(
      events: _sortEvents(<PrayerCalendarEvent>[event, ..._events]),
      reflections: _reflections,
    );
    notifyListeners();
    await _persist();
  }

  Future<void> addReflection({
    required DateTime date,
    required String title,
    required String body,
    String? linkedEventId,
  }) async {
    final DateTime now = DateTime.now();
    final PrayerReflectionEntry reflection = PrayerReflectionEntry(
      id: now.microsecondsSinceEpoch.toString(),
      date: DateTime(date.year, date.month, date.day),
      title: title.trim(),
      body: body.trim(),
      createdAt: now,
      linkedEventId: linkedEventId?.trim().isEmpty ?? true
          ? null
          : linkedEventId?.trim(),
    );

    _replaceData(
      events: _events,
      reflections: _sortReflections(
        <PrayerReflectionEntry>[reflection, ..._reflections],
      ),
    );
    notifyListeners();
    await _persist();
  }

  Future<void> updateEvent({
    required String eventId,
    required DateTime startDate,
    required DateTime endDate,
    required String title,
    required String details,
  }) async {
    _replaceData(
      events: _sortEvents(
        _events.map((PrayerCalendarEvent event) {
          if (event.id != eventId) {
            return event;
          }

          return event.copyWith(
            startDate: DateTime(startDate.year, startDate.month, startDate.day),
            endDate: DateTime(endDate.year, endDate.month, endDate.day),
            title: title.trim(),
            details: details.trim(),
          );
        }).toList(growable: false),
      ),
      reflections: _reflections,
    );
    notifyListeners();
    await _persist();
  }

  Future<void> deleteEvent(String eventId) async {
    _replaceData(
      events: _events
          .where((PrayerCalendarEvent event) => event.id != eventId)
          .toList(growable: false),
      reflections: _reflections.map((PrayerReflectionEntry entry) {
        if (entry.linkedEventId != eventId) {
          return entry;
        }

        return entry.copyWith(clearLinkedEventId: true);
      }).toList(growable: false),
    );
    notifyListeners();
    await _persist();
  }

  Future<void> updateReflection({
    required String reflectionId,
    required DateTime date,
    required String title,
    required String body,
    required String? linkedEventId,
  }) async {
    _replaceData(
      events: _events,
      reflections: _sortReflections(
        _reflections.map((PrayerReflectionEntry entry) {
          if (entry.id != reflectionId) {
            return entry;
          }

          return entry.copyWith(
            date: DateTime(date.year, date.month, date.day),
            title: title.trim(),
            body: body.trim(),
            linkedEventId: linkedEventId?.trim().isEmpty ?? true
                ? null
                : linkedEventId?.trim(),
            clearLinkedEventId: linkedEventId?.trim().isEmpty ?? true,
          );
        }).toList(growable: false),
      ),
    );
    notifyListeners();
    await _persist();
  }

  Future<void> deleteReflection(String reflectionId) async {
    _replaceData(
      events: _events,
      reflections: _reflections
          .where((PrayerReflectionEntry entry) => entry.id != reflectionId)
          .toList(growable: false),
    );
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() {
    return _storage.write(
      _userId,
      PersonalPrayerSnapshot(events: _events, reflections: _reflections),
    );
  }

  void _setLoading(bool nextValue) {
    if (_isDisposed || _isLoading == nextValue) {
      return;
    }

    _isLoading = nextValue;
    notifyListeners();
  }

  List<PrayerCalendarEvent> _sortEvents(List<PrayerCalendarEvent> items) {
    final List<PrayerCalendarEvent> nextItems = List<PrayerCalendarEvent>.of(
      items,
    );
    nextItems.sort((PrayerCalendarEvent a, PrayerCalendarEvent b) {
      final int dateCompare = b.startDate.compareTo(a.startDate);
      if (dateCompare != 0) {
        return dateCompare;
      }

      return b.createdAt.compareTo(a.createdAt);
    });
    return nextItems;
  }

  List<PrayerReflectionEntry> _sortReflections(
    List<PrayerReflectionEntry> items,
  ) {
    final List<PrayerReflectionEntry> nextItems =
        List<PrayerReflectionEntry>.of(items);
    nextItems.sort((PrayerReflectionEntry a, PrayerReflectionEntry b) {
      final int dateCompare = b.date.compareTo(a.date);
      if (dateCompare != 0) {
        return dateCompare;
      }

      return b.createdAt.compareTo(a.createdAt);
    });
    return nextItems;
  }

  void _replaceData({
    required List<PrayerCalendarEvent> events,
    required List<PrayerReflectionEntry> reflections,
  }) {
    _events = events;
    _reflections = reflections;
    _eventsByDay = _indexEventsByDay(events);
    _reflectionsByDay = _indexReflectionsByDay(reflections);
    _dayMarkersByKey = _buildDayMarkers(
      events: events,
      reflections: reflections,
    );
    _eventsById = <String, PrayerCalendarEvent>{
      for (final PrayerCalendarEvent event in events) event.id: event,
    };
    _contentDayKeys = <int>{
      ..._eventsByDay.keys,
      ..._reflectionsByDay.keys,
    };
  }

  Map<int, List<PrayerCalendarEvent>> _indexEventsByDay(
    List<PrayerCalendarEvent> events,
  ) {
    final Map<int, List<PrayerCalendarEvent>> result =
        <int, List<PrayerCalendarEvent>>{};

    for (final PrayerCalendarEvent event in events) {
      DateTime cursor = event.startDate;
      while (!cursor.isAfter(event.endDate)) {
        final List<PrayerCalendarEvent> items = result.putIfAbsent(
          _dayKey(cursor),
          () => <PrayerCalendarEvent>[],
        );
        items.add(event);
        cursor = cursor.add(const Duration(days: 1));
      }
    }

    return result;
  }

  Map<int, List<PrayerReflectionEntry>> _indexReflectionsByDay(
    List<PrayerReflectionEntry> reflections,
  ) {
    final Map<int, List<PrayerReflectionEntry>> result =
        <int, List<PrayerReflectionEntry>>{};

    for (final PrayerReflectionEntry reflection in reflections) {
      final List<PrayerReflectionEntry> items = result.putIfAbsent(
        _dayKey(reflection.date),
        () => <PrayerReflectionEntry>[],
      );
      items.add(reflection);
    }

    return result;
  }

  Map<int, PersonalPrayerDayMarker> _buildDayMarkers({
    required List<PrayerCalendarEvent> events,
    required List<PrayerReflectionEntry> reflections,
  }) {
    final Map<int, _MutablePersonalPrayerDayMarker> markers =
        <int, _MutablePersonalPrayerDayMarker>{};

    for (final PrayerCalendarEvent event in events) {
      final bool isMultiDayEvent = !_isSameDay(event.startDate, event.endDate);
      DateTime cursor = event.startDate;

      while (!cursor.isAfter(event.endDate)) {
        final _MutablePersonalPrayerDayMarker marker = markers.putIfAbsent(
          _dayKey(cursor),
          _MutablePersonalPrayerDayMarker.new,
        );
        marker.hasContent = true;

        if (isMultiDayEvent) {
          marker.hasMultiDayEvent = true;
          if (_isSameDay(cursor, event.startDate)) {
            marker.isMultiDayEventStart = true;
          }
          if (_isSameDay(cursor, event.endDate)) {
            marker.isMultiDayEventEnd = true;
          }
        }

        cursor = cursor.add(const Duration(days: 1));
      }
    }

    for (final PrayerReflectionEntry reflection in reflections) {
      final _MutablePersonalPrayerDayMarker marker = markers.putIfAbsent(
        _dayKey(reflection.date),
        _MutablePersonalPrayerDayMarker.new,
      );
      marker.hasContent = true;
    }

    return <int, PersonalPrayerDayMarker>{
      for (final MapEntry<int, _MutablePersonalPrayerDayMarker> entry
          in markers.entries)
        entry.key: entry.value.freeze(),
    };
  }

  int _dayKey(DateTime value) => value.year * 10000 + value.month * 100 + value.day;

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

class PersonalPrayerDayMarker {
  const PersonalPrayerDayMarker({
    required this.hasContent,
    required this.hasMultiDayEvent,
    required this.isMultiDayEventStart,
    required this.isMultiDayEventEnd,
  });

  static const PersonalPrayerDayMarker empty = PersonalPrayerDayMarker(
    hasContent: false,
    hasMultiDayEvent: false,
    isMultiDayEventStart: false,
    isMultiDayEventEnd: false,
  );

  final bool hasContent;
  final bool hasMultiDayEvent;
  final bool isMultiDayEventStart;
  final bool isMultiDayEventEnd;
}

class _MutablePersonalPrayerDayMarker {
  bool hasContent = false;
  bool hasMultiDayEvent = false;
  bool isMultiDayEventStart = false;
  bool isMultiDayEventEnd = false;

  PersonalPrayerDayMarker freeze() {
    return PersonalPrayerDayMarker(
      hasContent: hasContent,
      hasMultiDayEvent: hasMultiDayEvent,
      isMultiDayEventStart: isMultiDayEventStart,
      isMultiDayEventEnd: isMultiDayEventEnd,
    );
  }
}
