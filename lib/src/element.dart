import 'package:meta/meta.dart';

import '../text_parser.dart';

/// A class that holds the information of a parsed element.
@immutable
class TextElement {
  /// Creates a [TextElement] that holds the information of a parsed element.
  const TextElement(
    this.text, {
    this.groups = const [],
    this.matcherType = TextMatcher,
    this.offset = 0,
  });

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
          groups.equals(other.groups) &&
          matcherType == other.matcherType &&
          offset == other.offset;

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        text,
        groups,
        matcherType,
        offset,
      ]);

  @override
  String toString() {
    final g = groups.map(_convert).join(', ');

    return 'TextElement('
        'matcherType: $matcherType, '
        'offset: $offset, '
        'text: ${_convert(text)}, '
        'groups: [$g]'
        ')';
  }

  /// Creates a new [TextElement] from this one by updating individual
  /// properties.
  ///
  /// This method creates a new [TextElement] object with values for
  /// the properties provided by similarly named arguments, or using
  /// the existing value of the property if no argument, or `null`,
  /// is provided.
  TextElement copyWith({
    String? text,
    List<String?>? groups,
    Type? matcherType,
    int? offset,
  }) {
    return TextElement(
      text ?? this.text,
      groups: groups ?? this.groups,
      matcherType: matcherType ?? this.matcherType,
      offset: offset ?? this.offset,
    );
  }

  String? _convert(String? text) {
    return text
        ?.replaceAll('\r', r'\r')
        .replaceAll('\n', r'\n')
        .replaceAll('\t', r'\t');
  }
}

extension on List<String?> {
  bool equals(List<String?> other) {
    if (length != other.length) {
      return false;
    }

    for (var i = 0; i < length; i++) {
      if (this[i] != other[i]) {
        return false;
      }
    }

    return true;
  }
}
