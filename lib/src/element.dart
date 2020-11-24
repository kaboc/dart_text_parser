part of 'parser.dart';

/// A class that holds the information of an element of text as the result
/// of parsing.
@immutable
abstract class TextElement {
  const TextElement(this.text, this.groups, this.matcherType);

  /// The string that has matched the pattern in one of the matchers specified
  /// in [TextParser], or that has not matched any pattern.
  final String text;

  /// Pieces of the string matching the smaller pattern enclosed in each
  /// parentheses in a match pattern.
  final List<String> groups;

  /// The type of the matcher whose match pattern has matched the `text`.
  final Type matcherType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextElement &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          matcherType == other.matcherType;

  @override
  int get hashCode =>
      runtimeType.hashCode ^ text.hashCode ^ matcherType.hashCode;

  @override
  String toString() {
    final g = groups.map((v) => _convert(v)).join(', ');
    return 'matcherType: $matcherType, '
        'text: ${_convert(text)}, '
        'groups: ${matcherType == null ? 'null' : '[$g]'}';
  }

  String _convert(String text) {
    return text
        ?.replaceAll('\r', r'\r')
        ?.replaceAll('\n', r'\n')
        ?.replaceAll('\t', r'\t');
  }
}

class _Element extends TextElement {
  const _Element(
    String text, {
    List<String> groups,
    Type matcherType,
  }) : super(
          text,
          groups ?? const [],
          matcherType ?? TextMatcher,
        );
}
