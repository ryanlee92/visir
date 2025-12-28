import '../../results.dart' show ParsingResult;
import '../../types.dart' show Component;
import '../abstract_refiners.dart' show Filter;

class UnlikelyFormatFilter extends Filter {
  final bool _strictMode;

  UnlikelyFormatFilter([bool strictMode = false]) : _strictMode = strictMode, super();

  @override
  bool isValid(context, ParsingResult result) {
    if (RegExp(r'^\d*(\.\d*)?$').hasMatch(result.text.replaceFirst(" ", ""))) {
      return false;
    }

    if (!result.start.isValidDate()) {
      return false;
    }

    if (result.end != null && !result.end!.isValidDate()) {
      return false;
    }

    if (_strictMode) {
      return isStrictModeValid(context, result);
    }

    return true;
  }

  bool isStrictModeValid(context, ParsingResult result) {
    if (result.start.isOnlyWeekdayComponent()) {
      return false;
    }

    if (result.start.isOnlyTime() && (!result.start.isCertain(Component.hour) || !result.start.isCertain(Component.minute))) {
      return false;
    }

    return true;
  }
}
