import "package:flutter/material.dart";

import "../../design/editorial_components.dart";
import "../../design/editorial_tokens.dart";
import "../../design/editorial_typography.dart";
import "../../localization/app_strings.dart";
import "../../personal_prayer/personal_prayer_controller.dart";
import "../../personal_prayer/personal_prayer_models.dart";

enum PersonalPrayerSection { calendar, reflections }

class PersonalPrayerScreen extends StatefulWidget {
  const PersonalPrayerScreen({
    super.key,
    required this.controller,
    required this.displayName,
  });

  final PersonalPrayerController controller;
  final String displayName;

  @override
  State<PersonalPrayerScreen> createState() => _PersonalPrayerScreenState();
}

class _PersonalPrayerScreenState extends State<PersonalPrayerScreen> {
  late DateTimeRange _selectedRange;
  late DateTime _visibleMonth;
  PersonalPrayerSection _section = PersonalPrayerSection.calendar;
  bool _didScheduleBootstrap = false;

  PersonalPrayerController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    final DateTime today = _dateOnly(DateTime.now());
    _selectedRange = DateTimeRange(start: today, end: today);
    _visibleMonth = DateTime(today.year, today.month);
    _scheduleBootstrap();
  }

  @override
  void didUpdateWidget(covariant PersonalPrayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _didScheduleBootstrap = false;
      _scheduleBootstrap();
    }
  }

  void _scheduleBootstrap() {
    if (_didScheduleBootstrap) {
      return;
    }

    _didScheduleBootstrap = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _controller.bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        if (_controller.isLoading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        return Stack(
          children: <Widget>[
            SafeArea(
              top: false,
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: EditorialCenteredViewport(
                      maxWidth: 620,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _NotebookHero(
                              displayName: widget.displayName,
                              section: _section,
                            ),
                            const SizedBox(height: 24),
                            _SectionToggle(
                              selected: _section,
                              onChanged: (PersonalPrayerSection nextSection) {
                                setState(() {
                                  _section = nextSection;
                                });
                              },
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_section == PersonalPrayerSection.calendar)
                    ..._buildCalendarSlivers()
                  else
                    ..._buildReflectionSlivers(),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
            Positioned(
              right: 24,
              bottom: 24,
              child: FloatingActionButton(
                backgroundColor: EditorialColors.primary,
                foregroundColor: EditorialColors.onPrimary,
                onPressed: _section == PersonalPrayerSection.calendar
                    ? _handleAddEvent
                    : _handleAddDailyReflection,
                child: Icon(
                  _section == PersonalPrayerSection.calendar
                      ? Icons.event_available_rounded
                      : Icons.add_rounded,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildCalendarSlivers() {
    final List<PrayerCalendarEvent> events = _controller.eventsForRange(
      _selectedRange,
    );
    final List<PrayerReflectionEntry> reflections = _controller
        .reflectionsForRange(_selectedRange);

    return <Widget>[
      SliverToBoxAdapter(
        child: EditorialCenteredViewport(
          maxWidth: 620,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _CalendarSheet(
              visibleMonth: _visibleMonth,
              selectedRange: _selectedRange,
              markerForDay: _controller.markerForDay,
              onSelectDate: _handleCalendarDateSelected,
              onPreviousMonth: () {
                setState(() {
                  _visibleMonth = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month - 1,
                  );
                });
              },
              onNextMonth: () {
                setState(() {
                  _visibleMonth = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month + 1,
                  );
                });
              },
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 28)),
      SliverToBoxAdapter(
        child: EditorialCenteredViewport(
          maxWidth: 620,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _SelectedDayPanel(
              selectedRange: _selectedRange,
              events: events,
              reflections: reflections,
              findEventById: _controller.findEventById,
              onAddEvent: _handleAddEvent,
              onAddPrayer: _handleAddPrayerForSelectedDay,
              onEditEvent: _handleEditEvent,
              onDeleteEvent: _handleDeleteEvent,
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 20)),
      const SliverToBoxAdapter(
        child: EditorialCenteredViewport(maxWidth: 620, child: FeedLikeQuote()),
      ),
    ];
  }

  List<Widget> _buildReflectionSlivers() {
    final List<PrayerReflectionEntry> reflections = _controller.reflections;

    if (reflections.isEmpty) {
      return <Widget>[
        SliverToBoxAdapter(
          child: EditorialCenteredViewport(
            maxWidth: 620,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _EmptyReflectionState(
                onAddDailyReflection: _handleAddDailyReflection,
                onOpenCalendar: () {
                  setState(() {
                    _section = PersonalPrayerSection.calendar;
                  });
                },
              ),
            ),
          ),
        ),
      ];
    }

    return <Widget>[
      SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          final PrayerReflectionEntry entry = reflections[index];
          final PrayerCalendarEvent? linkedEvent = _controller.findEventById(
            entry.linkedEventId,
          );
          final bool isLast = index == reflections.length - 1;

          return EditorialCenteredViewport(
            maxWidth: 620,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, isLast ? 0 : 12),
              child: _ReflectionCard(
                entry: entry,
                linkedEvent: linkedEvent,
                onEdit: () => _handleEditReflection(entry),
                onDelete: () => _handleDeleteReflection(entry),
              ),
            ),
          );
        }, childCount: reflections.length),
      ),
    ];
  }

  Future<void> _handleAddEvent() async {
    final AppStrings strings = context.strings;
    final _EventDraft? draft = await _showPersonalPrayerEventSheet(
      context,
      initialRange: _selectedRange,
    );
    if (draft == null) {
      return;
    }

    await _controller.addEvent(
      startDate: draft.startDate,
      endDate: draft.endDate,
      title: draft.title,
      details: draft.details,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedRange = draft.range;
      _visibleMonth = DateTime(draft.startDate.year, draft.startDate.month);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(strings.prayerEventAdded)));
  }

  Future<void> _handleAddPrayerForSelectedDay() async {
    await _openReflectionEditor(
      initialRange: _selectedRange,
      showEventOptions: true,
      successMessage: context.strings.prayerNoteSaved,
      nextSection: PersonalPrayerSection.reflections,
    );
  }

  Future<void> _handleAddDailyReflection() async {
    await _openReflectionEditor(
      initialRange: _selectedRange,
      showEventOptions: true,
      successMessage: context.strings.prayerReflectionAdded,
      nextSection: PersonalPrayerSection.reflections,
    );
  }

  Future<void> _handleEditEvent(PrayerCalendarEvent event) async {
    final AppStrings strings = context.strings;
    final _EventDraft? draft = await _showPersonalPrayerEventSheet(
      context,
      initialRange: event.range,
      initialEvent: event,
    );
    if (draft == null) {
      return;
    }

    await _controller.updateEvent(
      eventId: event.id,
      startDate: draft.startDate,
      endDate: draft.endDate,
      title: draft.title,
      details: draft.details,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedRange = draft.range;
      _visibleMonth = DateTime(draft.startDate.year, draft.startDate.month);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(strings.prayerEventUpdated)));
  }

  Future<void> _handleDeleteEvent(PrayerCalendarEvent event) async {
    final AppStrings strings = context.strings;
    final bool confirmed = await _showDeletePersonalPrayerItemDialog(
      context,
      title: strings.prayerDeleteEventTitle,
      body: strings.prayerDeleteEventBody,
    );
    if (!confirmed) {
      return;
    }

    await _controller.deleteEvent(event.id);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(strings.prayerEventDeleted)));
  }

  Future<void> _handleEditReflection(PrayerReflectionEntry entry) async {
    await _openReflectionEditor(
      initialRange: DateTimeRange(start: entry.date, end: entry.date),
      initialReflection: entry,
      showEventOptions: true,
      successMessage: context.strings.prayerNoteUpdated,
    );
  }

  Future<void> _handleDeleteReflection(PrayerReflectionEntry entry) async {
    final AppStrings strings = context.strings;
    final bool confirmed = await _showDeletePersonalPrayerItemDialog(
      context,
      title: strings.prayerDeleteNoteTitle,
      body: strings.prayerDeleteNoteBody,
    );
    if (!confirmed) {
      return;
    }

    await _controller.deleteReflection(entry.id);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(strings.prayerNoteDeleted)));
  }

  Future<void> _openReflectionEditor({
    required DateTimeRange initialRange,
    required bool showEventOptions,
    required String successMessage,
    PrayerReflectionEntry? initialReflection,
    PersonalPrayerSection? nextSection,
  }) async {
    final _ReflectionDraft? draft = await _showPersonalPrayerReflectionSheet(
      context,
      initialRange: initialRange,
      initialReflection: initialReflection,
      availableEvents: _controller.events,
      showEventOptions: showEventOptions,
    );
    if (draft == null) {
      return;
    }

    if (initialReflection == null) {
      await _controller.addReflection(
        date: draft.date,
        title: draft.title,
        body: draft.body,
        linkedEventId: draft.linkedEventId,
      );
    } else {
      await _controller.updateReflection(
        reflectionId: initialReflection.id,
        date: draft.date,
        title: draft.title,
        body: draft.body,
        linkedEventId: draft.linkedEventId,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedRange = draft.selectedRange;
      _visibleMonth = DateTime(draft.date.year, draft.date.month);
      if (nextSection != null) {
        _section = nextSection;
      }
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(successMessage)));
  }

  void _handleCalendarDateSelected(DateTime nextDate) {
    final DateTime normalizedDate = _dateOnly(nextDate);

    setState(() {
      final bool isSingleDaySelection = _isSameDay(
        _selectedRange.start,
        _selectedRange.end,
      );

      if (isSingleDaySelection &&
          !_isSameDay(normalizedDate, _selectedRange.start)) {
        final DateTime start = normalizedDate.isBefore(_selectedRange.start)
            ? normalizedDate
            : _selectedRange.start;
        final DateTime end = normalizedDate.isBefore(_selectedRange.start)
            ? _selectedRange.start
            : normalizedDate;
        _selectedRange = DateTimeRange(start: start, end: end);
      } else {
        _selectedRange = DateTimeRange(
          start: normalizedDate,
          end: normalizedDate,
        );
      }

      _visibleMonth = DateTime(normalizedDate.year, normalizedDate.month);
    });
  }
}

