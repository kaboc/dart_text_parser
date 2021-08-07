import 'package:meta/meta.dart';

/// A class that holds the information of a parsed element.
@immutable
abstract class TextElement {
  const TextElement(this.text, this.groups, this.matcherType, this.offset);

  /// The string that has matched the pattern in one of the matchers
  /// specified in [TextParser], or that has not matched any pattern.
  final String text;

  /// An array of the strings that have matched each smaller pattern
  /// enclosed with parentheses in a match pattern.
  final List<String?> groups;

  /// The type of the matcher whose match pattern has matched the [text].
  /// If the type is [TextMatcher], it means no patterns have matched it.
  final Type matcherType;

  /// The offset where the [text] starts in the source text.
  final int offset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextElement &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          matcherType == other.matcherType &&
          offset == other.offset;

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      text.hashCode ^
      matcherType.hashCode ^
      offset.hashCode;

  @override
  String toString() {
    final g = groups.map((v) => _convert(v)).join(', ');
    return 'matcherType: $matcherType, '
        'offset: $offset, '
        'text: ${_convert(text)}, '
        'groups: [$g]';
  }

  String? _convert(String? text) {
    return text
        ?.replaceAll('\r', r'\r')
        .replaceAll('\n', r'\n')
        .replaceAll('\t', r'\t');
  }
}
