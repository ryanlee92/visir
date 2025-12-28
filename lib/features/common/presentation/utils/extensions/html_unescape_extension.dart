import 'package:html_unescape/html_unescape.dart';

extension HtmlUnescapeX on HtmlUnescape {
  String? convertOrNull(String? value) {
    if (value == null) return null;
    return this.convert(value);
  }
}
