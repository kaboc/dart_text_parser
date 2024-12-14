import 'package:meta/meta.dart' show immutable;

import 'element.dart';
import 'text_parser.dart';

/// A base class of matchers used to provide [TextParser] with match
/// patterns for parsing.
///
/// As a result of parsing, each [TextElement] holds the type of this class
/// or its subclass to indicate which matcher the element was parsed by.
@immutable
abstract class TextMatcher {
  const TextMatcher(this.pattern);

  /// The regular expression string to specify the rule for parsing.
  final String pattern;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextMatcher &&
          runtimeType == other.runtimeType &&
          pattern == other.pattern;

  @override
  int get hashCode => Object.hash(runtimeType, pattern);

  @override
  String toString() => '$runtimeType(pattern: $pattern)';
}

/// A variant of [TextMatcher] that takes a regular expression pattern
/// as a parameter.
///
/// {@template text_parser_pattern_matcher}
/// This is convenient when you want to prepare a matcher with some
/// pattern without writing a new matcher class extending [TextMatcher].
///
/// ```dart
/// const boldMatcher = PatternMatcher(r'\*\*(.+?)\*\*');
/// ```
/// {@endtemplate}
class PatternMatcher extends TextMatcher {
  /// Creates a [PatternMatcher] with some regular expression pattern.
  ///
  /// {@macro text_parser_pattern_matcher}
  const PatternMatcher(super.pattern);
}