class _NotebookHero extends StatelessWidget {
  const _NotebookHero({required this.displayName, required this.section});

  final String displayName;
  final PersonalPrayerSection section;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;
    final String title = section == PersonalPrayerSection.calendar
        ? strings.prayerHeroCalendarTitle
        : strings.prayerHeroReflectionsTitle;
    final String body = section == PersonalPrayerSection.calendar
        ? strings.prayerHeroCalendarBody
        : strings.prayerHeroReflectionsBody;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style:
              _editorialContentStyle(
                context,
                Theme.of(context).textTheme.headlineMedium,
              )?.copyWith(
                color: EditorialColors.onSurface,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
                height: 1.15,
              ),
        ),
        const SizedBox(height: 14),
        Text(
          body,
          style: _editorialContentStyle(
            context,
            Theme.of(context).textTheme.bodyLarge,
          )?.copyWith(color: EditorialColors.onSurfaceMuted, height: 1.75),
        ),
        const SizedBox(height: 18),
        Text(
          "${displayName.toUpperCase()}  ${strings.prayerHeroNotebookSuffix}",
          style: _editorialLabelStyle(
            context,
            color: EditorialColors.outline,
            englishLetterSpacing: 1.4,
            koreanLetterSpacing: 0.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 26),
        const EditorialDivider(),
      ],
    );
  }
}

