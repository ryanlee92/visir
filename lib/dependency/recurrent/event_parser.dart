import 'dart:core';

import 'package:intl/intl.dart';

import 'constants.dart';

class Token {
  final String text;
  final String allText;
  final String type;

  Token(this.text, this.allText, this.type);

  @override
  String toString() {
    return '<Token $text: $type>';
  }
}

class RecurringEvent {
  late DateTime nowDate;
  late List<int> preferredTimeRange;
  bool isRecurring = false;

  // RRULE parameters
  DateTime? dtstart;
  DateTime? until;
  int? count;
  String? exdate;
  String? exrule;
  int? interval;
  String? freq;
  List<String> weekdays = [];
  List<String> ordinalWeekdays = [];
  String? byday;
  List<String> bymonthday = [];
  List<String> byyearday = [];
  List<String> bymonth = [];
  List<String> byhour = [];
  List<String> byminute = [];
  List<String> bysetpos = [];
  List<String> byweekno = [];

  RecurringEvent({DateTime? nowDate, List<int>? preferredTimeRange}) {
    this.nowDate = nowDate ?? DateTime.now();
    this.preferredTimeRange = preferredTimeRange ?? [8, 19];
    _reset();
  }

  void _reset() {
    dtstart = null;
    until = null;
    count = null;
    exdate = null;
    exrule = null;
    interval = null;
    freq = null;
    weekdays = [];
    ordinalWeekdays = [];
    byday = null;
    bymonthday = [];
    byyearday = [];
    bymonth = [];
    byhour = [];
    byminute = [];
    bysetpos = [];
    byweekno = [];
  }

  Map<String, dynamic> getParams() {
    Map<String, dynamic> params = {};

    if (ordinalWeekdays.isNotEmpty) {
      params['byday'] = ordinalWeekdays.join(',');
    } else if (weekdays.isNotEmpty) {
      params['byday'] = weekdays.join(',');
    }

    if (bymonthday.isNotEmpty) {
      params['bymonthday'] = bymonthday.join(',');
    }
    if (byyearday.isNotEmpty) {
      params['byyearday'] = byyearday.join(',');
    }
    if (bymonth.isNotEmpty) {
      params['bymonth'] = bymonth.join(',');
    }
    if (byhour.isNotEmpty) {
      params['byhour'] = byhour.join(',');
    }
    if (byminute.isNotEmpty) {
      params['byminute'] = byminute.join(',');
    }
    if (bysetpos.isNotEmpty) {
      params['bysetpos'] = bysetpos.join(',');
    }
    if (byweekno.isNotEmpty) {
      params['byweekno'] = byweekno.join(',');
    }
    if (interval != null) {
      params['interval'] = interval;
    }
    if (freq != null) {
      params['freq'] = freq;
    }
    if (dtstart != null) {
      params['dtstart'] = DateFormat('yyyyMMdd').format(dtstart!);
    }
    if (until != null) {
      params['until'] = DateFormat('yyyyMMdd').format(until!);
    } else if (count != null) {
      params['count'] = count;
    }
    if (exrule != null) {
      params['exrule'] = exrule;
    }
    if (exdate != null) {
      params['exdate'] = exdate;
    }

    return params;
  }

  String? getRfcRrule() {
    String rrule = '';
    Map<String, dynamic> params = getParams();

    if (!params.containsKey('freq')) {
      return null; // Not a valid RRULE
    }

    if (params.containsKey('dtstart')) {
      rrule += 'DTSTART:${params['dtstart']}\n';
      params.remove('dtstart');
    }

    String? exdate = params.remove('exdate');
    String? exrule = params.remove('exrule');

    rrule += 'RRULE:';
    List<String> rules = [];

    params.forEach((k, v) {
      if (v is String || v is int) {
        String value = v.toString().toUpperCase();
        rules.add('${k.toUpperCase()}=$value');
      }
    });

    String result = rrule + rules.join(';');

    if (exrule != null) {
      result += '\nEXRULE:$exrule';
    }
    if (exdate != null) {
      result += '\nEXDATE:$exdate';
    }

    return result;
  }

