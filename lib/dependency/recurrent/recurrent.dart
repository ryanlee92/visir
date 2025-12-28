library recurrent;

import 'event_parser.dart';

export 'constants.dart' show Constants;

/// Export the main RecurringEvent class for direct use
export 'event_parser.dart' show RecurringEvent;

/// Parse a recurring event string and return an RRULE string or DateTime
///
/// [s] - The string to parse (e.g., "every Monday", "daily", "every 3 days")
/// [now] - Optional reference date (defaults to current date/time)
///
/// Returns:
/// - String: RRULE format if it's a recurring event
/// - DateTime: If it's a single date/time
/// - null: If the string cannot be parsed
dynamic parse(String s, [DateTime? now]) {
  return RecurringEvent(nowDate: now).parse(s);
}

/// Format an RRULE string or DateTime back to a human-readable string
///
/// [r] - RRULE string or DateTime to format
/// [now] - Optional reference date (defaults to current date/time)
///
/// Returns a human-readable string representation
String format(dynamic r, [DateTime? now]) {
  return RecurringEvent(nowDate: now).format(r);
}
