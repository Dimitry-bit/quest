/// A utility class for parsing values from JSON and CSV strings.
abstract class ParseUtils {
  /// Retrieves a typed value from a JSON map based on the provided [key].
  ///
  /// Throws:
  ///   - [ArgumentError] if the [key] is not found in the [json] map or if the value is `null`.
  static T getValue<T>(Map<String, dynamic> json, String? key) {
    dynamic value = json[key];
    if (value == null) {
      throw ArgumentError.notNull(key);
    }

    return value as T;
  }

  /// Parses a CSV string into a list of trimmed strings.
  ///
  /// Returns an empty list if the [csvString] is `null` or empty.
  static List<String> parseCSV(String? csvString) {
    return csvString?.split(',').map((e) => e.trim()).toList() ?? [];
  }
}