  dynamic parse(String s) {
    _reset();
    if (s.isEmpty) return null;

    s = _normalize(s);
    s = _handleBeginEnd(s);

    String? event = _parseStartAndEnd(s);
    if (event == null) return null;

    isRecurring = _parseEvent(event);
    if (isRecurring) {
      // Get time if it's obvious
      RegExp reAtTime = RegExp(r'at\s(\d{1,2}):?(\d{2})?\s?(am?|pm?)?(oclock)?');
      RegExp reTime = RegExp(r'(\d{1,2}):?(\d{2})?\s?(am?|pm?)?(oclock)?');
      RegExp reDefTime = RegExp(r'[:apo]');

      Match? m = reAtTime.firstMatch(event);
      if (m == null) {
        m = reTime.firstMatch(event);
        if (m != null && !reDefTime.hasMatch(m.group(0)!)) {
          m = null;
        }
      }

      if (m != null) {
        String hour = m.group(1)!;
        String? mod = m.group(3);
        byhour.add(_getHour(hour, mod).toString());

        String? minute = m.group(2);
        if (minute != null) {
          try {
            int mn = int.parse(minute);
            byminute.add(mn.toString());
          } catch (e) {
            // Ignore invalid minute
          }
        }
      }

      String? rrule = getRfcRrule();
      return rrule;
    }

    DateTime? date = _parseDate(s);
    if (date != null) {
      var result = _parseTime(s, date);
      return result['date'];
    }

    // Maybe we have a simple time expression
    var result = _parseTime(s, nowDate);
    if (result['found']) {
      return result['date'];
    }

    return null;
  }

  Map<String, dynamic> _parseTime(String s, DateTime dt) {
    RegExp reAtTime = RegExp(r'at\s(\d{1,2}):?(\d{2})?\s?(am?|pm?)?(oclock)?');
    RegExp reTime = RegExp(r'(\d{1,2}):?(\d{2})?\s?(am?|pm?)?(oclock)?');
    RegExp reDefTime = RegExp(r'[:apo]');

    Match? m = reAtTime.firstMatch(s);
    if (m == null) {
      m = reTime.firstMatch(s);
      if (m != null && !reDefTime.hasMatch(m.group(0)!)) {
        m = null;
      }
    }

    if (m != null) {
      String hour = m.group(1)!;
      String? minute = m.group(2);
      String? mod = m.group(3);

      int hr = _getHour(hour, mod);
      int? mn;

      if (minute != null) {
        try {
          mn = int.parse(minute);
        } catch (e) {
          mn = null;
        }
      }

      try {
        if (mn != null) {
          return {'date': DateTime(dt.year, dt.month, dt.day, hr, mn), 'found': true};
        } else {
          return {'date': DateTime(dt.year, dt.month, dt.day, hr), 'found': true};
        }
      } catch (e) {
        return {'date': dt, 'found': false};
      }
    }

    return {'date': dt, 'found': false};
  }

  static DateTime incrementDate(DateTime d, int amount, String units) {
    switch (units) {
      case 'years':
        return DateTime(d.year + amount, d.month, d.day, d.hour, d.minute, d.second);
      case 'months':
        int newMonth = d.month + amount;
        int newYear = d.year + (newMonth - 1) ~/ 12;
        newMonth = ((newMonth - 1) % 12) + 1;
        return DateTime(newYear, newMonth, d.day, d.hour, d.minute, d.second);
      case 'weeks':
        return d.add(Duration(days: amount * 7));
      case 'days':
        return d.add(Duration(days: amount));
      case 'hours':
        return d.add(Duration(hours: amount));
      case 'minutes':
        return d.add(Duration(minutes: amount));
      default:
        return d;
    }
  }

  String? _parseStartAndEnd(String s) {
    // This is a simplified version - the full implementation would be much more complex
    RegExp reStartEvent = RegExp(r'start(?:s|ing)?\s+(.*)');
    RegExp reEventStart =
        RegExp(r'(every|each|on|repeat|daily|weekdays|weekends|first|second|third|fourth|fifth|sixth|seventh|eighth|ninth|tenth|last).*start(?:s|ing)?\s+(.*)');
    RegExp reFromTo = RegExp(r'(.*)from(.*)(to|through|thru|until)(.*)');
    RegExp reStartEnd = RegExp(r'start(?:s|ing)?\s+(.*)\s+(?:end|until)(?:s|ing)?\s+(.*)');

    Match? match = reStartEvent.firstMatch(s);
    if (match != null) {
      return match.group(1);
    }

    match = reEventStart.firstMatch(s);
    if (match != null) {
      String? group1 = match.group(1);
      String? group2 = match.group(2);
      if (group1 != null && group2 != null) {
        return '$group1 $group2';
      }
    }

    match = reFromTo.firstMatch(s);
    if (match != null) {
      return match.group(1);
    }

    match = reStartEnd.firstMatch(s);
    if (match != null) {
      return match.group(1);
    }

    return s;
  }