class _SectionToggle extends StatelessWidget {
  const _SectionToggle({required this.selected, required this.onChanged});

  final PersonalPrayerSection selected;
  final ValueChanged<PersonalPrayerSection> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;

    return Container(
      decoration: BoxDecoration(
        color: EditorialColors.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ToggleButton(
              icon: Icons.calendar_month_rounded,
              label: strings.prayerCalendar,
              selected: selected == PersonalPrayerSection.calendar,
              onTap: () => onChanged(PersonalPrayerSection.calendar),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              icon: Icons.auto_stories_rounded,
              label: strings.prayerReflections,
              selected: selected == PersonalPrayerSection.reflections,
              onTap: () => onChanged(PersonalPrayerSection.reflections),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? EditorialColors.surfaceLowest : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 18,
                color: selected
                    ? EditorialColors.onSurface
                    : EditorialColors.onSurfaceMuted,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? EditorialColors.onSurface
                      : EditorialColors.onSurfaceMuted,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarSheet extends StatelessWidget {
  const _CalendarSheet({
    required this.visibleMonth,
    required this.selectedRange,
    required this.markerForDay,
    required this.onSelectDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final DateTime visibleMonth;
  final DateTimeRange selectedRange;
  final PersonalPrayerDayMarker Function(DateTime day) markerForDay;
  final ValueChanged<DateTime> onSelectDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final List<DateTime> days = _buildVisibleMonthDays(visibleMonth);
    final AppStrings strings = context.strings;

    return EditorialSheet(
      tone: EditorialSheetTone.subtle,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      strings.prayerTimeline,
                      style: _editorialLabelStyle(
                        context,
                        color: EditorialColors.outline,
                        englishLetterSpacing: 1.4,
                        koreanLetterSpacing: 0.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatMonthYear(context, visibleMonth),
                      style:
                          _editorialContentStyle(
                            context,
                            Theme.of(context).textTheme.titleMedium,
                          )?.copyWith(
                            color: EditorialColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              IconButton(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: strings.weekdayLabels
                .map((String dayLabel) {
                  return Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          dayLabel,
                          style: _editorialLabelStyle(
                            context,
                            color: EditorialColors.outline,
                            englishLetterSpacing: 1.1,
                            koreanLetterSpacing: 0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                })
                .toList(growable: false),
          ),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              const int crossAxisCount = 7;
              const double gridSpacing = 8;
              final int rowCount = (days.length / crossAxisCount).ceil();
              final double cellExtent =
                  (constraints.maxWidth - (crossAxisCount - 1) * gridSpacing) /
                  crossAxisCount;
              final double gridHeight =
                  rowCount * cellExtent + (rowCount - 1) * gridSpacing;

              return SizedBox(
                height: gridHeight,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _CalendarRangeGapPainter(
                            days: days,
                            selectedRange: selectedRange,
                            cellExtent: cellExtent,
                            crossAxisCount: crossAxisCount,
                            gap: gridSpacing,
                            color: EditorialColors.surfaceContainer,
                          ),
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: days.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: gridSpacing,
                            crossAxisSpacing: gridSpacing,
                            childAspectRatio: 1,
                          ),
                      itemBuilder: (BuildContext context, int index) {
                        final DateTime day = days[index];
                        final bool isCurrentMonth =
                            day.month == visibleMonth.month;
                        final bool isRangeStart = _isSameDay(
                          day,
                          selectedRange.start,
                        );
                        final bool isRangeEnd = _isSameDay(
                          day,
                          selectedRange.end,
                        );
                        final bool isWithinRange =
                            !day.isBefore(selectedRange.start) &&
                            !day.isAfter(selectedRange.end);
                        final bool isSelected = isRangeStart || isRangeEnd;
                        final PersonalPrayerDayMarker marker = markerForDay(
                          day,
                        );
                        final Color backgroundColor = isSelected
                            ? EditorialColors.primary
                            : isWithinRange
                            ? EditorialColors.surfaceContainer
                            : isCurrentMonth
                            ? EditorialColors.surfaceLowest
                            : EditorialColors.surface.withValues(alpha: 0.24);
                        final Color foregroundColor = isSelected
                            ? EditorialColors.onPrimary
                            : isCurrentMonth
                            ? EditorialColors.onSurface
                            : EditorialColors.outlineVariant;
                        final Color indicatorColor = isSelected
                            ? EditorialColors.onPrimary.withValues(alpha: 0.72)
                            : EditorialColors.primary.withValues(alpha: 0.72);

                        return Material(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => onSelectDate(day),
                            child: LayoutBuilder(
                              builder:
                                  (
                                    BuildContext context,
                                    BoxConstraints constraints,
                                  ) {
                                    final double halfWidth =
                                        constraints.maxWidth / 2;
                                    const double connectorOverflow = 4;

                                    return Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        if (marker.hasMultiDayEvent)
                                          Positioned(
                                            left: marker.isMultiDayEventStart
                                                ? halfWidth
                                                : -connectorOverflow,
                                            right: marker.isMultiDayEventEnd
                                                ? halfWidth
                                                : -connectorOverflow,
                                            bottom: 11,
                                            height: 3,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: indicatorColor,
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                            ),
                                          ),
                                        if (marker.isMultiDayEventStart)
                                          Positioned(
                                            left: halfWidth - 6,
                                            bottom: 9,
                                            child: CustomPaint(
                                              size: const Size(6, 7),
                                              painter:
                                                  _RangeIndicatorCapPainter(
                                                    color: indicatorColor,
                                                    direction:
                                                        AxisDirection.left,
                                                  ),
                                            ),
                                          ),
                                        if (marker.isMultiDayEventEnd)
                                          Positioned(
                                            left: halfWidth,
                                            bottom: 9,
                                            child: CustomPaint(
                                              size: const Size(6, 7),
                                              painter:
                                                  _RangeIndicatorCapPainter(
                                                    color: indicatorColor,
                                                    direction:
                                                        AxisDirection.right,
                                                  ),
                                            ),
                                          ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              width: 32,
                                              height: 32,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? EditorialColors.primary
                                                    : Colors.transparent,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                "${day.day}",
                                                style: TextStyle(
                                                  color: foregroundColor,
                                                  fontWeight:
                                                      isSelected ||
                                                          isWithinRange
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            if (!marker.hasMultiDayEvent)
                                              Container(
                                                width: 5,
                                                height: 5,
                                                decoration: BoxDecoration(
                                                  color: marker.hasContent
                                                      ? indicatorColor
                                                      : Colors.transparent,
                                                  shape: BoxShape.circle,
                                                ),
                                              )
                                            else
                                              const SizedBox(height: 5),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SelectedDayPanel extends StatelessWidget {
  const _SelectedDayPanel({
    required this.selectedRange,
    required this.events,
    required this.reflections,
    required this.findEventById,
    required this.onAddEvent,
    required this.onAddPrayer,
    required this.onEditEvent,
    required this.onDeleteEvent,
  });

  final DateTimeRange selectedRange;
  final List<PrayerCalendarEvent> events;
  final List<PrayerReflectionEntry> reflections;
  final PrayerCalendarEvent? Function(String? id) findEventById;
  final VoidCallback onAddEvent;
  final VoidCallback onAddPrayer;
  final ValueChanged<PrayerCalendarEvent> onEditEvent;
  final ValueChanged<PrayerCalendarEvent> onDeleteEvent;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                _formatSelectedRange(context, selectedRange),
                style:
                    _editorialContentStyle(
                      context,
                      Theme.of(context).textTheme.titleLarge,
                    )?.copyWith(
                      color: EditorialColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Text(
              strings.selected,
              style: _editorialLabelStyle(
                context,
                color: EditorialColors.outline,
                englishLetterSpacing: 1.4,
                koreanLetterSpacing: 0.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: <Widget>[
            Expanded(
              child: EditorialSecondaryButton(
                label: strings.prayerAddEvent,
                icon: Icons.event_note_rounded,
                onPressed: onAddEvent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: EditorialSecondaryButton(
                label: strings.prayerNote,
                icon: Icons.auto_stories_rounded,
                onPressed: onAddPrayer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (events.isEmpty && reflections.isEmpty)
          EditorialSheet(
            padding: const EdgeInsets.all(24),
            child: Text(
              strings.prayerEmptyDay,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: EditorialColors.onSurfaceMuted,
                height: 1.75,
              ),
            ),
          )
        else
          Column(
            children: <Widget>[
              if (events.isNotEmpty)
                _DetailBlock(
                  title: strings.prayerEvents,
                  child: Column(
                    children: events
                        .map((PrayerCalendarEvent event) {
                          final List<PrayerReflectionEntry> linkedReflections =
                              reflections
                                  .where((PrayerReflectionEntry reflection) {
                                    return reflection.linkedEventId == event.id;
                                  })
                                  .toList(growable: false);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _EventCard(
                              event: event,
                              linkedReflectionCount: linkedReflections.length,
                              onEdit: () => onEditEvent(event),
                              onDelete: () => onDeleteEvent(event),
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
                ),
              if (reflections.isNotEmpty)
                _DetailBlock(
                  title: strings.prayerNotes,
                  child: Column(
                    children: reflections
                        .map((PrayerReflectionEntry entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _DailyReflectionSnippet(
                              entry: entry,
                              linkedEvent: findEventById(entry.linkedEventId),
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: _editorialLabelStyle(
              context,
              color: EditorialColors.outline,
              englishLetterSpacing: 1.4,
              koreanLetterSpacing: 0.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.linkedReflectionCount,
    required this.onEdit,
    required this.onDelete,
  });

  final PrayerCalendarEvent event;
  final int linkedReflectionCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;
    return EditorialSheet(
      tone: EditorialSheetTone.elevated,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: EditorialColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.event_rounded,
                  size: 20,
                  color: EditorialColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _formatEventRange(context, event),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: EditorialColors.outline,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: EditorialColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.details,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: EditorialColors.onSurfaceMuted,
                        height: 1.65,
                      ),
                    ),
                  ],
                ),
              ),
              _PersonalPrayerItemMenu(onEdit: onEdit, onDelete: onDelete),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            linkedReflectionCount == 0
                ? strings.prayerNoLinkedNotes
                : strings.prayerLinkedNotes(linkedReflectionCount),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: EditorialColors.onSurfaceMuted,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyReflectionSnippet extends StatelessWidget {
  const _DailyReflectionSnippet({
    required this.entry,
    required this.linkedEvent,
  });

  final PrayerReflectionEntry entry;
  final PrayerCalendarEvent? linkedEvent;

  @override
  Widget build(BuildContext context) {
    return EditorialSheet(
      tone: EditorialSheetTone.subtle,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  entry.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: EditorialColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (linkedEvent != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: EditorialColors.surfaceLowest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.event_rounded,
                        size: 13,
                        color: EditorialColors.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        linkedEvent!.title,
                        style: _editorialLabelStyle(
                          context,
                          color: EditorialColors.outline,
                          englishLetterSpacing: 0.2,
                          koreanLetterSpacing: 0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _preview(entry.body),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: EditorialColors.onSurfaceMuted,
              height: 1.75,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard({
    required this.entry,
    required this.linkedEvent,
    required this.onEdit,
    required this.onDelete,
  });

  final PrayerReflectionEntry entry;
  final PrayerCalendarEvent? linkedEvent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return EditorialSheet(
      tone: EditorialSheetTone.elevated,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: EditorialColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 20,
                  color: EditorialColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _formatShortDate(context, entry.date).toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: EditorialColors.outline,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: EditorialColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _PersonalPrayerItemMenu(onEdit: onEdit, onDelete: onDelete),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _preview(entry.body, maxLength: 180),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: EditorialColors.onSurfaceMuted,
              height: 1.75,
            ),
          ),
          if (linkedEvent != null) ...<Widget>[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: EditorialColors.surfaceLowest,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.event_rounded,
                    size: 14,
                    color: EditorialColors.outline,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      linkedEvent!.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: EditorialColors.outline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PersonalPrayerItemMenu extends StatelessWidget {
  const _PersonalPrayerItemMenu({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;

    return PopupMenuButton<String>(
      tooltip: strings.prayerMoreActions,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      color: EditorialColors.surfaceLowest,
      surfaceTintColor: Colors.transparent,
      padding: EdgeInsets.zero,
      onSelected: (String value) {
        if (value == "edit") {
          onEdit();
          return;
        }

        if (value == "delete") {
          onDelete();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(value: "edit", child: Text(strings.edit)),
        PopupMenuItem<String>(value: "delete", child: Text(strings.delete)),
      ],
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: EditorialColors.surfaceLowest,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.more_horiz,
          size: 18,
          color: EditorialColors.outline,
        ),
      ),
    );
  }
}

class _EmptyReflectionState extends StatelessWidget {
  const _EmptyReflectionState({
    required this.onAddDailyReflection,
    required this.onOpenCalendar,
  });

  final VoidCallback onAddDailyReflection;
  final VoidCallback onOpenCalendar;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;
    return EditorialSheet(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings.prayerEmptyNotebookTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: EditorialColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            strings.prayerEmptyNotebookBody,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: EditorialColors.onSurfaceMuted,
              height: 1.75,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: <Widget>[
              Expanded(
                child: EditorialSecondaryButton(
                  label: strings.prayerDailyReflection,
                  icon: Icons.edit_note_rounded,
                  onPressed: onAddDailyReflection,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: EditorialSecondaryButton(
                  label: strings.prayerOpenCalendar,
                  icon: Icons.calendar_month_rounded,
                  onPressed: onOpenCalendar,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FeedLikeQuote extends StatelessWidget {
  const FeedLikeQuote({super.key});

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 2,
            height: 78,
            color: EditorialColors.outlineVariant.withValues(alpha: 0.42),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  strings.prayerQuoteBody,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: EditorialColors.onSurfaceMuted,
                    fontStyle: FontStyle.italic,
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  strings.prayerQuoteReference,
                  style: _editorialLabelStyle(
                    context,
                    color: EditorialColors.outline,
                    englishLetterSpacing: 1.4,
                    koreanLetterSpacing: 0.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> _showDeletePersonalPrayerItemDialog(
  BuildContext context, {
  required String title,
  required String body,
}) async {
  final AppStrings strings = context.strings;
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: EditorialColors.surfaceLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: EditorialColors.onSurface,
          ),
        ),
        content: Text(
          body,
          style: const TextStyle(
            fontSize: 15,
            height: 1.6,
            color: EditorialColors.onSurfaceMuted,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: EditorialColors.onSurfaceMuted,
              side: const BorderSide(color: EditorialColors.outlineVariant),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: EditorialColors.primary,
              foregroundColor: EditorialColors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: Text(strings.delete),
          ),
        ],
      );
    },
  );

  return confirmed ?? false;
}

Future<_EventDraft?> _showPersonalPrayerEventSheet(
  BuildContext context, {
  required DateTimeRange initialRange,
  PrayerCalendarEvent? initialEvent,
}) {
  return showModalBottomSheet<_EventDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return _EventEditorSheet(
        initialRange: initialRange,
        initialEvent: initialEvent,
      );
    },
  );
}

Future<_ReflectionDraft?> _showPersonalPrayerReflectionSheet(
  BuildContext context, {
  required DateTimeRange initialRange,
  required List<PrayerCalendarEvent> availableEvents,
  bool showEventOptions = true,
  PrayerReflectionEntry? initialReflection,
}) {
  return showModalBottomSheet<_ReflectionDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return _ReflectionEditorSheet(
        initialRange: initialRange,
        availableEvents: availableEvents,
        showEventOptions: showEventOptions,
        initialReflection: initialReflection,
      );
    },
  );
}

class _EventEditorSheet extends StatefulWidget {
  const _EventEditorSheet({required this.initialRange, this.initialEvent});

  final DateTimeRange initialRange;
  final PrayerCalendarEvent? initialEvent;

  @override
  State<_EventEditorSheet> createState() => _EventEditorSheetState();
}

class _EventEditorSheetState extends State<_EventEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;
  late DateTimeRange _selectedRange;

  @override
  void initState() {
    super.initState();
    final PrayerCalendarEvent? initialEvent = widget.initialEvent;
    _titleController = TextEditingController(text: initialEvent?.title ?? "");
    _detailsController = TextEditingController(
      text: initialEvent?.details ?? "",
    );
    _selectedRange = initialEvent?.range ?? widget.initialRange;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final AppStrings strings = context.strings;
    final bool isEditing = widget.initialEvent != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: EditorialSheet(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              isEditing
                  ? strings.prayerEditPrayerEvent
                  : strings.prayerAddPrayerEvent,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            _SheetField(
              label: strings.prayerFieldDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: EditorialColors.surfaceLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _formatSelectedRange(context, _selectedRange),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: EditorialColors.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SheetField(
              label: strings.prayerFieldTitle,
              child: TextField(
                controller: _titleController,
                decoration: _sheetDecoration(strings.prayerEventTitleHint),
              ),
            ),
            const SizedBox(height: 12),
            _SheetField(
              label: strings.prayerFieldDetails,
              child: TextField(
                controller: _detailsController,
                minLines: 3,
                maxLines: 5,
                decoration: _sheetDecoration(strings.prayerEventDetailsHint),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: EditorialPrimaryButton(
                label: isEditing ? strings.edit : strings.prayerSaveEvent,
                onPressed: () {
                  final String title = _titleController.text.trim();
                  final String details = _detailsController.text.trim();
                  if (title.isEmpty || details.isEmpty) {
                    return;
                  }

                  Navigator.of(context).pop(
                    _EventDraft(
                      startDate: _selectedRange.start,
                      endDate: _selectedRange.end,
                      title: title,
                      details: details,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReflectionEditorSheet extends StatefulWidget {
  const _ReflectionEditorSheet({
    required this.initialRange,
    required this.availableEvents,
    required this.showEventOptions,
    this.initialReflection,
  });

  final DateTimeRange initialRange;
  final List<PrayerCalendarEvent> availableEvents;
  final bool showEventOptions;
  final PrayerReflectionEntry? initialReflection;

  @override
  State<_ReflectionEditorSheet> createState() => _ReflectionEditorSheetState();
}

class _ReflectionEditorSheetState extends State<_ReflectionEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late DateTimeRange _selectedRange;
  String? _linkedEventId;

  DateTime get _selectedDate => _selectedRange.end;

  @override
  void initState() {
    super.initState();
    final PrayerReflectionEntry? initialReflection = widget.initialReflection;
    _titleController = TextEditingController(
      text: initialReflection?.title ?? "",
    );
    _bodyController = TextEditingController(
      text: initialReflection?.body ?? "",
    );
    _selectedRange = initialReflection != null
        ? DateTimeRange(
            start: initialReflection.date,
            end: initialReflection.date,
          )
        : widget.initialRange;
    _linkedEventId =
        initialReflection?.linkedEventId ??
        (widget.availableEvents.isNotEmpty
            ? widget.availableEvents.first.id
            : null);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final AppStrings strings = context.strings;
    final bool isEditing = widget.initialReflection != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: EditorialSheet(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                isEditing
                    ? strings.prayerEditPrayerNote
                    : strings.prayerNewPrayerNote,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              _SheetField(
                label: strings.prayerFieldDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: EditorialColors.surfaceLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _formatSelectedRange(context, _selectedRange),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: EditorialColors.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _SheetField(
                label: strings.prayerFieldTitle,
                child: TextField(
                  controller: _titleController,
                  decoration: _sheetDecoration(strings.prayerNoteTitleHint),
                ),
              ),
              const SizedBox(height: 12),
              _SheetField(
                label: strings.prayerFieldPrayer,
                child: TextField(
                  controller: _bodyController,
                  minLines: 5,
                  maxLines: 8,
                  decoration: _sheetDecoration(strings.prayerNoteBodyHint),
                ),
              ),
              if (widget.showEventOptions) ...<Widget>[
                const SizedBox(height: 12),
                _SheetField(
                  label: strings.prayerFieldLinkEvent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: EditorialColors.surfaceLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _linkedEventId,
                        isExpanded: true,
                        hint: Text(strings.prayerDailyNoteOnly),
                        items: <DropdownMenuItem<String?>>[
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(strings.prayerDailyNoteOnly),
                          ),
                          ...widget.availableEvents.map(
                            (PrayerCalendarEvent event) =>
                                DropdownMenuItem<String?>(
                                  value: event.id,
                                  child: Text(event.title),
                                ),
                          ),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            _linkedEventId = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: EditorialPrimaryButton(
                  label: isEditing ? strings.edit : strings.prayerSaveNote,
                  onPressed: () {
                    final String title = _titleController.text.trim();
                    final String body = _bodyController.text.trim();
                    if (title.isEmpty || body.isEmpty) {
                      return;
                    }

                    Navigator.of(context).pop(
                      _ReflectionDraft(
                        date: _selectedDate,
                        selectedRange: _selectedRange,
                        title: title,
                        body: body,
                        linkedEventId: _linkedEventId,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: _editorialLabelStyle(
            context,
            color: EditorialColors.outline,
            englishLetterSpacing: 1.4,
            koreanLetterSpacing: 0.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

InputDecoration _sheetDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: EditorialColors.surfaceLow,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: EditorialColors.outline, width: 0.8),
    ),
  );
}

class _EventDraft {
  const _EventDraft({
    required this.startDate,
    required this.endDate,
    required this.title,
    required this.details,
  });

  final DateTime startDate;
  final DateTime endDate;
  final String title;
  final String details;

  DateTimeRange get range => DateTimeRange(start: startDate, end: endDate);
}

class _ReflectionDraft {
  const _ReflectionDraft({
    required this.date,
    required this.selectedRange,
    required this.title,
    required this.body,
    required this.linkedEventId,
  });

  final DateTime date;
  final DateTimeRange selectedRange;
  final String title;
  final String body;
  final String? linkedEventId;
}

TextStyle? _editorialContentStyle(BuildContext context, TextStyle? style) {
  if (style == null) {
    return null;
  }

  if (!context.strings.isKorean) {
    return style;
  }

  return EditorialTypography.withKoreanContent(style);
}

TextStyle? _editorialLabelStyle(
  BuildContext context, {
  required Color color,
  required double englishLetterSpacing,
  required double koreanLetterSpacing,
  required FontWeight fontWeight,
}) {
  final TextStyle? baseStyle = _editorialContentStyle(
    context,
    Theme.of(context).textTheme.labelSmall,
  );

  return baseStyle?.copyWith(
    color: color,
    letterSpacing: context.strings.isKorean
        ? koreanLetterSpacing
        : englishLetterSpacing,
    fontWeight: fontWeight,
  );
}

String _formatMonthYear(BuildContext context, DateTime date) {
  final AppStrings strings = context.strings;
  final String monthName = strings.monthNames[date.month - 1];

  if (strings.isKorean) {
    return "${date.year}\uB144 $monthName";
  }

  return "$monthName ${date.year}";
}

String _formatSelectedDay(BuildContext context, DateTime date) {
  final AppStrings strings = context.strings;
  final String monthName = strings.monthNames[date.month - 1];
  final String weekdayName = strings.weekdayNames[date.weekday - 1];

  if (strings.isKorean) {
    return "$monthName ${date.day}\uC77C $weekdayName";
  }

  return "$monthName ${date.day}, $weekdayName";
}

String _formatSelectedRange(BuildContext context, DateTimeRange range) {
  if (_isSameDay(range.start, range.end)) {
    return _formatSelectedDay(context, range.start);
  }

  return "${_formatShortDate(context, range.start)} - ${_formatShortDate(context, range.end)}";
}

String _formatShortDate(BuildContext context, DateTime date) {
  final AppStrings strings = context.strings;
  final String monthName = strings.monthNames[date.month - 1];

  if (strings.isKorean) {
    return "${date.year}\uB144 $monthName ${date.day}\uC77C";
  }

  final String shortMonth = monthName.substring(0, 3);
  return "$shortMonth ${date.day}, ${date.year}";
}

String _formatEventRange(BuildContext context, PrayerCalendarEvent event) {
  return _formatSelectedRange(context, event.range);
}

class _CalendarRangeGapPainter extends CustomPainter {
  const _CalendarRangeGapPainter({
    required this.days,
    required this.selectedRange,
    required this.cellExtent,
    required this.crossAxisCount,
    required this.gap,
    required this.color,
  });

  final List<DateTime> days;
  final DateTimeRange selectedRange;
  final double cellExtent;
  final int crossAxisCount;
  final double gap;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (days.length < 2) {
      return;
    }

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    const double highlightHeight = 36;

    for (int index = 1; index < days.length; index += 1) {
      if (index % crossAxisCount == 0) {
        continue;
      }

      final DateTime previousDay = days[index - 1];
      final DateTime currentDay = days[index];
      final bool previousWithinRange =
          !previousDay.isBefore(selectedRange.start) &&
          !previousDay.isAfter(selectedRange.end);
      final bool currentWithinRange =
          !currentDay.isBefore(selectedRange.start) &&
          !currentDay.isAfter(selectedRange.end);

      if (!previousWithinRange || !currentWithinRange) {
        continue;
      }

      final int row = index ~/ crossAxisCount;
      final int column = index % crossAxisCount;
      final double top =
          row * (cellExtent + gap) + ((cellExtent - highlightHeight) / 2);
      final double left = column * (cellExtent + gap) - gap;

      canvas.drawRect(Rect.fromLTWH(left, top, gap, highlightHeight), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CalendarRangeGapPainter oldDelegate) {
    return oldDelegate.days != days ||
        oldDelegate.selectedRange != selectedRange ||
        oldDelegate.cellExtent != cellExtent ||
        oldDelegate.crossAxisCount != crossAxisCount ||
        oldDelegate.gap != gap ||
        oldDelegate.color != color;
  }
}

class _RangeIndicatorCapPainter extends CustomPainter {
  const _RangeIndicatorCapPainter({
    required this.color,
    required this.direction,
  });

  final Color color;
  final AxisDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final Path path = Path();

    if (direction == AxisDirection.left) {
      path
        ..moveTo(size.width, 0)
        ..lineTo(0, size.height / 2)
        ..lineTo(size.width, size.height)
        ..close();
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, size.height / 2)
        ..lineTo(0, size.height)
        ..close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RangeIndicatorCapPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.direction != direction;
  }
}

String _preview(String text, {int maxLength = 120}) {
  final String normalized = text.trim().replaceAll(RegExp(r"\s+"), " ");
  if (normalized.length <= maxLength) {
    return normalized;
  }

  return "${normalized.substring(0, maxLength).trimRight()}...";
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool _isSameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

List<DateTime> _buildVisibleMonthDays(DateTime month) {
  final DateTime firstOfMonth = DateTime(month.year, month.month, 1);
  final DateTime start = firstOfMonth.subtract(
    Duration(days: firstOfMonth.weekday - 1),
  );

  return List<DateTime>.generate(42, (int index) {
    final DateTime day = start.add(Duration(days: index));
    return DateTime(day.year, day.month, day.day);
  });
}
