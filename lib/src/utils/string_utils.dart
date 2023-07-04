String toSnakeCase(String str) {
  return str.replaceAllMapped(RegExp('([A-Z])'), (match) => '_${match.group(1)!.toLowerCase()}');
}

String toCamelCase(String str) {
  return str.replaceAllMapped(RegExp('_([a-z])'), (match) => match.group(1)!.toUpperCase());
}
