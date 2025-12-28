import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../calendar.dart';

/// Signature for callback that reports that the [CalendarController] properties
/// changed.
typedef CalendarValueChangedCallback = void Function(String);

/// Signature for callback that gets the calendar details by using the
/// [getCalendarDetailsAtOffset] function.
typedef CalendarDetailsCallback = CalendarDetails? Function(Offset position, Offset? localOffset);

/// Notifier used to notify the when the objects properties changed.
class CalendarValueChangedNotifier with Diagnosticable {
  List<CalendarValueChangedCallback>? _listeners;

  /// Calls the listener every time the controller's property changed.
  ///
  /// Listeners can be removed with [removePropertyChangedListener].
  void addPropertyChangedListener(CalendarValueChangedCallback listener) {
    _listeners ??= <CalendarValueChangedCallback>[];
    _listeners!.add(listener);
  }

  /// remove the listener used for notify the data source changes.
  ///
  /// Stop calling the listener every time in controller's property changed.
  ///
  /// If `listener` is not currently registered as a listener, this method does
  /// nothing.
  ///
  /// Listeners can be added with [addPropertyChangedListener].
  void removePropertyChangedListener(CalendarValueChangedCallback listener) {
    if (_listeners == null) {
      return;
    }

    _listeners!.remove(listener);
  }

  /// Call all the registered listeners.
  ///
  /// Call this method whenever the object changes, to notify any clients the
  /// object may have. Listeners that are added during this iteration will not
  /// be visited. Listeners that are removed during this iteration will not be
  /// visited after they are removed.
  ///
  /// This method must not be called after [dispose] has been called.
  ///
  /// Surprising behavior can result when reentrantly removing a listener (i.e.
  /// in response to a notification) that has been registered multiple times.
  /// See the discussion at [removePropertyChangedListener].
  void notifyPropertyChangedListeners(String property) {
    if (_listeners == null) {
      return;
    }

    for (final CalendarValueChangedCallback listener in _listeners!) {
      listener(property);
    }
  }

  /// Discards any resources used by the object. After this is called, the
  /// object is not in a usable state and should be discarded (calls to
  /// [addListener] and [removeListener] will throw after the object is
  /// disposed).
  ///
  /// This method should only be called by the object's owner.
  @mustCallSuper
  void dispose() {
    _listeners = null;
  }
}

/// An object that used for programmatic date navigation and date selection
/// in [SfCalendar].
///
/// A [CalendarController] served for several purposes. It can be used
/// to selected dates programmatically on [SfCalendar] by using the
/// [selectedDate]. It can be used to navigate to specific date
/// by using the [displayDate] property.
///
/// ## Listening to property changes:
/// The [CalendarController] is a listenable. It notifies it's listeners
/// whenever any of attached [SfCalendar]`s selected date, display date
/// changed (i.e: selecting a different date, swiping to next/previous
/// view] in in [SfCalendar].
///
/// ## Navigates to different view:
/// In [SfCalendar] the visible view can be navigated programmatically by
/// using the [forward] and [backward] method.
///
/// ## Programmatic selection:
/// In [SfCalendar] selecting dates programmatically can be achieved by
/// using the [selectedDate] which allows to select date on
/// [SfCalendar] on initial load and in run time.
///
/// The [CalendarController] can be listened by adding a listener to the
/// controller, the listener will listen and notify whenever the selected date,
/// display date changed in the [SfCalendar].
///
/// This example demonstrates how to use the [CalendarController] for
/// [SfCalendar].
///
/// ```dart
///
/// class MyAppState extends State<MyApp>{
///
///  CalendarController _calendarController = CalendarController();
///  @override
///  initState(){
///    _calendarController.selectedDate = DateTime(2022, 02, 05);
///    _calendarController.displayDate = DateTime(2022, 02, 05);
///    super.initState();
///  }
///
///  @override
///  Widget build(BuildContext context) {
///    return MaterialApp(
///      home: Scaffold(
///        body: SfCalendar(
///          view: CalendarView.month,
///          controller: _calendarController,
///        ),
///      ),
///    );
///  }
///}
/// ```
class CalendarController extends CalendarValueChangedNotifier {
  DateTime? _selectedDate;
  DateTime? _displayDate;
  CalendarView? _view;
  DateTime? _tappedDate;

  void setProperties({DateTime? selectedDate, DateTime? tappedDate, DateTime? displayDate, CalendarView? view, String? changeKey}) {
    bool isChanged = false;
    if (selectedDate != null) {
      _selectedDate = selectedDate;
      isChanged = true;
    }
    if (tappedDate != null) {
      _tappedDate = tappedDate;
      isChanged = true;
    }
    if (displayDate != null) {
      _displayDate = displayDate;
      isChanged = true;
    }

    if (view != null && _view != view) {
      _view = view;
      isChanged = true;
    }

    if (selectedDate == null && tappedDate == null && displayDate == null && view == null) return;
    if (!isChanged) return;
    notifyPropertyChangedListeners(changeKey ?? 'update');
  }

  DateTime? get selectedDate => _selectedDate;

  DateTime? get tappedDate => _tappedDate;

  DateTime? get displayDate => _displayDate;

  CalendarView? get view => _view;

  VoidCallback? forward;
  CalendarDetailsCallback? getCalendarDetailsAtOffset;
  DateTime? Function()? getCurrentTargetedDisplayDate;
  VoidCallback? backward;
  VoidCallback? hideCreateShadow;
  List<DateTime> Function()? getCurrentVisibleDates;
  void Function(bool isTask)? updateIsTask;
  void Function(String? title)? updateTitle;
  void Function(double? offset)? onControlScrollWheel;
  void Function(Color? color)? updateColor;
  void Function(DateTime startTime, DateTime endTime, bool isAllDay)? updateDate;
  void Function(DateTime startTime, DateTime endTime, bool isAllDay, Offset offset, Function(Rect anchorOffset) onCreated)? showCreateShadow;
  void Function(Offset offset, Duration duration, Color color, Function(Rect anchorOffset) onCreated, String? title)? showDragInboxShadow;

  void Function()? endDragInboxShadow;
  double? Function()? getCurrentScrollPositionRatio;
  void Function(double ratio)? setCurrentScrollPositionRatio;

  DateTime? Function()? getInboxDragDatetime;
  bool? Function()? getInboxDragIsAllDay;
  void Function(int minutes)? updateDuration;
  bool Function()? isAppointmentCreateViewVisible;
  Future<void> Function()? onRefresh;

  CalendarTapDetails? Function(String id, DateTime date)? getCalendarDetailsForId;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DateTime>('selectedDate', selectedDate));
    properties.add(DiagnosticsProperty<DateTime>('displayDate', displayDate));
    properties.add(EnumProperty<CalendarView>('view', view));
  }
}
