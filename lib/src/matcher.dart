import 'package:meta/meta.dart';

/// A base class of matchers used to provide [TextParser] with match
/// patterns for parsing.
///
/// As a result of parsing, each [TextElement] holds a sub class type of
/// this class to show which matcher the element was parsed by.
@immutable
abstract class TextMatcher {
  const TextMatcher(this.pattern)
      : assert(
          pattern != null && pattern.length > 0,
          '`pattern` must not be null nor empty.',
        );

  /// The regular expression string to specify the rule for parsing.
  final String pattern;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextMatcher &&
          runtimeType == other.runtimeType &&
          pattern == other.pattern;

  @override
  int get hashCode => runtimeType.hashCode ^ pattern.hashCode;

  @override
  String toString() => '$runtimeType(pattern: $pattern)';
}
