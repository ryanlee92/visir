import 'dart:core';

class Constants {
  static final List<String> doWs = [
    r'mon(day)?',
    r'tues?(day)?',
    r'(we(dnes|nds|ns|des)day)|(wed)',
    r'(th(urs|ers)day)|(thur?s?)',
    r'fri(day)?',
    r'sat([ue]rday)?',
    r'sun(day)?',
    r'weekday',
    r'weekend'
  ];

  static final List<RegExp> reDows = doWs.map((r) => RegExp(r)).toList();
  static final RegExp rePluralDow = RegExp('mondays|tuesdays|wednesdays|thursdays|fridays|saturdays|sundays');
  static final RegExp reDow = RegExp('(${doWs.join(')|(')})');
  static final RegExp rePluralWeekday = RegExp('weekdays|weekends|${rePluralDow.pattern}');

  static final List<String> weekdayCodes = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU', 'MO,TU,WE,TH,FR', 'SA,SU'];

  static final List<String> orderedWeekdayCodes = ['', 'SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'];

  static final Map<String, String> nextDay = {'MO': 'TU', 'TU': 'WE', 'WE': 'TH', 'TH': 'FR', 'FR': 'SA', 'SA': 'SU', 'SU': 'MO'};

  static final Map<String, String> dayNames = {'MO': 'Mon', 'TU': 'Tue', 'WE': 'Wed', 'TH': 'Thu', 'FR': 'Fri', 'SA': 'Sat', 'SU': 'Sun'};

  static final Map<String, String> pluralDayNames = {
    'MO': 'Mondays',
    'TU': 'Tuesdays',
    'WE': 'Wednesdays',
    'TH': 'Thursdays',
    'FR': 'Fridays',
    'SA': 'Saturdays',
    'SU': 'Sundays'
  };

  static final List<String> moYs = [
    r'jan(uary)?',
    r'feb(r?uary)?',
    r'mar(ch)?',
    r'apr(il)?',
    r'may',
    r'jun(e)?',
    r'jul(y)?',
    r'aug(ust)?',
    r'sept?(ember)?',
    r'oct(ober)?',
    r'nov(ember)?',
    r'dec(ember)?',
  ];

  static final List<RegExp> reMoys = moYs.map((r) => RegExp(r + r'$')).toList();
  static final RegExp reMoy = RegExp('(' + moYs.join(r')$|(') + r')$');
  static final RegExp reMoyNotAnchored = RegExp('(' + moYs.join(')|(') + ')');

  static final List<String> units = ['day', 'week', 'month', 'year', 'hour', 'minute', 'min', 'sec', 'seconds'];

  static final List<String> unitsFreq = ['daily', 'weekly', 'monthly', 'yearly', 'hourly', 'minutely', 'minutely', 'secondly', 'secondly'];

  static final RegExp reUnits = RegExp(r'^(day|week|month|year|hour|minute|min|sec|seconds)s?)$');

  static final List<String> ordinals = [
    'first',
    'second',
    'third',
    'fourth',
    'fifth',
    'sixth',
    'seventh',
    'eighth',
    'ninth',
    'tenth',
    'last',
  ];

  static final List<RegExp> reOrdinals = ordinals.map((r) => RegExp(r + r'$')).toList();
  static final RegExp reOrdinal = RegExp(r'\d+(st|nd|rd|th)$|' + ordinals.join(r'$|'));
  static final RegExp reOrdinalNotAnchored = RegExp(r'\d+(st|nd|rd|th)|' + ordinals.join('|'));

  static final List<String> numbers = [
    'zero',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
    'ten',
  ];

  static final List<RegExp> reNumbers = numbers.map((r) => RegExp(r + r'$')).toList();
  static final RegExp reNumber = RegExp('(' + numbers.join('|') + r')|(\d+)');
  static final RegExp reNumberNotAnchored = RegExp('(' + numbers.join('|') + r')|(\d+)');

  static final RegExp reEvery = RegExp(r'(every|each|once)$');
  static final RegExp reThrough = RegExp(r'(through|thru)$');
  static final RegExp reDaily = RegExp(r'daily|everyday');
  static final RegExp reRecurringUnit = RegExp(r'weekly|monthly|yearly');

  // Helper functions
  static int getNumber(String s) {
    try {
      return int.parse(s);
    } catch (e) {
      return numbers.indexOf(s);
    }
  }

  static int getOrdinalIndex(String s) {
    try {
      return int.parse(s.substring(0, s.length - 2));
    } catch (e) {
      // Continue to regex matching
    }

    int sign = s.startsWith('-') ? -1 : 1;
    for (int i = 0; i < reOrdinals.length; i++) {
      if (reOrdinals[i].hasMatch(s)) {
        if (i == 10) {
          // 'last'
          return -1;
        }
        return sign * (i + 1);
      }
    }
    throw FormatException('Invalid ordinal: $s');
  }

  static List<String> getDoW(String s) {
    for (int i = 0; i < reDows.length; i++) {
      if (reDows[i].hasMatch(s)) {
        return weekdayCodes[i].split(',');
      }
    }
    throw FormatException('Invalid day of week: $s');
  }

  static int getMoY(String s) {
    for (int i = 0; i < reMoys.length; i++) {
      if (reMoys[i].hasMatch(s)) {
        return i + 1;
      }
    }
    throw FormatException('Invalid month of year: $s');
  }

  static String getUnitFreq(String s) {
    for (int i = 0; i < units.length; i++) {
      if (s.contains(units[i])) {
        return unitsFreq[i];
      }
    }
    throw FormatException('Invalid unit: $s');
  }
}
