String dartStringLiteral(String value) {
  final escaped = value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
  return "'$escaped'";
}

String enumName(Object value) {
  if (value is Enum) {
    return value.name;
  }
  if (value is String) {
    return value;
  }
  throw ArgumentError.value(
    value,
    'value',
    'Expected String or Enum for snippet enum input.',
  );
}

bool hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
}

String buildConstructorSnippet({
  required String constructor,
  required List<String> namedArguments,
}) {
  final buffer = StringBuffer()..writeln('$constructor(');
  for (final argument in namedArguments) {
    buffer.writeln('  $argument,');
  }
  buffer.write(')');
  return buffer.toString();
}
