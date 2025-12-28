import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Extension that allows to substitute [DateTime.now] with a testable function
extension DateTimeX on DateTime {
  /// Allows copying [DateTime] with an arbitrary shift in time
  DateTime copyWith({int? year, int? month, int? day, int? hour, int? minute, int? second, int? millisecond, int? microsecond}) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }

  /// Default [DateTime] format to be used on the UI
  String defaultString() {
    return DateFormat.yMMMd().format(this);
  }

  DateTime roundDown({Duration delta = const Duration(seconds: 15)}) {
    return DateTime.fromMillisecondsSinceEpoch(this.millisecondsSinceEpoch - this.millisecondsSinceEpoch % delta.inMilliseconds);
  }

  DateTime roundUp({Duration delta = const Duration(seconds: 15)}) {
    return DateTime.fromMillisecondsSinceEpoch(this.millisecondsSinceEpoch - this.millisecondsSinceEpoch % delta.inMilliseconds + delta.inMilliseconds);
    // (this.millisecondsSinceEpoch % delta.inMilliseconds == 0
    //     ? this.millisecondsSinceEpoch % delta.inMilliseconds
    //     : this.millisecondsSinceEpoch % delta.inMilliseconds - delta.inMilliseconds));
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  static DateTime? _customTime;

  /// Method that allows to get current [DateTime] in runtime or custom [DateTime] in tests
  static DateTime get current {
    return _customTime ?? DateTime.now();
  }

  @visibleForTesting
  static set customTime(DateTime? customTime) {
    _customTime = customTime;
  }

  String get timeString {
    if (this.minute == 0) return DateFormat('h a').format(this);
    return DateFormat('h:mm a').format(this);
  }

  String get dateString {
    if (DateUtils.isSameDay(DateTime.now(), this)) return timeString;
    if (DateUtils.isSameDay(DateTime.now().subtract(Duration(days: 1)), this)) return Utils.mainContext.tr.yesterday;
    if (this.year == DateTime.now().year) return DateFormat.MMMd().format(this);
    return DateFormat.yMMMd().format(this);
  }

  String get forceDateString {
    if (DateUtils.isSameDay(DateTime.now(), this)) return Utils.mainContext.tr.today;
    if (DateUtils.isSameDay(DateTime.now().subtract(Duration(days: 1)), this)) return Utils.mainContext.tr.yesterday;
    if (this.year == DateTime.now().year) return DateFormat.MMMd().format(this);
    return DateFormat.yMMMd().format(this);
  }

  String get dateTimeString {
    if (DateUtils.isSameDay(DateTime.now(), this)) return timeString;
    return dateString + ' • ' + timeString;
  }

  String get forceDateTimeString {
    if (DateUtils.isSameDay(DateTime.now(), this)) return Utils.mainContext.tr.today + ' • ' + timeString;
    return dateString + ' • ' + timeString;
  }

  DateTime get dateOnly {
    return DateTime(this.year, this.month, this.day);
  }
}