  bool _parseEvent(String s) {
    // This is a simplified version - the full implementation would parse all the complex patterns
    if (Constants.reDaily.hasMatch(s)) {
      freq = 'daily';
      interval = 1;
      return true;
    }

    if (Constants.reRecurringUnit.hasMatch(s)) {
      freq = Constants.getUnitFreq(s);
      interval = 1;
      return true;
    }

    // Parse "every X days/weeks/months/years"
    // Handle "every day", "every week", etc. (no number, default to 1)
    RegExp reEverySingle = RegExp(r'every\s+(day|week|month|year)s?');
    Match? match = reEverySingle.firstMatch(s);
    if (match != null) {
      String unit = match.group(1)!;
      freq = Constants.getUnitFreq(unit);
      interval = 1;
      return true;
    }

    // Handle "every {number} day", "every {number} week", etc.
    RegExp reEveryInterval = RegExp(r'every\s+(\d+)\s+(day|week|month|year)s?');
    match = reEveryInterval.firstMatch(s);
    if (match != null) {
      int intervalValue = int.parse(match.group(1)!);
      String unit = match.group(2)!;
      freq = Constants.getUnitFreq(unit);
      interval = intervalValue;
      return true;
    }

    // Parse weekdays
    if (Constants.rePluralWeekday.hasMatch(s)) {
      freq = 'weekly';
      interval = 1;
      if (s.contains('weekday')) {
        byday = 'MO,TU,WE,TH,FR';
      } else if (s.contains('weekend')) {
        byday = 'SA,SU';
      } else {
        try {
          byday = Constants.getDoW(s).join(',');
        } catch (e) {
          return false;
        }
      }
      return true;
    }

    return false;
  }

  DateTime? _parseDate(String dateString) {
    // This is a simplified version - would need a proper date parsing library
    try {
      // Try to parse common date formats
      List<String> formats = [
        'yyyy-MM-dd',
        'MM/dd/yyyy',
        'dd/MM/yyyy',
        'yyyy/MM/dd',
      ];

      for (String format in formats) {
        try {
          return DateFormat(format).parse(dateString);
        } catch (e) {
          continue;
        }
      }

      // Try relative dates
      if (dateString.contains('today')) {
        return nowDate;
      } else if (dateString.contains('tomorrow')) {
        return nowDate.add(Duration(days: 1));
      } else if (dateString.contains('yesterday')) {
        return nowDate.subtract(Duration(days: 1));
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  int _getHour(String hr, String? mod) {
    int hour = int.parse(hr);

    if (mod != null) {
      if (mod.toLowerCase().startsWith('p') && hour != 12) {
        hour += 12;
      } else if (mod.toLowerCase().startsWith('a') && hour == 12) {
        hour = 0;
      }
    }

    return hour;
  }

  String _normalize(String s) {
    s = s.trim().toLowerCase();
    s = s.replaceAll(RegExp(r',\s*(\d{4})'), r' $1');
    s = s.replaceAll(RegExp(r',\s*and'), ' and');
    s = s.replaceAll(',', ' and ');
    s = s.replaceAll(RegExp(r'[^\w\s\./:-]'), '');
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s;
  }

  String _handleBeginEnd(String s) {
    RegExp reBeginEndOf = RegExp(r'(beginning|begin|start|ending|end)\s+of\b');
    RegExp reAtBeginEnd = RegExp(r'\bat(\s+the)?\s+(beginning\b|begin\b|start\b|ending\b|end\b)');

    s = s.replaceAllMapped(reBeginEndOf, (match) {
      if (match.group(1)!.startsWith('e')) {
        return 'last of';
      } else {
        return 'first of';
      }
    });

    s = s.replaceAllMapped(reAtBeginEnd, (match) {
      if (match.group(2)!.startsWith('e')) {
        return 'on the last';
      } else {
        return 'on the first';
      }
    });

    return s;
  }

  String format(dynamic rruleOrDatetime) {
    // This is a simplified version - the full implementation would be much more complex
    if (rruleOrDatetime is DateTime) {
      return DateFormat('yyyy-MM-dd HH:mm').format(rruleOrDatetime);
    } else if (rruleOrDatetime is String) {
      // Parse RRULE and format it nicely
      if (rruleOrDatetime.startsWith('RRULE:')) {
        return _formatRrule(rruleOrDatetime);
      }
    }

    return rruleOrDatetime.toString();
  }

  String _formatRrule(String rrule) {
    // Simplified RRULE formatting
    if (rrule.contains('FREQ=DAILY')) {
      return 'daily';
    } else if (rrule.contains('FREQ=WEEKLY')) {
      return 'weekly';
    } else if (rrule.contains('FREQ=MONTHLY')) {
      return 'monthly';
    } else if (rrule.contains('FREQ=YEARLY')) {
      return 'yearly';
    }

    return rrule;
  }
}
